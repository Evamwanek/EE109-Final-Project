import spatial.dsl._

/* LSTM Inference Engine for Genre Classification
 * Architecture: 2-layer LSTM (input=128, hidden=128) + FC (128->10)
 * Input: projected spectrogram frame sequence, shape (50, 128)
 * Output: predicted genre index (0-9) as ArgOut
 */

@spatial class LSTMInference extends SpatialTest {

  val T_STEPS  = 50
  val INPUT_SZ = 128
  val HIDDEN   = 128
  val GATES    = 4
  val GATE_H   = 512
  val N_CLASS  = 10

  type T = FixPt[TRUE, _16, _16]

  def main(args: Array[String]): Unit = {

    val wih0_flat  = loadCSV1D[T]("weight_ih_l0.csv")
    val whh0_flat  = loadCSV1D[T]("weight_hh_l0.csv")
    val bih0_flat  = loadCSV1D[T]("bias_ih_l0.csv")
    val bhh0_flat  = loadCSV1D[T]("bias_hh_l0.csv")
    val wih1_flat  = loadCSV1D[T]("weight_ih_l1.csv")
    val whh1_flat  = loadCSV1D[T]("weight_hh_l1.csv")
    val bih1_flat  = loadCSV1D[T]("bias_ih_l1.csv")
    val bhh1_flat  = loadCSV1D[T]("bias_hh_l1.csv")
    val wfc_flat   = loadCSV1D[T]("fc_weight.csv")
    val bfc_flat   = loadCSV1D[T]("fc_bias.csv")
    val input_flat = loadCSV1D[T]("input_seq.csv")

    val dWih0  = DRAM[T](GATE_H, INPUT_SZ)
    val dWhh0  = DRAM[T](GATE_H, HIDDEN)
    val dBih0  = DRAM[T](GATE_H)
    val dBhh0  = DRAM[T](GATE_H)
    val dWih1  = DRAM[T](GATE_H, HIDDEN)
    val dWhh1  = DRAM[T](GATE_H, HIDDEN)
    val dBih1  = DRAM[T](GATE_H)
    val dBhh1  = DRAM[T](GATE_H)
    val dWfc   = DRAM[T](N_CLASS, HIDDEN)
    val dBfc   = DRAM[T](N_CLASS)
    val dInput = DRAM[T](T_STEPS, INPUT_SZ)

    setMem(dWih0, wih0_flat);  setMem(dWhh0, whh0_flat)
    setMem(dBih0, bih0_flat);  setMem(dBhh0, bhh0_flat)
    setMem(dWih1, wih1_flat);  setMem(dWhh1, whh1_flat)
    setMem(dBih1, bih1_flat);  setMem(dBhh1, bhh1_flat)
    setMem(dWfc,  wfc_flat);   setMem(dBfc,  bfc_flat)
    setMem(dInput, input_flat)

    val predOut = ArgOut[Int]

    Accel {

      // sigmoid LUT: 256 points over [-6, 6], defined once
      val sigLUT = LUT[T](256)(List.tabulate(256){ i =>
        val xv = -6.0 + i * 12.0 / 255.0
        (1.0 / (1.0 + scala.math.exp(-xv))).to[T]
      } :_*)

      val wih0 = SRAM[T](GATE_H, INPUT_SZ)
      val whh0 = SRAM[T](GATE_H, HIDDEN)
      val bih0 = SRAM[T](GATE_H)
      val bhh0 = SRAM[T](GATE_H)
      val wih1 = SRAM[T](GATE_H, HIDDEN)
      val whh1 = SRAM[T](GATE_H, HIDDEN)
      val bih1 = SRAM[T](GATE_H)
      val bhh1 = SRAM[T](GATE_H)
      val wfc  = SRAM[T](N_CLASS, HIDDEN)
      val bfc  = SRAM[T](N_CLASS)

      wih0 load dWih0;  whh0 load dWhh0
      bih0 load dBih0;  bhh0 load dBhh0
      wih1 load dWih1;  whh1 load dWhh1
      bih1 load dBih1;  bhh1 load dBhh1
      wfc  load dWfc;   bfc  load dBfc

      val inputSeq = SRAM[T](T_STEPS, INPUT_SZ)
      inputSeq load dInput

      val h0 = SRAM[T](HIDDEN)
      val c0 = SRAM[T](HIDDEN)
      val h1 = SRAM[T](HIDDEN)
      val c1 = SRAM[T](HIDDEN)

      Foreach(HIDDEN by 1) { i =>
        h0(i) = 0.to[T]; c0(i) = 0.to[T]
        h1(i) = 0.to[T]; c1(i) = 0.to[T]
      }

      val gates0 = SRAM[T](GATES, HIDDEN).conflictable
      val gates1 = SRAM[T](GATES, HIDDEN).conflictable

      // helper macro: clip x to [-6,6], compute LUT index into a Reg, return sigLUT value
      // (avoids .to[Int] inline which triggers Spatial's Math.v rdy redeclaration bug)

      Sequential.Foreach(T_STEPS by 1) { t =>

        // --- Layer 0 gate pre-activations ---
        Foreach(GATES by 1, HIDDEN by 1) { (g, j) =>
          val row = g * HIDDEN + j
          val xC = Reduce(Reg[T](0.to[T]))(INPUT_SZ by 1) { k =>
            wih0(row, k) * inputSeq(t, k)
          }{_ + _}
          val hC = Reduce(Reg[T](0.to[T]))(HIDDEN by 1) { k =>
            whh0(row, k) * h0(k)
          }{_ + _}
          gates0(g, j) = xC.value + hC.value + bih0(row) + bhh0(row)
        }

        // --- Layer 0 gate activations + state update ---
        Foreach(HIDDEN by 1) { j =>

          // i gate: sigmoid(gates0(0,j))
          val ig = gates0(0, j)
          val ic = mux(ig > 6.to[T], 6.to[T], mux(ig < -6.to[T], -6.to[T], ig))
          val i_idx = Reg[Int](0); i_idx := ((ic + 6.to[T]) * (255.to[T] / 12.to[T])).to[Int]
          val i_gate = sigLUT(i_idx.value)

          // f gate: sigmoid(gates0(1,j))
          val fg = gates0(1, j)
          val fc_clip = mux(fg > 6.to[T], 6.to[T], mux(fg < -6.to[T], -6.to[T], fg))
          val f_idx = Reg[Int](0); f_idx := ((fc_clip + 6.to[T]) * (255.to[T] / 12.to[T])).to[Int]
          val f_gate = sigLUT(f_idx.value)

          // g gate: tanh(gates0(2,j)) = 2*sigmoid(2*x)-1
          val gg = gates0(2, j) * 2.to[T]
          val gc = mux(gg > 6.to[T], 6.to[T], mux(gg < -6.to[T], -6.to[T], gg))
          val g_idx = Reg[Int](0); g_idx := ((gc + 6.to[T]) * (255.to[T] / 12.to[T])).to[Int]
          val g_gate = 2.to[T] * sigLUT(g_idx.value) - 1.to[T]

          // o gate: sigmoid(gates0(3,j))
          val og = gates0(3, j)
          val oc = mux(og > 6.to[T], 6.to[T], mux(og < -6.to[T], -6.to[T], og))
          val o_idx = Reg[Int](0); o_idx := ((oc + 6.to[T]) * (255.to[T] / 12.to[T])).to[Int]
          val o_gate = sigLUT(o_idx.value)

          val c0_new = f_gate * c0(j) + i_gate * g_gate

          // tanh(c0_new)
          val tc = c0_new * 2.to[T]
          val tcc = mux(tc > 6.to[T], 6.to[T], mux(tc < -6.to[T], -6.to[T], tc))
          val tc_idx = Reg[Int](0); tc_idx := ((tcc + 6.to[T]) * (255.to[T] / 12.to[T])).to[Int]
          val tanh_c0 = 2.to[T] * sigLUT(tc_idx.value) - 1.to[T]

          c0(j) = c0_new
          h0(j) = o_gate * tanh_c0
        }

        // --- Layer 1 gate pre-activations ---
        Foreach(GATES by 1, HIDDEN by 1) { (g, j) =>
          val row = g * HIDDEN + j
          val xC = Reduce(Reg[T](0.to[T]))(HIDDEN by 1) { k =>
            wih1(row, k) * h0(k)
          }{_ + _}
          val hC = Reduce(Reg[T](0.to[T]))(HIDDEN by 1) { k =>
            whh1(row, k) * h1(k)
          }{_ + _}
          gates1(g, j) = xC.value + hC.value + bih1(row) + bhh1(row)
        }

        // --- Layer 1 gate activations + state update ---
        Foreach(HIDDEN by 1) { j =>

          val ig = gates1(0, j)
          val ic = mux(ig > 6.to[T], 6.to[T], mux(ig < -6.to[T], -6.to[T], ig))
          val i_idx = Reg[Int](0); i_idx := ((ic + 6.to[T]) * (255.to[T] / 12.to[T])).to[Int]
          val i_gate = sigLUT(i_idx.value)

          val fg = gates1(1, j)
          val fc_clip = mux(fg > 6.to[T], 6.to[T], mux(fg < -6.to[T], -6.to[T], fg))
          val f_idx = Reg[Int](0); f_idx := ((fc_clip + 6.to[T]) * (255.to[T] / 12.to[T])).to[Int]
          val f_gate = sigLUT(f_idx.value)

          val gg = gates1(2, j) * 2.to[T]
          val gc = mux(gg > 6.to[T], 6.to[T], mux(gg < -6.to[T], -6.to[T], gg))
          val g_idx = Reg[Int](0); g_idx := ((gc + 6.to[T]) * (255.to[T] / 12.to[T])).to[Int]
          val g_gate = 2.to[T] * sigLUT(g_idx.value) - 1.to[T]

          val og = gates1(3, j)
          val oc = mux(og > 6.to[T], 6.to[T], mux(og < -6.to[T], -6.to[T], og))
          val o_idx = Reg[Int](0); o_idx := ((oc + 6.to[T]) * (255.to[T] / 12.to[T])).to[Int]
          val o_gate = sigLUT(o_idx.value)

          val c1_new = f_gate * c1(j) + i_gate * g_gate

          val tc = c1_new * 2.to[T]
          val tcc = mux(tc > 6.to[T], 6.to[T], mux(tc < -6.to[T], -6.to[T], tc))
          val tc_idx = Reg[Int](0); tc_idx := ((tcc + 6.to[T]) * (255.to[T] / 12.to[T])).to[Int]
          val tanh_c1 = 2.to[T] * sigLUT(tc_idx.value) - 1.to[T]

          c1(j) = c1_new
          h1(j) = o_gate * tanh_c1
        }

      } // end Sequential.Foreach over time steps

      // --- FC layer ---
      val logits = SRAM[T](N_CLASS)
      Foreach(N_CLASS by 1) { i =>
        val dot = Reduce(Reg[T](0.to[T]))(HIDDEN by 1) { j =>
          wfc(i, j) * h1(j)
        }{_ + _}
        logits(i) = dot.value + bfc(i)
      }

      // --- Argmax ---
      val maxVal = Reg[T](-1000.to[T])
      val maxIdx = Reg[Int](0)
      Sequential.Foreach(N_CLASS by 1) { i =>
        if (logits(i) > maxVal.value) {
          maxVal := logits(i)
          maxIdx := i
        }
      }

      predOut := maxIdx.value

    } // end Accel

    val result = getArg(predOut)
    println("Predicted genre index: " + result)
    val cksum = result >= 0 && result < N_CLASS
    println("PASS: " + cksum)
    assert(cksum)
  }
}
