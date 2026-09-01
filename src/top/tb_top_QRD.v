`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.04.2026 04:12:41
// Design Name: 
// Module Name: tb_top_QRD
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


/*module tb_top_QRD;

    // ── DUT signals ────────────────────────────────────────────
    reg  clk;
    reg  start;
    wire done;

    // ── Clock generation ───────────────────────────────────────
    initial clk = 0;
    always #5 clk = ~clk;

    // ── DUT instantiation ──────────────────────────────────────
    top_QRD #(.N(4), .WIDTH(32)) dut (
        .clk   (clk),
        .start (start),
        .done  (done)
    );

    // ── Q16.16 to float conversion function ───────────────────
    function real q16_to_real;
        input [31:0] val;
        reg signed [31:0] signed_val;
        begin
            signed_val  = val;
            q16_to_real = $itor(signed_val) / 65536.0;
        end
    endfunction

    // ── State name function ────────────────────────────────────
    function [80*8-1:0] state_name;
        input [3:0] s;
        begin
            case (s)
                4'd0:  state_name = "START   ";
                4'd1:  state_name = "CMP_VC  ";
                4'd2:  state_name = "LOAD_V  ";
                4'd3:  state_name = "CMP_QC  ";
                4'd4:  state_name = "RDQ     ";
                4'd5:  state_name = "LDQ     ";
                4'd6:  state_name = "START_DP";
                4'd7:  state_name = "WAIT_DP ";
                4'd8:  state_name = "WRUP_DP ";
                4'd9:  state_name = "INC_QC  ";
                4'd10: state_name = "START_L2";
                4'd11: state_name = "WAIT_L2 ";
                4'd12: state_name = "WRUP_L2 ";
                4'd13: state_name = "INC_VC  ";
                4'd14: state_name = "DONE    ";
                default: state_name = "UNKNOWN ";
            endcase
        end
    endfunction

    // ── General state monitor ──────────────────────────────────
    always @(posedge clk) begin
        $display("t=%0t | state=%s | Vc=%0d | Qc=%0d | ltVc=%b | ltQc=%b | l2_done=%b | dp_done=%b | ldV=%b | selV=%b | wrR=%b | wrQ=%b | rdQ=%b | ldq=%b",
            $time,
            state_name(tb_top_QRD.dut.ctrl.state),
            tb_top_QRD.dut.dp.Vcout,
            tb_top_QRD.dut.dp.Qcout,
            tb_top_QRD.dut.dp.ltVc,
            tb_top_QRD.dut.dp.ltQc,
            tb_top_QRD.dut.dp.l2_done,
            tb_top_QRD.dut.dp.dp_done,
            tb_top_QRD.dut.dp.ldV,
            tb_top_QRD.dut.dp.selV,
            tb_top_QRD.dut.dp.wrR,
            tb_top_QRD.dut.dp.wrQ,
            tb_top_QRD.dut.dp.rdQ,
            tb_top_QRD.dut.dp.ldq
        );
    end

    // ── START_DP trigger monitor ───────────────────────────────
    always @(posedge clk) begin
        if (tb_top_QRD.dut.ctrl.state == 4'd6) begin
            $display("──────────────────────────────────────────");
            $display("START_DP: Vc=%0d Qc=%0d",
                tb_top_QRD.dut.dp.Vcout,
                tb_top_QRD.dut.dp.Qcout);
            $display("  V  = %h", tb_top_QRD.dut.dp.Vout_flat);
            $display("  q  = %h", tb_top_QRD.dut.dp.qout_flat);
            $display("──────────────────────────────────────────");
        end
    end

    // ── WAIT_DP done monitor ───────────────────────────────────
    always @(posedge clk) begin
        if (tb_top_QRD.dut.ctrl.state == 4'd7 && 
            tb_top_QRD.dut.dp.dp_done) begin
            $display("──────────────────────────────────────────");
            $display("DP_DONE: Vc=%0d Qc=%0d",
                tb_top_QRD.dut.dp.Vcout,
                tb_top_QRD.dut.dp.Qcout);
            $display("  dp_result = %h  (%f)",
                tb_top_QRD.dut.dp.dp_result_flat,
                q16_to_real(tb_top_QRD.dut.dp.dp_Rval));
            $display("  dp_Rval   = %h  (%f)",
                tb_top_QRD.dut.dp.dp_Rval,
                q16_to_real(tb_top_QRD.dut.dp.dp_Rval));
            $display("──────────────────────────────────────────");
        end
    end

    // ── WRUP_DP monitor ───────────────────────────────────────
    always @(posedge clk) begin
        if (tb_top_QRD.dut.ctrl.state == 4'd8) begin
            $display("──────────────────────────────────────────");
            $display("WRUP_DP: Vc=%0d Qc=%0d",
                tb_top_QRD.dut.dp.Vcout,
                tb_top_QRD.dut.dp.Qcout);
            $display("  writing R[%0d][%0d] = %h (%f)",
                tb_top_QRD.dut.dp.Qcout,
                tb_top_QRD.dut.dp.Vcout,
                tb_top_QRD.dut.dp.dp_Rval,
                q16_to_real(tb_top_QRD.dut.dp.dp_Rval));
            $display("  new V (dp_result_flat) = %h",
                tb_top_QRD.dut.dp.dp_result_flat);
            $display("──────────────────────────────────────────");
        end
    end

    // ── START_L2 trigger monitor ───────────────────────────────
    always @(posedge clk) begin
        if (tb_top_QRD.dut.ctrl.state == 4'd10) begin
            $display("──────────────────────────────────────────");
            $display("START_L2: Vc=%0d",
                tb_top_QRD.dut.dp.Vcout);
            $display("  V = %h", tb_top_QRD.dut.dp.Vout_flat);
            $display("──────────────────────────────────────────");
        end
    end

    // ── WAIT_L2 done monitor ───────────────────────────────────
    always @(posedge clk) begin
        if (tb_top_QRD.dut.ctrl.state == 4'd11 && 
            tb_top_QRD.dut.dp.l2_done) begin
            $display("──────────────────────────────────────────");
            $display("L2_DONE: Vc=%0d",
                tb_top_QRD.dut.dp.Vcout);
            $display("  norm  = %h (%f)",
                tb_top_QRD.dut.dp.l2_Rval,
                q16_to_real(tb_top_QRD.dut.dp.l2_Rval));
            $display("  Qcol  = %h",
                tb_top_QRD.dut.dp.l2_Qout);
            $display("──────────────────────────────────────────");
        end
    end

    // ── WRUP_L2 monitor ───────────────────────────────────────
    always @(posedge clk) begin
        if (tb_top_QRD.dut.ctrl.state == 4'd12) begin
            $display("──────────────────────────────────────────");
            $display("WRUP_L2: Vc=%0d",
                tb_top_QRD.dut.dp.Vcout);
            $display("  writing R[%0d][%0d] = %h (%f)",
                tb_top_QRD.dut.dp.Vcout,
                tb_top_QRD.dut.dp.Vcout,
                tb_top_QRD.dut.dp.l2_Rval,
                q16_to_real(tb_top_QRD.dut.dp.l2_Rval));
            $display("  writing Q[%0d] = %h",
                tb_top_QRD.dut.dp.Vcout,
                tb_top_QRD.dut.dp.l2_Qout);
            $display("──────────────────────────────────────────");
        end
    end

    // ── Stimulus ───────────────────────────────────────────────
    initial begin
        start = 0;

        // hold start for 2 cycles
        @(posedge clk); #1;
        start = 1;
        @(posedge clk);
        @(posedge clk); #1;
        start = 0;

        $display("══════════════════════════════════════════");
        $display("Simulation started, waiting for done...");
        $display("══════════════════════════════════════════");

        @(posedge done);
        repeat(3) @(posedge clk);

        // ── Final Q matrix dump ────────────────────────────────
        $display("══════════════════════════════════════════");
        $display("Q MATRIX (Q16.16 decoded to float):");
        $display("══════════════════════════════════════════");
        begin : dump_Q
            integer r, c;
            reg [31:0] entry;
            for (c = 0; c < 4; c = c + 1)
                for (r = 0; r < 4; r = r + 1) begin
                    entry = tb_top_QRD.dut.dp.qmem.Q[c][(r+1)*32-1 -: 32];
                    $display("  Q[%0d][%0d] = %f  (hex: %08h)",
                        r, c, q16_to_real(entry), entry);
                end
        end

        // ── Final R matrix dump ────────────────────────────────
        $display("══════════════════════════════════════════");
        $display("R MATRIX (Q16.16 decoded to float):");
        $display("══════════════════════════════════════════");
        begin : dump_R
            integer r, c;
            reg [31:0] entry;
            for (r = 0; r < 4; r = r + 1)
                for (c = 0; c < 4; c = c + 1) begin
                    entry = tb_top_QRD.dut.dp.rmem.R[r][c];
                    $display("  R[%0d][%0d] = %f  (hex: %08h)",
                        r, c, q16_to_real(entry), entry);
                end
        end

        // ── Expected values ────────────────────────────────────
        $display("══════════════════════════════════════════");
        $display("EXPECTED Q:");
        $display("══════════════════════════════════════════");
        $display("  Q[0][0]=0.182574  Q[0][1]=0.816497  Q[0][2]=0.000000  Q[0][3]=0.683130");
        $display("  Q[1][0]=0.365148  Q[1][1]=0.408248  Q[1][2]=-0.154303 Q[1][3]=-0.585540");
        $display("  Q[2][0]=0.547723  Q[2][1]=0.000000  Q[2][2]=0.617213  Q[2][3]=-0.390360");
        $display("  Q[3][0]=0.730297  Q[3][1]=-0.408248 Q[3][2]=-0.771517 Q[3][3]=-0.195180");
        $display("══════════════════════════════════════════");
        $display("EXPECTED R:");
        $display("══════════════════════════════════════════");
        $display("  R[0][0]=5.477226  R[0][1]=7.302967  R[0][2]=9.128709  R[0][3]=11.684748");
        $display("  R[1][0]=0.000000  R[1][1]=0.816497  R[1][2]=1.632993  R[1][3]=2.041241");
        $display("  R[2][0]=0.000000  R[2][1]=0.000000  R[2][2]=0.000000  R[2][3]=-0.462910");
        $display("  R[3][0]=0.000000  R[3][1]=0.000000  R[3][2]=0.000000  R[3][3]=0.292770");

        $display("══════════════════════════════════════════");
        $display("Simulation complete at t=%0t", $time);
        $display("══════════════════════════════════════════");
        $finish;
    end

    // ── Timeout watchdog ──────────────────────────────────────
    initial begin
        #5000000;
        $display("TIMEOUT: simulation did not complete");
        $finish;
    end

endmodule*/

//normal tb with just results
/*module tb_top_QRD;

    // ── DUT signals ────────────────────────────────────────────
    reg  clk;
    reg  start;
    wire done;

    // ── Clock generation ───────────────────────────────────────
    initial clk = 0;
    always #5 clk = ~clk;

    // ── DUT instantiation ──────────────────────────────────────
    top_QRD #(.N(4), .WIDTH(32)) dut (
        .clk   (clk),
        .start (start),
        .done  (done)
    );

    // ── Q16.16 to real ─────────────────────────────────────────
    function real q16_to_real;
        input [31:0] val;
        reg signed [31:0] s;
        begin
            s = val;
            q16_to_real = $itor(s) / 65536.0;
        end
    endfunction

    // ── Expected values ────────────────────────────────────────
    real Q_exp [0:3][0:3];
    real R_exp [0:3][0:3];

    task load_expected;
        begin
            Q_exp[0][0]= 0.104214; Q_exp[0][1]= 0.238554; Q_exp[0][2]= 0.923847; Q_exp[0][3]=-0.280605;
            Q_exp[1][0]= 0.460278; Q_exp[1][1]= 0.548721; Q_exp[1][2]=-0.372806; Q_exp[1][3]=-0.589970;
            Q_exp[2][0]= 0.790289; Q_exp[2][1]=-0.608699; Q_exp[2][2]= 0.069923; Q_exp[2][3]= 0.006236;
            Q_exp[3][0]= 0.390802; Q_exp[3][1]= 0.521039; Q_exp[3][2]= 0.051323; Q_exp[3][3]= 0.757072;

            R_exp[0][0]=11.514773; R_exp[0][1]= 6.209415; R_exp[0][2]= 8.037501; R_exp[0][3]= 9.844745;
            R_exp[1][0]= 0.000000; R_exp[1][1]= 6.090416; R_exp[1][2]= 6.750249; R_exp[1][3]= 7.362370;
            R_exp[2][0]= 0.000000; R_exp[2][1]= 0.000000; R_exp[2][2]= 0.814077; R_exp[2][3]= 1.443385;
            R_exp[3][0]= 0.000000; R_exp[3][1]= 0.000000; R_exp[3][2]= 0.000000; R_exp[3][3]= 0.056121;
        end
    endtask

    // ── Display results ────────────────────────────────────────
    task display_results;
        integer r, c;
        real got, exp, err;
        reg [31:0] entry;
        begin
            $display("════════════════════════════════════════════════════════════════");
            $display("Q MATRIX:  got value    |  expected   |  error");
            $display("════════════════════════════════════════════════════════════════");
            for (c = 0; c < 4; c = c + 1) begin
                for (r = 0; r < 4; r = r + 1) begin
                    entry = tb_top_QRD.dut.dp.qmem.Q[c][(r+1)*32-1 -: 32];
                    got   = q16_to_real(entry);
                    exp   = Q_exp[r][c];
                    err   = got - exp;
                    if (err < 0) err = -err;
                    $display("  Q[%0d][%0d]   %10.6f  |  %10.6f  |  %10.6f", r, c, got, exp, err);
                end
            end

            $display("════════════════════════════════════════════════════════════════");
            $display("R MATRIX:  got value    |  expected   |  error");
            $display("════════════════════════════════════════════════════════════════");
            for (r = 0; r < 4; r = r + 1) begin
                for (c = 0; c < 4; c = c + 1) begin
                    entry = tb_top_QRD.dut.dp.rmem.R[r][c];
                    got   = q16_to_real(entry);
                    exp   = R_exp[r][c];
                    err   = got - exp;
                    if (err < 0) err = -err;
                    $display("  R[%0d][%0d]   %10.6f  |  %10.6f  |  %10.6f", r, c, got, exp, err);
                end
            end
            $display("════════════════════════════════════════════════════════════════");
        end
    endtask

    // ── Stimulus ───────────────────────────────────────────────
    initial begin
        load_expected;
        start = 0;

        @(posedge clk); #1;
        start = 1;
        @(posedge clk);
        @(posedge clk); #1;
        start = 0;

        $display("Waiting for done...");
        @(posedge done);
        repeat(3) @(posedge clk);

        display_results;

        $display("Simulation complete at t=%0t", $time);
        $finish;
    end

    // ── Timeout watchdog ──────────────────────────────────────
    initial begin
        #10000000;
        $display("TIMEOUT");
        $finish;
    end

endmodule*/


//tb to show step by step
module tb_top_QRD;

    reg  clk;
    reg  start;
    wire done;

    initial clk = 0;
    always #5 clk = ~clk;

    top_QRD #(.N(4), .WIDTH(32)) dut (
        .clk   (clk),
        .start (start),
        .done  (done)
    );

    // ── Q12.20 to real ─────────────────────────────────────────
    function real q16_to_real;
        input [31:0] val;
        reg signed [31:0] s;
        begin
            s = val;
            q16_to_real = $itor(s) / 1048576.0;
        end
    endfunction

    // ── Print vector V ─────────────────────────────────────────
    task print_V;
        input [127:0] V;
        begin
            $display("      V = [%f, %f, %f, %f]",
                q16_to_real(V[31:0]),
                q16_to_real(V[63:32]),
                q16_to_real(V[95:64]),
                q16_to_real(V[127:96]));
        end
    endtask

    // ── Print vector q ─────────────────────────────────────────
    task print_q;
        input [127:0] q;
        begin
            $display("      q = [%f, %f, %f, %f]",
                q16_to_real(q[31:0]),
                q16_to_real(q[63:32]),
                q16_to_real(q[95:64]),
                q16_to_real(q[127:96]));
        end
    endtask

    // ── Print Q column ─────────────────────────────────────────
    task print_Qcol;
        input [127:0] Qcol;
        input integer col;
        begin
            $display("      Q[*][%0d] = [%f, %f, %f, %f]",
                col,
                q16_to_real(Qcol[31:0]),
                q16_to_real(Qcol[63:32]),
                q16_to_real(Qcol[95:64]),
                q16_to_real(Qcol[127:96]));
        end
    endtask

    // ── Stepwise monitor ───────────────────────────────────────
    always @(posedge clk) begin

        // ── New Vc iteration starting ──────────────────────────
        if (tb_top_QRD.dut.ctrl.state == 5'd2) begin  // LOAD_V
            $display("");
            $display("--------------------------------------------------------");
            $display("  Vc = %0d  :  Loading column %0d from A matrix",
                tb_top_QRD.dut.dp.Vcout,
                tb_top_QRD.dut.dp.Vcout);
            $display("--------------------------------------------------------");
            print_V(tb_top_QRD.dut.dp.A_col);
        end

        // ── Qc iteration starting ──────────────────────────────
        if (tb_top_QRD.dut.ctrl.state == 5'd4) begin  // RDQ
            $display("");
            $display("--------------------------------------------------------");
            $display("    Qc = %0d  :  Reading Q[*][%0d] from Q memory",
                tb_top_QRD.dut.dp.Qcout,
                tb_top_QRD.dut.dp.Qcout);
            $display("--------------------------------------------------------");
        end

        // ── q loaded into q_reg ────────────────────────────────
        if (tb_top_QRD.dut.ctrl.state == 5'd5) begin  // LDQ
            print_q(tb_top_QRD.dut.dp.q_col_out);
        end

        // ── dot product done ───────────────────────────────────
        if (tb_top_QRD.dut.ctrl.state == 5'd7 &&
            tb_top_QRD.dut.dp.dp_done) begin  // WAIT_DP
            $display("      Dot product  →  R[%0d][%0d] = %f",
                tb_top_QRD.dut.dp.Qcout,
                tb_top_QRD.dut.dp.Vcout,
                q16_to_real(tb_top_QRD.dut.dp.dp_result));
        end

        // ── scal_sub done, V updated ───────────────────────────
        if (tb_top_QRD.dut.ctrl.state == 5'd10) begin  // WRUP_DP
            $display("      Scalar subtract  →  V = V - R[%0d][%0d] * q",
                tb_top_QRD.dut.dp.Qcout,
                tb_top_QRD.dut.dp.Vcout);
            print_V(tb_top_QRD.dut.dp.ss_result_flat);
        end

        // ── l2norm done ────────────────────────────────────────
        if (tb_top_QRD.dut.ctrl.state == 5'd13 &&
            tb_top_QRD.dut.dp.l2_done) begin  // WAIT_L2
            $display("");
            $display("      L2 Norm  →  R[%0d][%0d] = %f",
                tb_top_QRD.dut.dp.Vcout,
                tb_top_QRD.dut.dp.Vcout,
                q16_to_real(tb_top_QRD.dut.dp.l2_norm_result));
        end

        // ── vector divide done, Q column written ──────────────
        if (tb_top_QRD.dut.ctrl.state == 5'd15 &&
            tb_top_QRD.dut.dp.vd_done) begin  // WAIT_VD
            $display("      Vector divide  →  Q column %0d = V / R[%0d][%0d]",
                tb_top_QRD.dut.dp.Vcout,
                tb_top_QRD.dut.dp.Vcout,
                tb_top_QRD.dut.dp.Vcout);
            print_Qcol(tb_top_QRD.dut.dp.vd_result_flat,
                       tb_top_QRD.dut.dp.Vcout);
        end

    end

    // ── Final results ──────────────────────────────────────────
    task display_final;
        integer r, c;
        reg [31:0] entry;
        begin
            $display("");
            $display("--------------------------------------------------------");
            $display("                 FINAL RESULTS                     ");
            $display("--------------------------------------------------------");

            $display("Q MATRIX:");
            for (c = 0; c < 4; c = c + 1) begin
                for (r = 0; r < 4; r = r + 1) begin
                    entry = tb_top_QRD.dut.dp.qmem.Q[c][(r+1)*32-1 -: 32];
                    $display("  Q[%0d][%0d] = %f", r, c, q16_to_real(entry));
                end
            end

            $display("R MATRIX:");
            for (r = 0; r < 4; r = r + 1) begin
                for (c = 0; c < 4; c = c + 1) begin
                    entry = tb_top_QRD.dut.dp.rmem.R[r][c];
                    $display("  R[%0d][%0d] = %f", r, c, q16_to_real(entry));
                end
            end
        end
    endtask

    // ── Stimulus ───────────────────────────────────────────────
    initial begin
        start = 0;

        @(posedge clk); #1;
        start = 1;
        @(posedge clk);
        @(posedge clk); #1;
        start = 0;

        $display("--------------------------------------------------------");
        $display("           QRD DECOMPOSITION  —  STEP BY STEP        ");
        $display("--------------------------------------------------------");

        @(posedge done);
        repeat(3) @(posedge clk);

        display_final;

        $display("");
        $display("Simulation complete at t=%0t", $time);
        $finish;
    end

    // ── Timeout ────────────────────────────────────────────────
    initial begin
        #10000000;
        $display("TIMEOUT");
        $finish;
    end

endmodule
