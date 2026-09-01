`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.04.2026 04:03:50
// Design Name: 
// Module Name: top_QRD
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


module top_QRD #(
    parameter N     = 4,
    parameter WIDTH = 32
)(
    input  clk,
    input  start,
    output done
);

    // ── Controller to Datapath signals ─────────────────────────
    wire clrVc;
    wire incVc;
    wire clrQc;
    wire incQc;
    wire ldV;
    wire ldq;
    wire selV;
    wire wrQ;
    wire rdQ;
    wire wrR;
    wire start_dp;
    wire start_ss;
    wire start_l2;
    wire start_vd;

    // ── Datapath to Controller signals ─────────────────────────
    wire ltVc;
    wire ltQc;
    wire dp_done;
    wire ss_done;
    wire l2_done;
    wire vd_done;

    // ── Controller instantiation ───────────────────────────────
    controller #(.N(N)) ctrl (
        .clk      (clk),
        .start    (start),
        .ltVc     (ltVc),
        .ltQc     (ltQc),
        .dp_done  (dp_done),
        .ss_done  (ss_done),
        .l2_done  (l2_done),
        .vd_done  (vd_done),
        .clrVc    (clrVc),
        .incVc    (incVc),
        .clrQc    (clrQc),
        .incQc    (incQc),
        .ldV      (ldV),
        .ldq      (ldq),
        .selV     (selV),
        .wrQ      (wrQ),
        .rdQ      (rdQ),
        .wrR      (wrR),
        .start_dp (start_dp),
        .start_ss (start_ss),
        .start_l2 (start_l2),
        .start_vd (start_vd),
        .done     (done)
    );

    // ── Datapath instantiation ─────────────────────────────────
    top_datapath #(.N(N), .WIDTH(WIDTH)) dp (
        .clk      (clk),
        .clrVc    (clrVc),
        .incVc    (incVc),
        .clrQc    (clrQc),
        .incQc    (incQc),
        .ldV      (ldV),
        .ldq      (ldq),
        .selV     (selV),
        .wrQ      (wrQ),
        .rdQ      (rdQ),
        .wrR      (wrR),
        .start_dp (start_dp),
        .start_ss (start_ss),
        .start_l2 (start_l2),
        .start_vd (start_vd),
        .ltVc     (ltVc),
        .ltQc     (ltQc),
        .dp_done  (dp_done),
        .ss_done  (ss_done),
        .l2_done  (l2_done),
        .vd_done  (vd_done)
    );

endmodule
