import spatial.dsl._

/* LSTM Inference Engine for Genre Classification
 * Architecture: 2-layer LSTM (input=128, hidden=128) + FC (128->10)
 * Input: projected spectrogram frame sequence, shape (50, 128)
 *   - 50 time steps, 128 features per step (after software proj 512->128)
 * Output: predicted genre index (0-9) as ArgOut
 *
 * Weight files (exported from PyTorch, flattened row-major CSVs):
 *   weight_ih_l0.csv  (512 x 128)
 *   weight_hh_l0.csv  (512 x 128)
 *   bias_ih_l0.csv    (512)
 *   bias_hh_l0.csv    (512)
 *   weight_ih_l1.csv  (512 x 128)
 *   weight_hh_l1.csv  (512 x 128)
 *   bias_ih_l1.csv    (512)
 *   bias_hh_l1.csv    (512)
 *   fc_weight.csv     (10 x 128)
 *   fc_bias.csv       (10)
 *   input_seq.csv     (50 x 128) -- the projected spectrogram chunk
 */

@spatial class LSTMInference extends SpatialTest {

  val T_STEPS  = 50    // time steps (chunk size)
  val INPUT_SZ = 128   // input size per step (after proj)
  val HIDDEN   = 128   // hidden size
  val GATES    = 4     // i, f, g, o
  val GATE_H   = 512   // GATES * HIDDEN
  val N_CLASS  = 10    // number of genres

  type T = FixPt[TRUE, _16, _16]  // signed 16.16 fixed point

