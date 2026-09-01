`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.04.2026 04:02:07
// Design Name: 
// Module Name: controller
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


//17 state fsm
module controller #(
    parameter N = 4
)(
    input  clk,
    input  start,
    input  ltVc,
    input  ltQc,
    input  dp_done,
    input  ss_done,
    input  l2_done,
    input  vd_done,

    // counter controls
    output reg clrVc,
    output reg incVc,
    output reg clrQc,
    output reg incQc,

    // register load controls
    output reg ldV,
    output reg ldq,
    output reg selV,

    // memory write controls
    output reg wrQ,
    output reg rdQ,
    output reg wrR,

    // computation start pulses
    output reg start_dp,
    output reg start_ss,
    output reg start_l2,
    output reg start_vd,

    // done
    output reg done
);

    // ── State encoding ────────────────────────────────────────
    localparam START    = 5'd0;
    localparam CMP_VC   = 5'd1;
    localparam LOAD_V   = 5'd2;
    localparam CMP_QC   = 5'd3;
    localparam RDQ      = 5'd4;
    localparam LDQ      = 5'd5;
    localparam START_DP = 5'd6;
    localparam WAIT_DP  = 5'd7;
    localparam WAIT_SS  = 5'd8;
    localparam WRUP_DP  = 5'd9;
    localparam INC_QC   = 5'd10;
    localparam START_L2 = 5'd11;
    localparam WAIT_L2  = 5'd12;
    localparam WAIT_VD  = 5'd13;
    localparam WRUP_L2  = 5'd14;
    localparam INC_VC   = 5'd15;
    localparam DONE     = 5'd16;

    reg [4:0] state, next_state;

    // ── State register ────────────────────────────────────────
    always @(posedge clk) begin
        if (start)
            state <= START;
        else
            state <= next_state;
    end

    // ── Next state logic ──────────────────────────────────────
    always @(*) begin
        case (state)
            START:    next_state = CMP_VC;
            CMP_VC:   next_state = ltVc    ? LOAD_V   : DONE;
            LOAD_V:   next_state = CMP_QC;
            CMP_QC:   next_state = ltQc    ? RDQ      : START_L2;
            RDQ:      next_state = LDQ;
            LDQ:      next_state = START_DP;
            START_DP: next_state = WAIT_DP;
            WAIT_DP:  next_state = dp_done ? WAIT_SS  : WAIT_DP;
            WAIT_SS:  next_state = ss_done ? WRUP_DP   : WAIT_SS;
            WRUP_DP:  next_state = INC_QC;
            INC_QC:   next_state = CMP_QC;
            START_L2: next_state = WAIT_L2;
            WAIT_L2:  next_state = l2_done ? WAIT_VD  : WAIT_L2;
            WAIT_VD:  next_state = vd_done ? WRUP_L2   : WAIT_VD;
            WRUP_L2:  next_state = INC_VC;
            INC_VC:   next_state = CMP_VC;
            DONE:     next_state = DONE;
            default:  next_state = START;
        endcase
    end

    // ── Output logic ──────────────────────────────────────────
    always @(*) begin
        // default all to 0
        clrVc    = 0;
        incVc    = 0;
        clrQc    = 0;
        incQc    = 0;
        ldV      = 0;
        ldq      = 0;
        selV     = 0;
        wrQ      = 0;
        rdQ      = 0;
        wrR      = 0;
        start_dp = 0;
        start_ss = 0;
        start_l2 = 0;
        start_vd = 0;
        done     = 0;

        case (state)
            START: begin
                clrVc = 1;
            end

            CMP_VC: begin
                // ltVc evaluated
            end

            LOAD_V: begin
                ldV   = 1;
                selV  = 0;
                clrQc = 1;
            end

            CMP_QC: begin
                // ltQc evaluated
            end

            RDQ: begin
                rdQ = 1;
            end

            LDQ: begin
                ldq = 1;
            end

            START_DP: begin
                start_dp = 1;
            end

            WAIT_DP: begin
                start_ss = dp_done ? 1 : 0;
            end

            WAIT_SS: begin
                // waiting for ss_done
            end

            WRUP_DP: begin
                wrR  = 1;
                ldV  = 1;
                selV = 1;
            end

            INC_QC: begin
                incQc = 1;
            end

            START_L2: begin
                start_l2 = 1;
            end

            WAIT_L2: begin
                start_vd = l2_done ? 1 : 0;
            end

            WAIT_VD: begin
                // waiting for vd_done
            end

            WRUP_L2: begin
                wrR = 1;
                wrQ = 1;
            end

            INC_VC: begin
                incVc = 1;
            end

            DONE: begin
                done = 1;
            end
        endcase
    end

endmodule

/*
//19 state fsm 375 cycles
module controller #(
    parameter N = 4
)(
    input  clk,
    input  start,
    input  ltVc,
    input  ltQc,
    input  dp_done,
    input  ss_done,
    input  l2_done,
    input  vd_done,

    // counter controls
    output reg clrVc,
    output reg incVc,
    output reg clrQc,
    output reg incQc,

    // register load controls
    output reg ldV,
    output reg ldq,
    output reg selV,

    // memory write controls
    output reg wrQ,
    output reg rdQ,
    output reg wrR,

    // computation start pulses
    output reg start_dp,
    output reg start_ss,
    output reg start_l2,
    output reg start_vd,

    // done
    output reg done
);

    // ── State encoding ────────────────────────────────────────
    localparam START    = 5'd0;
    localparam CMP_VC   = 5'd1;
    localparam LOAD_V   = 5'd2;
    localparam CMP_QC   = 5'd3;
    localparam RDQ      = 5'd4;
    localparam LDQ      = 5'd5;
    localparam START_DP = 5'd6;
    localparam WAIT_DP  = 5'd7;
    localparam START_SS = 5'd8;
    localparam WAIT_SS  = 5'd9;
    localparam WRUP_DP  = 5'd10;
    localparam INC_QC   = 5'd11;
    localparam START_L2 = 5'd12;
    localparam WAIT_L2  = 5'd13;
    localparam START_VD = 5'd14;
    localparam WAIT_VD  = 5'd15;
    localparam WRUP_L2  = 5'd16;
    localparam INC_VC   = 5'd17;
    localparam DONE     = 5'd18;

    reg [4:0] state, next_state;

    // ── State register ────────────────────────────────────────
    always @(posedge clk) begin
        if (start)
            state <= START;
        else
            state <= next_state;
    end

    // ── Next state logic ──────────────────────────────────────
    always @(*) begin
        case (state)
            START:    next_state = CMP_VC;
            CMP_VC:   next_state = ltVc    ? LOAD_V   : DONE;
            LOAD_V:   next_state = CMP_QC;
            CMP_QC:   next_state = ltQc    ? RDQ      : START_L2;
            RDQ:      next_state = LDQ;
            LDQ:      next_state = START_DP;
            START_DP: next_state = WAIT_DP;
            WAIT_DP:  next_state = dp_done ? START_SS  : WAIT_DP;
            START_SS: next_state = WAIT_SS;
            WAIT_SS:  next_state = ss_done ? WRUP_DP   : WAIT_SS;
            WRUP_DP:  next_state = INC_QC;
            INC_QC:   next_state = CMP_QC;
            START_L2: next_state = WAIT_L2;
            WAIT_L2:  next_state = l2_done ? START_VD  : WAIT_L2;
            START_VD: next_state = WAIT_VD;
            WAIT_VD:  next_state = vd_done ? WRUP_L2   : WAIT_VD;
            WRUP_L2:  next_state = INC_VC;
            INC_VC:   next_state = CMP_VC;
            DONE:     next_state = DONE;
            default:  next_state = START;
        endcase
    end

    // ── Output logic ──────────────────────────────────────────
    always @(*) begin
        // default all to 0
        clrVc    = 0;
        incVc    = 0;
        clrQc    = 0;
        incQc    = 0;
        ldV      = 0;
        ldq      = 0;
        selV     = 0;
        wrQ      = 0;
        rdQ      = 0;
        wrR      = 0;
        start_dp = 0;
        start_ss = 0;
        start_l2 = 0;
        start_vd = 0;
        done     = 0;

        case (state)
            START: begin
                clrVc = 1;
            end

            CMP_VC: begin
                // ltVc evaluated
            end

            LOAD_V: begin
                ldV   = 1;
                selV  = 0;
                clrQc = 1;
            end

            CMP_QC: begin
                // ltQc evaluated
            end

            RDQ: begin
                rdQ = 1;
            end

            LDQ: begin
                ldq = 1;
            end

            START_DP: begin
                start_dp = 1;
            end

            WAIT_DP: begin
                // waiting for dp_done
            end

            START_SS: begin
                start_ss = 1;
            end

            WAIT_SS: begin
                // waiting for ss_done
            end

            WRUP_DP: begin
                wrR  = 1;
                ldV  = 1;
                selV = 1;
            end

            INC_QC: begin
                incQc = 1;
            end

            START_L2: begin
                start_l2 = 1;
            end

            WAIT_L2: begin
                // waiting for l2_done
            end

            START_VD: begin
                start_vd = 1;
            end

            WAIT_VD: begin
                // waiting for vd_done
            end

            WRUP_L2: begin
                wrR = 1;
                wrQ = 1;
            end

            INC_VC: begin
                incVc = 1;
            end

            DONE: begin
                done = 1;
            end
        endcase
    end

endmodule */
