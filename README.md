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
