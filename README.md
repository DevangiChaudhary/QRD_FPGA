# FPGA-Based QR Decomposition Accelerator
### Verilog | Xilinx Artix-7 | Xilinx Vivado 2025.2

Hardware accelerator for QR Decomposition (QRD) using the Modified 
Gram-Schmidt (MGS) algorithm, implemented in Verilog on a Xilinx 
Artix-7 FPGA (xc7a200tfbg484-2). The design factorizes a matrix A 
into an orthonormal matrix Q and upper triangular matrix R (A = QR), 
a fundamental operation in signal processing, radar systems, MIMO 
communications, and numerical linear algebra.

---

## Overview

QR Decomposition is at the core of many real-time signal processing 
pipelines. This project implements the Modified Gram-Schmidt (MGS) 
orthogonalization algorithm entirely in hardware, mapping every 
mathematical operation directly to a custom RTL module operating under 
a finite state machine controller. The design targets a 4×4 matrix 
and operates on Q16.16 fixed-point arithmetic throughout.

---

## Architecture

The design follows a **datapath-controller methodology**:

- The **controller** is a 17-state FSM that sequences every step of 
  the MGS algorithm, issuing individual start pulses and monitoring 
  done signals for each computational unit
- The **datapath** contains all arithmetic units, memory blocks, and 
  registers, operating entirely under FSM control
- All arithmetic operates on **Q16.16 fixed-point** representation

### FSM State Sequence

START → CMP_VC → LOAD_V → CMP_QC → RDQ → LDQ →
START_DP → WAIT_DP → WAIT_SS → WRUP_DP → INC_QC →
START_L2 → WAIT_L2 → WAIT_VD → WRUP_L2 → INC_VC → DONE

The outer loop iterates over columns (Vc = 0 to N-1). The inner 
loop iterates over previous Q columns (Qc = 0 to Vc-1) performing 
orthogonal projection. Once all projections are complete, L2 norm 
and vector division produce the next orthonormal Q column.

---

## Module Hierarchy

top_QRD
├── controller 17-state FSM, all control signals
└── top_datapath
├── dot_product Euclidean inner product, 3-stage pipeline
├── scal_sub Orthogonal projection subtraction
├── l2norm L2 norm via pipelined sum-of-squares
├── vector_divide Element-wise column normalization
├── sqrt_cordic CORDIC-based square root (Xilinx IP)
├── division (×4) Parallel scalar division (Xilinx IP)
├── Amemory / bank Input matrix column ROM
├── Qmemory Orthonormal Q matrix RAM
├── Rmemory Upper triangular R matrix RAM
├── V_reg Working vector register
├── q_reg Q column register
├── Vc_reg Outer loop column counter
├── Qc_reg Inner loop counter
└── lessthancomp Loop termination comparator

---

## Fixed-Point Format — Q16.16

All arithmetic uses Q16.16 signed fixed-point representation:

Bit layout (32-bit):
[31] sign bit
[30:16] 15-bit integer part
[15:0] 16-bit fractional part

Properties:
Integer range: -32768 to +32767
Fractional bits: 16
Precision: 1 / 2^16 = 0.0000153
Scaling factor: 2^16 = 65,536
Safe input range: approximately ±100 for 4×4 matrices


**Encoding (Python):**
```python
scaled = int(round(value * 65536))
if scaled < 0:
    scaled += 2**32
hex_representation = scaled & 0xFFFFFFFF
```

**Decoding (Python):**
```python
if hex_val >= 2**31:
    hex_val -= 2**32
float_value = hex_val / 65536.0
```

---

## Performance

Measured on Xilinx Artix-7 (xc7a200tfbg484-2) using Xilinx Vivado 2025.2:

| Metric | Value |
|--------|-------|
| Matrix size | 4×4 |
| Fixed-point format | Q16.16 |
| Clock cycles per decomposition | ~365 cycles |
| Measured Fmax | ~360 MHz |
| Latency at Fmax | ~1.01 μs |
| Throughput | ~960,000 decompositions/sec |
| Timing slack WNS | +7.224 ns |
| Hold slack WHS | +0.086 ns |
| Failing timing endpoints | 0 / 119 |

---

## Resource Utilisation

**Post-synthesis (Xilinx Artix-7 xc7a200tfbg484-2):**

