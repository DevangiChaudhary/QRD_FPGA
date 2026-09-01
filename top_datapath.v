`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 23:17:57
// Design Name: 
// Module Name: top_datapath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_datapath #(
    parameter N     = 4,
    parameter WIDTH = 32
)(
    input  clk,

    // ── Counter controls ──────────────────────────────────────
    input  clrVc,
    input  incVc,
    input  clrQc,
    input  incQc,

    // ── Register load controls ────────────────────────────────
    input  ldV,
    input  ldq,
    input  selV,       // 0 = Amemory, 1 = scal_sub result

    // ── Memory write controls ─────────────────────────────────
    input  wrQ,
    input  rdQ,
    input  wrR,

    // ── Computation start pulses ──────────────────────────────
    input  start_dp,
    input  start_ss,
    input  start_l2,
    input  start_vd,

    // ── Status outputs ────────────────────────────────────────
    output ltVc,
    output ltQc,
    output dp_done,
    output ss_done,
    output l2_done,
    output vd_done
);

    // ── Counter outputs ───────────────────────────────────────
    wire [3:0] Vcout;
    wire [3:0] Qcout;

    Vc_reg #(.N(N)) vc (
        .clk   (clk),
        .clrVc (clrVc),
        .incVc (incVc),
        .Vcout (Vcout)
    );

    Qc_reg #(.N(N)) qc (
        .clk   (clk),
        .clrQc (clrQc),
        .incQc (incQc),
        .Qcout (Qcout)
    );

    // ── Comparators ───────────────────────────────────────────
    lessthancomp #(.WIDTH(4)) comp_vc (
        .A  (Vcout),
        .B  (4'd4),
        .lt (ltVc)
    );

    lessthancomp #(.WIDTH(4)) comp_qc (
        .A  (Qcout),
        .B  (Vcout),
        .lt (ltQc)
    );

    // ── A matrix memory ───────────────────────────────────────
    wire [N*WIDTH-1:0] A_col;

    Amemory #(.N(N), .WIDTH(WIDTH)) amem (
        .addr   (Vcout),
        .V_flat (A_col)
    );

    // ── dot_product ───────────────────────────────────────────
    wire signed [WIDTH-1:0] dp_result;

    dot_product #(.N(N), .WIDTH(WIDTH)) dp (
        .clk       (clk),
        .start     (start_dp),
        .Vout_flat (Vout_flat),
        .qout_flat (qout_flat),
        .result    (dp_result),
        .done      (dp_done)
    );

    // ── scal_sub ──────────────────────────────────────────────
    wire [N*WIDTH-1:0] ss_result_flat;

    scal_sub #(.N(N), .WIDTH(WIDTH)) ss (
        .clk        (clk),
        .start      (start_ss),
        .Vout_flat  (Vout_flat),
        .qout_flat  (qout_flat),
        .R_val      (dp_result),
        .result_flat(ss_result_flat),
        .done       (ss_done)
    );

    // ── V_reg input mux ───────────────────────────────────────
    // selV=0 → Amemory column
    // selV=1 → scal_sub result
    wire [N*WIDTH-1:0] V_bus;
    assign V_bus = selV ? ss_result_flat : A_col;

    // ── V register ────────────────────────────────────────────
    wire [N*WIDTH-1:0] Vout_flat;

    V_reg #(.N(N), .WIDTH(WIDTH)) vreg (
        .clk      (clk),
        .ldV      (ldV),
        .V_bus    (V_bus),
        .Vout_flat(Vout_flat)
    );

    // ── Q memory ─────────────────────────────────────────────
    wire [N*WIDTH-1:0] q_col_out;
    wire [N*WIDTH-1:0] vd_result_flat;  // vector_divide output → Q write

    Qmemory #(.N(N), .WIDTH(WIDTH)) qmem (
        .clk     (clk),
        .wrQ     (wrQ),
        .rdQ     (rdQ),
        .wr_addr (Vcout),
        .rd_addr (Qcout),
        .col_in  (vd_result_flat),
        .col_out (q_col_out)
    );

    // ── q register ────────────────────────────────────────────
    wire [N*WIDTH-1:0] qout_flat;

    q_reg #(.N(N), .WIDTH(WIDTH)) qreg (
        .clk      (clk),
        .ldq      (ldq),
        .q_bus    (q_col_out),
        .qout_flat(qout_flat)
    );

    // ── l2norm ────────────────────────────────────────────────
    wire signed [WIDTH-1:0] l2_norm_result;

    l2norm #(.N(N), .WIDTH(WIDTH)) l2 (
        .clk        (clk),
        .start      (start_l2),
        .Vout_flat  (Vout_flat),
        .norm_result(l2_norm_result),
        .done       (l2_done)
    );

    // ── vector_divide ─────────────────────────────────────────
    vector_divide #(.N(N), .WIDTH(WIDTH)) vd (
        .clk        (clk),
        .start      (start_vd),
        .Vout_flat  (Vout_flat),
        .norm       (l2_norm_result),
        .result_flat(vd_result_flat),
        .done       (vd_done)
    );

    // ── R memory data_in mux ──────────────────────────────────
    // ltQc=0: writing norm → R[Vc][Vc]
    // ltQc=1: writing dot product → R[Qc][Vc]
    wire signed [WIDTH-1:0] R_data_in;
    assign R_data_in = ltQc ? dp_result : l2_norm_result;

    // ── R memory ─────────────────────────────────────────────
    Rmemory #(.N(N), .WIDTH(WIDTH)) rmem (
        .clk     (clk),
        .wrR     (wrR),
        .ltQc    (ltQc),
        .Qcout   (Qcout),
        .Vcout   (Vcout),
        .data_in (R_data_in)
    );

endmodule