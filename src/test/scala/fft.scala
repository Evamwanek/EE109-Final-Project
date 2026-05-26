import spatial.dsl._

/* The following code preforms radix 2 FFT on a 1024 block 
of audio input. A Hamming window is used on time domain samples, 
* then processed using butterfly stages until frequency 
* domain FFT components are outputted 
*/
@spatial class Butterfly extends SpatialTest {
    val N = 1024 
    val numFrames = 50
    val numStages = 10  // log2(1024), as defined by Cooley Tookey alg
    type T = FixPt[TRUE, _8, _24] // fine precision

def main(args: Array[String]): Unit = {
    val n = 1024
    val nStages = 10
    val realArr = loadCSV1D[T]("/Users/evawanek/EE109-Final-Project/frames.csv")
    val ImagArr = Array.fill[T](numFrames * N)(0.to[T])

    val inputRealDRAM  = DRAM[T](numFrames, N)
    val inputImagDRAM  = DRAM[T](numFrames, N)
    val outputRealDRAM = DRAM[T](numFrames, N)
    val outputImagDRAM = DRAM[T](numFrames, N)
    
    setMem(inputRealDRAM, realArr)
    setMem(inputImagDRAM, ImagArr)
    
    // get all twiddle factors for all stages on host side
    // twiddle factor (w), acts as a phase shifter and weight
    // (W_N^k = e^(-j*2pik/N)
    val twRList = List.tabulate(n/2){ k =>
        scala.math.cos(-2.0 * scala.math.Pi * k / n).to[T]
    }
    val twIList = List.tabulate(n/2){ k =>
        scala.math.sin(-2.0 * scala.math.Pi * k / n).to[T]
    }
    // src: https://graphics.stanford.edu/~seander/bithacks.html#BitReverseObvious
    val bitRevList = List.tabulate[Int](n) { i =>
        (Integer.reverse(i) >>> (32 - numStages)).to[Int]
    }
    
    // precomute butterfly parameters
    val halfStrides = List.tabulate(nStages)(s => (1 << s).to[Int]) // 2^s
    val strides = List.tabulate(nStages)(s => (1 << (s + 1)).to[Int])  // 2^s+1
    val twSteps = List.tabulate(nStages)(s => ((n/2) / (1 << s)).to[Int])
    
    // classic Hamming window function
    val hammingList = List.tabulate(n){ i => 
        (0.54 - 0.46 * scala.math.cos(2.0 * scala.math.Pi * i / (n - 1))).to[T] 
    }
    
    Accel {
        // hardware LUTs
        // :_* ensures entire list doesn't become one LUT entry,
        // and that the list elements are separated 
        val twR = LUT[T](N/2)(twRList :_*)
        val twI = LUT[T](N/2)(twIList :_*)
        val hammingLUT = LUT[T](N)(hammingList :_*)
        val halfStrideLUT = LUT[Int](numStages)(halfStrides :_*)
        val strideLUT = LUT[Int](numStages)(strides :_*)
        val twStepLUT = LUT[Int](numStages)(twSteps :_*)
        val bitRevLUT = LUT[Int](N)(bitRevList :_*)
        
        val inReal  = SRAM[T](N)
        val inImag  = SRAM[T](N)
        // from error, detected potential write conflicts... 
        // consider either: manually deconflicting them or add .conflictable flag
        val outReal = SRAM[T](N).conflictable
        val outImag = SRAM[T](N).conflictable

        val tmpReal = SRAM[T](N)
        val tmpImag = SRAM[T](N)

        Sequential.Foreach(numFrames by 1) { f =>
            
            inReal load inputRealDRAM(f, 0::N)
            inImag load inputImagDRAM(f, 0::N)
            
            // apply window function
            Foreach(N by 1){ i =>
                inReal(i) = inReal(i) * hammingLUT(i)
                inImag(i) = inImag(i) * hammingLUT(i)
            }
            
            Sequential.Foreach(N by 1){ i =>
                val rev = bitRevLUT(i)
                tmpReal(rev) = inReal(i)
                tmpImag(rev) = inImag(i)
            }
    
            Foreach(N by 1){ i =>
                inReal(i) = tmpReal(i)
                inImag(i) = tmpImag(i)
            }
    
            // 0-9 stages 
            Sequential.Foreach(numStages by 1){ s =>
                // load parameters for this stage 
                val halfStride = halfStrideLUT(s)
                val stride = strideLUT(s)
                val twStep = twStepLUT(s)
            
            Sequential {
            // total # of butterflies in any stage is N/2
            Foreach(N/2 by 1){ k =>
                // butterfly parameters
                // butterfly group/ iteration index
                val group = k / halfStride
                val pos = k % halfStride
                val topIdx = group * stride + pos
                val botIdx = topIdx + halfStride
                val twIdx = pos * twStep
                
                val w_real = twR(twIdx)
                val w_imag = twI(twIdx)
                
                val a_real = inReal(topIdx)
                val b_real = inReal(botIdx)
                
                val a_imag = inImag(topIdx)
                val b_imag = inImag(botIdx)
                
                val bw_real = b_real * w_real - b_imag * w_imag
                val bw_imag = b_real * w_imag + b_imag * w_real
                
                outReal(topIdx) = a_real + bw_real
                outImag(topIdx) = a_imag + bw_imag
                outReal(botIdx) = a_real - bw_real
                outImag(botIdx) = a_imag - bw_imag
            }
            
            Foreach(N by 1){ i =>
                inReal(i) = outReal(i)
                inImag(i) = outImag(i)
            }
            }
        }
        outputRealDRAM store inReal
        outputImagDRAM store inImag
        }
    }

    val resultReal = getMem(outputRealDRAM(0::numFrames, 0::N))
    val resultImag = getMem(outputImagDRAM(0::numFrames, 0::N))

    writeCSV1D(resultReal, "fft_real.csv")
    writeCSV1D(resultImag, "fft_imag.csv")

    val cksum = true
    println("PASS: " + cksum)
    assert(cksum)
}
}
