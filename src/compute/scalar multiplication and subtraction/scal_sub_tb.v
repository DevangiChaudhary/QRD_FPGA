`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 02:27:36
// Design Name: 
// Module Name: scal_sub_tb
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

module scal_sub_tb();

    parameter N     = 4;
    parameter WIDTH = 32;

    reg                     clk;
    reg                     start;
    reg  [N*WIDTH-1:0]      Vout_flat;
    reg  [N*WIDTH-1:0]      qout_flat;
    reg  signed [WIDTH-1:0] R_val;
    wire [N*WIDTH-1:0]      result_flat;
    wire                    done;

    scal_sub #(
        .N(N),
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .start(start),
        .Vout_flat(Vout_flat),
        .qout_flat(qout_flat),
        .R_val(R_val),
        .result_flat(result_flat),
        .done(done)
    );

    always #5 clk = ~clk;

    task run_scal_sub;
        input [N*WIDTH-1:0]      V_in;
        input [N*WIDTH-1:0]      q_in;
        input signed [WIDTH-1:0] R_in;
        input real               expected_0;
        input real               expected_1;
        input real               expected_2;
        input real               expected_3;
        integer j;
        reg signed [WIDTH-1:0] element;
        real float_val;
        begin
            @(negedge clk);
            Vout_flat = V_in;
            qout_flat = q_in;
            R_val     = R_in;
            start     = 1;
            @(posedge clk);
            #1;
            start = 0;

            @(posedge done);
            #1;
            $display("  Results:");
            for (j = 0; j < N; j = j + 1) begin
                element   = result_flat[(j+1)*WIDTH-1 -: WIDTH];
                float_val = $itor(element) / 65536.0;
                $display("    res[%0d] = %h  (decimal: %f)", j, element, float_val);
            end
            $display("  Expected: [%f, %f, %f, %f]", expected_0, expected_1, expected_2, expected_3);
            $display("");
        end
    endtask

    initial begin
        clk       = 0;
        start     = 0;
        Vout_flat = 0;
        qout_flat = 0;
        R_val     = 0;

        #10;

        // =============================================
        // CASE 1: simple positive integers
        // V=[4,3,2,1] q=[1,2,3,4] R=2.0
        // result = [4-2*1, 3-2*2, 2-2*3, 1-2*4]
        //        = [2, -1, -4, -7]
        // =============================================
        $display("CASE 1: V=[4,3,2,1] q=[1,2,3,4] R=2.0");
        run_scal_sub(
            {32'h00010000, 32'h00020000, 32'h00030000, 32'h00040000},
            {32'h00040000, 32'h00030000, 32'h00020000, 32'h00010000},
            32'h00020000,
            2.0, -1.0, -4.0, -7.0
        );

        // =============================================
        // CASE 2: negative R
        // V=[4,3,2,1] q=[1,2,3,4] R=-2.0
        // result = [4-(-2)*1, 3-(-2)*2, 2-(-2)*3, 1-(-2)*4]
        //        = [6, 7, 8, 9]
        // =============================================
        $display("CASE 2: V=[4,3,2,1] q=[1,2,3,4] R=-2.0");
        run_scal_sub(
            {32'h00010000, 32'h00020000, 32'h00030000, 32'h00040000},
            {32'h00040000, 32'h00030000, 32'h00020000, 32'h00010000},
            32'hFFFE0000,
            6.0, 7.0, 8.0, 9.0
        );

        // =============================================
        // CASE 3: negative V
        // V=[-4,-3,-2,-1] q=[1,2,3,4] R=2.0
        // result = [-4-2, -3-4, -2-6, -1-8]
        //        = [-6, -7, -8, -9]
        // =============================================
        $display("CASE 3: V=[-4,-3,-2,-1] q=[1,2,3,4] R=2.0");
        run_scal_sub(
            {32'hFFFF0000, 32'hFFFE0000, 32'hFFFD0000, 32'hFFFC0000},
            {32'h00040000, 32'h00030000, 32'h00020000, 32'h00010000},
            32'h00020000,
            -6.0, -7.0, -8.0, -9.0
        );

        // =============================================
        // CASE 4: decimal R
        // V=[4,3,2,1] q=[1,2,3,4] R=0.5
        // result = [4-0.5, 3-1.0, 2-1.5, 1-2.0]
        //        = [3.5, 2.0, 0.5, -1.0]
        // =============================================
        $display("CASE 4: V=[4,3,2,1] q=[1,2,3,4] R=0.5");
        run_scal_sub(
            {32'h00010000, 32'h00020000, 32'h00030000, 32'h00040000},
            {32'h00040000, 32'h00030000, 32'h00020000, 32'h00010000},
            32'h00008000,
            3.5, 2.0, 0.5, -1.0
        );

        // =============================================
        // CASE 5: decimal V and q
        // V=[1.5,2.5,3.5,4.5] q=[0.5,0.5,0.5,0.5] R=2.0
        // result = [1.5-1.0, 2.5-1.0, 3.5-1.0, 4.5-1.0]
        //        = [0.5, 1.5, 2.5, 3.5]
        // =============================================
        $display("CASE 5: V=[1.5,2.5,3.5,4.5] q=[0.5,0.5,0.5,0.5] R=2.0");
        run_scal_sub(
            {32'h00048000, 32'h00038000, 32'h00028000, 32'h00018000},
            {32'h00008000, 32'h00008000, 32'h00008000, 32'h00008000},
            32'h00020000,
            0.5, 1.5, 2.5, 3.5
        );

        // =============================================
        // CASE 6: R=0 result should equal V
        // =============================================
        $display("CASE 6: R=0.0 result should equal V=[4,3,2,1]");
        run_scal_sub(
            {32'h00010000, 32'h00020000, 32'h00030000, 32'h00040000},
            {32'h00040000, 32'h00030000, 32'h00020000, 32'h00010000},
            32'h00000000,
            4.0, 3.0, 2.0, 1.0
        );

        // =============================================
        // CASE 7: negative q values
        // V=[4,3,2,1] q=[-1,-2,-3,-4] R=2.0
        // result = [4-2*(-1), 3-2*(-2), 2-2*(-3), 1-2*(-4)]
        //        = [6, 7, 8, 9]
        // =============================================
        $display("CASE 7: V=[4,3,2,1] q=[-1,-2,-3,-4] R=2.0");
        run_scal_sub(
            {32'h00010000, 32'h00020000, 32'h00030000, 32'h00040000},
            {32'hFFFC0000, 32'hFFFD0000, 32'hFFFE0000, 32'hFFFF0000},
            32'h00020000,
            6.0, 7.0, 8.0, 9.0
        );

        // =============================================
        // CASE 8: realistic MGS values
        // V=[13.86,-7.23,5.44,-2.91]
        // q=[0.567,-0.423,0.812,-0.234]
        // R=15.9469 (dot product result from dotpro tb)
        // result = [V[i] - R*q[i]]
        // = [13.86-9.042, -7.23-(-6.746), 5.44-12.951, -2.91-(-3.732)]
        // = [4.818, -0.484, -7.511, 0.822]
        // =============================================
        $display("CASE 8: realistic MGS values");
        $display("V=[13.86,-7.23,5.44,-2.91] q=[0.567,-0.423,0.812,-0.234] R=15.9469");
        run_scal_sub(
            {32'hFFFD170A, 32'h000570A4, 32'hFFF8C51F, 32'h000DDC29},
            {32'hFFFFC419, 32'h0000CFDF, 32'hFFFF93B6, 32'h00009127},
            32'h000FF26A,
            4.818, -0.484, -7.511, 0.822
        );

        // =============================================
        // CASE 9: all negative values
        // V=[-1.5,-2.5,-3.5,-4.5] q=[-0.5,-0.5,-0.5,-0.5] R=-2.0
        // result = [-1.5-(-2.0)*(-0.5), -2.5-(-2.0)*(-0.5), ...]
        //        = [-1.5-1.0, -2.5-1.0, -3.5-1.0, -4.5-1.0]
        //        = [-2.5, -3.5, -4.5, -5.5]
        // =============================================
        $display("CASE 9: all negative V=[-1.5,-2.5,-3.5,-4.5] q=[-0.5,-0.5,-0.5,-0.5] R=-2.0");
        $display("expected = [-2.5, -3.5, -4.5, -5.5]");
        run_scal_sub(
            {32'hFFFB8000, 32'hFFFC8000, 32'hFFFD8000, 32'hFFFE8000},
            {32'hFFFF8000, 32'hFFFF8000, 32'hFFFF8000, 32'hFFFF8000},
            32'hFFFE0000,
            -2.5, -3.5, -4.5, -5.5
        );

        $display("Done.");
        $finish;
    end

endmodule
