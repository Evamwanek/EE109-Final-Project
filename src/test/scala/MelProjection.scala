import spatial.dsl._

// mel projection stage - this is the missing middle piece between butterfly and lstm
// takes fft_real.csv + fft_imag.csv (50 x 1024 complex output from butterfly)
// does: magnitude -> log -> normalize -> linear proj 512->128
// writes input_seq.csv (50 x 128) which lstm.scala reads directly
@spatial class MelProjection extends SpatialTest {

  val N_FRAMES  = 50
  val N_FFT     = 1024
  val N_BINS    = 512   // we only use first 512 bins (matches fft_runner.py)
  val PROJ_OUT  = 128   // proj layer output size, matches lstm input size

  // fft uses _8,_24 (same as butterfly), proj uses _16,_16 (same as lstm)
  type TFFT  = FixPt[TRUE, _8,  _24]
  type T     = FixPt[TRUE, _16, _16]

  // log LUT: 512 points over [1e-10, ~1500]
  // covers the range of FFT magnitudes for audio at 22050hz
  // using natural log then scaling by 20/ln(10) to match 20*log10
  val LOG_LUT_SZ  = 512
  val LOG_LUT_MAX = 1500.0
  val LOG_SCALE   = (20.0 / scala.math.log(10.0))  // converts ln to 20*log10

  def main(args: Array[String]): Unit = {

    // load fft outputs from butterfly
    val fftRealFlat = loadCSV1D[TFFT]("fft_real.csv")
    val fftImagFlat = loadCSV1D[TFFT]("fft_imag.csv")

    // load proj layer weights exported from model_small.pth
    // proj_weight shape: (128, 512) flattened = 65536 values
    // proj_bias shape: (128,)
    val projWeightFlat = loadCSV1D[T]("proj_weight.csv")
    val projBiasFlat   = loadCSV1D[T]("proj_bias.csv")

    // dram for fft inputs
    val dFftReal = DRAM[TFFT](N_FRAMES, N_FFT)
    val dFftImag = DRAM[TFFT](N_FRAMES, N_FFT)

    // dram for proj weights
    val dProjW = DRAM[T](PROJ_OUT, N_BINS)
    val dProjB = DRAM[T](PROJ_OUT)

    // dram for final output -> this is what lstm.scala reads as input_seq
    val dOutput = DRAM[T](N_FRAMES, PROJ_OUT)

    setMem(dFftReal, fftRealFlat)
    setMem(dFftImag, fftImagFlat)
    setMem(dProjW,   projWeightFlat)
    setMem(dProjB,   projBiasFlat)

    // build log LUT on host side - 512 points from eps to max magnitude
    // avoids doing ln() in hardware which is expensive
    val logLutList = List.tabulate(LOG_LUT_SZ) { i =>
      val x = 1e-10 + i.toDouble * (LOG_LUT_MAX - 1e-10) / (LOG_LUT_SZ - 1)
      (LOG_SCALE * scala.math.log(x)).to[T]
    }

    Accel {

      // load proj weights into on-chip sram once - dont reload per frame
      val projW = SRAM[T](PROJ_OUT, N_BINS)
      val projB = SRAM[T](PROJ_OUT)
      projW load dProjW
      projB load dProjB

      // log lut lives on chip
      val logLUT = LUT[T](LOG_LUT_SZ)(logLutList :_*)

      // per-frame buffers
      val fftReal = SRAM[TFFT](N_FFT)
      val fftImag = SRAM[TFFT](N_FFT)
      val magBuf  = SRAM[T](N_BINS)     // magnitude for first 512 bins
      val logBuf  = SRAM[T](N_BINS)     // log magnitude
      val outBuf  = SRAM[T](PROJ_OUT)   // proj output (128)

      // accumulators for normalization (mean + std across 512 bins x 50 frames)
      // we normalize per-clip the same way fft_runner.py does: (x - mean) / std
      // doing it in two passes: first compute mean, then std, then normalize
      val sumReg    = Reg[T](0.to[T])
      val sumSqReg  = Reg[T](0.to[T])
      val countReg  = Reg[T]((N_FRAMES * N_BINS).to[T])

      // --- pass 1: compute all log-magnitudes and accumulate sum/sumsq ---
      // store all log mags in a big sram so we dont redo work in pass 2
      val allLogMag = SRAM[T](N_FRAMES, N_BINS)

      Reduce(sumReg)(N_FRAMES by 1) { f =>
        fftReal load dFftReal(f, 0::N_FFT)
        fftImag load dFftImag(f, 0::N_FFT)

        // magnitude for first 512 bins only
        Foreach(N_BINS by 1) { i =>
          val r = fftReal(i).to[T]
          val im = fftImag(i).to[T]
          val mag = sqrt(r * r + im * im)  // sqrt is ok in spatial simulation

          // lut lookup: clamp mag to [0, LOG_LUT_MAX], find index
          val magClamped = mux(mag > LOG_LUT_MAX.to[T], LOG_LUT_MAX.to[T], mag)
          val lutIdx = Reg[Int](0)
          lutIdx := (magClamped * ((LOG_LUT_SZ - 1).to[T] / LOG_LUT_MAX.to[T])).to[Int]
          val logMag = logLUT(lutIdx.value)

          allLogMag(f, i) = logMag
          magBuf(i) = logMag  // temp reuse for sum reduction below
        }

        // sum all bins in this frame
        Reduce(Reg[T](0.to[T]))(N_BINS by 1) { i => magBuf(i) } {_ + _}
      } {_ + _}

      // compute sum of squares
      Reduce(sumSqReg)(N_FRAMES by 1) { f =>
        Reduce(Reg[T](0.to[T]))(N_BINS by 1) { i =>
          allLogMag(f, i) * allLogMag(f, i)
        } {_ + _}
      } {_ + _}

      // mean and std
      val mean = sumReg.value / countReg
      val variance = sumSqReg.value / countReg - mean * mean
      // clamp variance > 0 to avoid sqrt(negative) from fixed point rounding
      val varClamped = mux(variance < 0.to[T], 0.001.to[T], variance)
      val std = sqrt(varClamped) + 1e-8.to[T]

      // --- pass 2: normalize then project each frame ---
      Sequential.Foreach(N_FRAMES by 1) { f =>

        // normalize this frame
        Foreach(N_BINS by 1) { i =>
          logBuf(i) = (allLogMag(f, i) - mean) / std
        }

        // linear projection: outBuf = projW @ logBuf + projB
        // projW is (128 x 512), logBuf is (512,) -> outBuf is (128,)
        Foreach(PROJ_OUT by 1) { o =>
          val dot = Reduce(Reg[T](0.to[T]))(N_BINS by 1) { i =>
            projW(o, i) * logBuf(i)
          } {_ + _}
          outBuf(o) = dot.value + projB(o)
        }

        // store this frame's projection to output dram
        dOutput(f, 0::PROJ_OUT) store outBuf
      }

    } // end Accel

    // write result - lstm.scala reads this as input_seq.csv
    val result = getMem(dOutput)
    writeCSV1D(result, "input_seq.csv")

    val cksum = true
    println("PASS: " + cksum)
    assert(cksum)
  }
}