  def main(args: Array[String]): Unit = {

    // -------- Load weights from CSV (host side) --------
    val wih0_flat = loadCSV1D[T]("weight_ih_l0.csv")  // 512*128 = 65536
    val whh0_flat = loadCSV1D[T]("weight_hh_l0.csv")  // 512*128
    val bih0_flat = loadCSV1D[T]("bias_ih_l0.csv")    // 512
    val bhh0_flat = loadCSV1D[T]("bias_hh_l0.csv")    // 512

    val wih1_flat = loadCSV1D[T]("weight_ih_l1.csv")
    val whh1_flat = loadCSV1D[T]("weight_hh_l1.csv")
    val bih1_flat = loadCSV1D[T]("bias_ih_l1.csv")
    val bhh1_flat = loadCSV1D[T]("bias_hh_l1.csv")

    val wfc_flat  = loadCSV1D[T]("fc_weight.csv")     // 10*128 = 1280
    val bfc_flat  = loadCSV1D[T]("fc_bias.csv")       // 10

    val input_flat = loadCSV1D[T]("input_seq.csv")    // 50*128 = 6400

    // -------- DRAMs --------
    val dWih0 = DRAM[T](GATE_H, INPUT_SZ)
    val dWhh0 = DRAM[T](GATE_H, HIDDEN)
    val dBih0 = DRAM[T](GATE_H)
    val dBhh0 = DRAM[T](GATE_H)

    val dWih1 = DRAM[T](GATE_H, HIDDEN)
    val dWhh1 = DRAM[T](GATE_H, HIDDEN)
    val dBih1 = DRAM[T](GATE_H)
    val dBhh1 = DRAM[T](GATE_H)

    val dWfc  = DRAM[T](N_CLASS, HIDDEN)
    val dBfc  = DRAM[T](N_CLASS)

    val dInput = DRAM[T](T_STEPS, INPUT_SZ)

    setMem(dWih0, wih0_flat)
    setMem(dWhh0, whh0_flat)
    setMem(dBih0, bih0_flat)
    setMem(dBhh0, bhh0_flat)

    setMem(dWih1, wih1_flat)
    setMem(dWhh1, whh1_flat)
    setMem(dBih1, bih1_flat)
    setMem(dBhh1, bhh1_flat)

    setMem(dWfc,  wfc_flat)
    setMem(dBfc,  bfc_flat)

    setMem(dInput, input_flat)

    // -------- Output: predicted class index --------
    val predOut = ArgOut[Int]

    Accel {

      // ---- Load weights into on-chip SRAMs ----
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

      wih0 load dWih0
      whh0 load dWhh0
      bih0 load dBih0
      bhh0 load dBhh0

      wih1 load dWih1
      whh1 load dWhh1
      bih1 load dBih1
      bhh1 load dBhh1

      wfc  load dWfc
      bfc  load dBfc

      // ---- Load input sequence ----
      val inputSeq = SRAM[T](T_STEPS, INPUT_SZ)
      inputSeq load dInput

      // ---- LSTM state registers ----
      // Layer 0
      val h0 = SRAM[T](HIDDEN)
      val c0 = SRAM[T](HIDDEN)
      // Layer 1
      val h1 = SRAM[T](HIDDEN)
      val c1 = SRAM[T](HIDDEN)

      // Initialize hidden/cell states to zero
      Foreach(HIDDEN by 1) { i =>
        h0(i) = 0.to[T]
        c0(i) = 0.to[T]
        h1(i) = 0.to[T]
        c1(i) = 0.to[T]
      }

      // ---- Scratch SRAMs for gate computations ----
      // gates0(g, j): gate g, hidden index j — layer 0
      val gates0 = SRAM[T](GATES, HIDDEN).conflictable
      val gates1 = SRAM[T](GATES, HIDDEN).conflictable

      // ---- Sequential over time steps ----
      Sequential.Foreach(T_STEPS by 1) { t =>

        // ==== LAYER 0: input is inputSeq[t] (size INPUT_SZ) ====
        // Compute gates: gates0[g][j] = sum_k(wih0[g*H+j][k] * x[k])
        //                             + sum_k(whh0[g*H+j][k] * h0[k])
        //                             + bih0[g*H+j] + bhh0[g*H+j]

        Foreach(GATES by 1, HIDDEN by 1) { (g, j) =>
          val row = g * HIDDEN + j

          // input contribution
          val xContrib = Reduce(Reg[T](0.to[T]))(INPUT_SZ by 1) { k =>
            wih0(row, k) * inputSeq(t, k)
          }{_ + _}

          // hidden contribution
          val hContrib = Reduce(Reg[T](0.to[T]))(HIDDEN by 1) { k =>
            whh0(row, k) * h0(k)
          }{_ + _}

          gates0(g, j) = xContrib.value + hContrib.value + bih0(row) + bhh0(row)
        }

        // Apply gate activations and update cell/hidden state — layer 0
        // PyTorch LSTM gate order: i=0, f=1, g=2, o=3
        Foreach(HIDDEN by 1) { j =>
          val i_gate = sigmoid(gates0(0, j))
          val f_gate = sigmoid(gates0(1, j))
          val g_gate = tanh_approx(gates0(2, j))
          val o_gate = sigmoid(gates0(3, j))

          val c0_new = f_gate * c0(j) + i_gate * g_gate
          val h0_new = o_gate * tanh_approx(c0_new)

          c0(j) = c0_new
          h0(j) = h0_new
        }

        // ==== LAYER 1: input is h0 (size HIDDEN) ====
        Foreach(GATES by 1, HIDDEN by 1) { (g, j) =>
          val row = g * HIDDEN + j

          val xContrib = Reduce(Reg[T](0.to[T]))(HIDDEN by 1) { k =>
            wih1(row, k) * h0(k)
          }{_ + _}

          val hContrib = Reduce(Reg[T](0.to[T]))(HIDDEN by 1) { k =>
            whh1(row, k) * h1(k)
          }{_ + _}

          gates1(g, j) = xContrib.value + hContrib.value + bih1(row) + bhh1(row)
        }

        Foreach(HIDDEN by 1) { j =>
          val i_gate = sigmoid(gates1(0, j))
          val f_gate = sigmoid(gates1(1, j))
          val g_gate = tanh_approx(gates1(2, j))
          val o_gate = sigmoid(gates1(3, j))

          val c1_new = f_gate * c1(j) + i_gate * g_gate
          val h1_new = o_gate * tanh_approx(c1_new)

          c1(j) = c1_new
          h1(j) = h1_new
        }
      } // end Sequential.Foreach over time steps

      // ---- FC layer: logits = wfc @ h1 + bfc ----
      // h1 is the final hidden state of layer 1 (last timestep)
      val logits = SRAM[T](N_CLASS)
      Foreach(N_CLASS by 1) { i =>
        val dot = Reduce(Reg[T](0.to[T]))(HIDDEN by 1) { j =>
          wfc(i, j) * h1(j)
        }{_ + _}
        logits(i) = dot.value + bfc(i)
      }

      // ---- Argmax over logits ----
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

    // Sanity check: result must be a valid class index
    val cksum = result >= 0 && result < N_CLASS
    println("PASS: " + cksum)
    assert(cksum)
  }

def sigmoid(x: T): T = {
  val clipped = mux(x > 6.to[T], 6.to[T], mux(x < -6.to[T], -6.to[T], x))
  val idx = ((clipped + 6.to[T]) * (255.to[T] / 12.to[T])).to[Int]
  val sigLUT = LUT[T](256)(List.tabulate(256){ i =>
    val xv = -6.0 + i * 12.0 / 255.0
    (1.0 / (1.0 + scala.math.exp(-xv))).to[T]
  } :_*)
  sigLUT(idx)
}

def tanh_approx(x: T): T = {
  2.to[T] * sigmoid(2.to[T] * x) - 1.to[T]
}}