| Resource | Used | Available | Utilisation |
|----------|------|-----------|-------------|
| Slice LUTs | 976 | 134,600 | 0.73% |
| Slice Registers | 1,333 | 269,200 | 0.50% |
| DSP48E1 | 36 | 740 | 4.86% |
| Block RAM | 0 | 365 | 0.00% |
| CARRY4 | 167 | — | — |
| Distributed RAM | 130 | — | — |

Additional: 4× Xilinx Divider Generator IP + 1× Xilinx CORDIC IP

The design uses under 5% of available DSP blocks and under 1% of 
LUTs, leaving substantial headroom for scaling to larger matrix 
sizes or deploying alongside other processing blocks.

---

## Accuracy Analysis — Q16.16

Fixed-point precision evaluated by comparing hardware outputs against 
a Python double-precision floating-point reference on the same matrix:

| Metric | Value |
|--------|-------|
| R matrix mean error | 0.0206% |
| R matrix max error | 0.0370% |
| R matrix max absolute error | 0.000976 |
| Q matrix mean error | 0.0853% |
| Q matrix max error | 0.7020% |
| Q matrix max absolute error | 0.001324 |
| Orthonormality error ‖Q^T Q − I‖_max | ~0.002 |
| Reconstruction error ‖A − QR‖ / ‖A‖ | < 0.1% |

**Error accumulation across Q columns:**

| Q Column | Max Error % | Reason |
|----------|-------------|--------|
| Column 0 | 0.0121% | Direct normalisation, no projection |
| Column 1 | 0.1101% | One projection iteration |
| Column 2 | 0.7020% | Two projection iterations |
| Column 3 | 0.0693% | Three projection iterations |

Errors grow with column index due to accumulated Q16.16 rounding 
across successive orthogonalisation iterations — a known 
characteristic of fixed-point MGS implementations.

---

## Verification

- **Stepwise Vivado testbench** tracking every FSM state — 
  Gram-Schmidt projection coefficients, residual vector updates, 
  column norms, and orthonormal basis vector generation at each 
  iteration
- **Python floating-point reference model** implementing MGS in 
  double precision for direct output comparison
- **Multiple test matrices** including diagonal, identity-scaled, 
  and random full-rank matrices with varying condition numbers
- **Rank verification** ensuring all test matrices are full rank 
  before testing to avoid numerically degenerate cases

---

## How to Use

**1. Generate input matrix:**
```bash
python python/matrix_input_q16.py
```
Enter matrix values when prompted. The script validates Q16.16 
limits and writes the encoded hex values to `mem/Amatrix.mem`.

**2. Run simulation in Vivado:**

Add all source files from src/
Add tb/tb_top_QRD.v as simulation source
Add mem/Amatrix.mem
Run Behavioural Simulation

**3. Run synthesis and implementation:**

Add constraints/constraints.xdc
Run Synthesis
Run Implementation
Report Utilization and Timing Summary


---

## Tools

| Tool | Details |
|------|---------|
| HDL | Verilog |
| Synthesis & Implementation | Xilinx Vivado 2025.2 |
| Simulation | Vivado XSim |
| Target Device | xc7a200tfbg484-2 (Artix-7, Speed Grade -2) |
| Reference Model | Python 3, NumPy |
| IP Cores | Xilinx Divider Generator, Xilinx CORDIC v6.0 |

---

## Future Improvements

- Pipeline Vc iterations to overlap L2 norm computation with 
  next column data loading
- Systolic array architecture for 4-8× throughput improvement
- Replace Xilinx CORDIC IP with Newton-Raphson square root for 
  device-independent implementation
- Parameterize design for NxN matrices beyond 4×4
- AXI-Stream interface for integration with Xilinx Zynq SoC
- Full board deployment with UART interface for real-time 
  matrix input and result readback

---

## Fixed-Point Format Exploration — Q12.20

As an extension to the base Q16.16 implementation, the design was 
also tested with Q12.20 fixed-point format to evaluate the impact 
of increased fractional precision on accuracy.

**Q12.20 format:**

Integer range: ±2,047
Fractional bits: 20
Precision: 1 / 2^20 = 0.00000095 (16× better than Q16.16)
Safe input range: approximately ±40 for 4×4 matrices
