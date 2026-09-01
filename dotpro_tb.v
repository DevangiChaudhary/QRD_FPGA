`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 00:30:51
// Design Name: 
// Module Name: dotpro_tb
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

module dotpro_tb();
    parameter N     = 4;
    parameter WIDTH = 32;

    reg                     clk;
    reg                     start;
    reg  [N*WIDTH-1:0]      Vout_flat;
    reg  [N*WIDTH-1:0]      qout_flat;
    wire signed [WIDTH-1:0] result;
    wire                    done;

    dot_product #(
        .N(N),
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .start(start),
        .Vout_flat(Vout_flat),
        .qout_flat(qout_flat),
        .result(result),
        .done(done)
    );

    always #5 clk = ~clk;

    task run_dot;
        input [N*WIDTH-1:0] V_in;
        input [N*WIDTH-1:0] q_in;
        input real          expected;
        begin
            @(negedge clk);
            Vout_flat = V_in;
            qout_flat = q_in;
            start     = 1;
            @(posedge clk);
            #1;
            start = 0;

            @(posedge done);
            #1;
            // Display the raw sum_l2 from the uut
                        $display("  Result (truncated)= %h  (decimal: %f)", result, $itor($signed(result)) / 65536.0);
            $display("  Expected          = %f", expected);
        end
    endtask

    function [31:0] real_to_q1616;
        input real val;
        begin
            real_to_q1616 = $rtoi(val * 65536.0);
        end
    endfunction

    initial begin
        clk       = 0;
        start     = 0;
        Vout_flat = 0;
        qout_flat = 0;

        #10;

        // =============================================
        // CASE 1: positive integers
        // V=[1,2,3,4] q=[1,2,3,4]
        // expected = 1+4+9+16 = 30.0
        // =============================================
        $display("CASE 1: V=[1,2,3,4] q=[1,2,3,4] expected=30.0");
        run_dot(
            {32'h00040000, 32'h00030000, 32'h00020000, 32'h00010000},
            {32'h00040000, 32'h00030000, 32'h00020000, 32'h00010000},
            30.0
        );

        // =============================================
        // CASE 2: positive and negative integers
        // V=[1,-2,3,-4] q=[1,-2,3,-4]
        // expected = 1+4+9+16 = 30.0
        // =============================================
        $display("CASE 2: V=[1,-2,3,-4] q=[1,-2,3,-4] expected=30.0");
        run_dot(
            {32'hFFFC0000, 32'h00030000, 32'hFFFE0000, 32'h00010000},
            {32'hFFFC0000, 32'h00030000, 32'hFFFE0000, 32'h00010000},
            30.0
        );

        // =============================================
        // CASE 3: mixed signs
        // V=[1,2,3,4] q=[-1,-2,-3,-4]
        // expected = -1-4-9-16 = -30.0
        // =============================================
        $display("CASE 3: V=[1,2,3,4] q=[-1,-2,-3,-4] expected=-30.0");
        run_dot(
            {32'h00040000, 32'h00030000, 32'h00020000, 32'h00010000},
            {32'hFFFC0000, 32'hFFFD0000, 32'hFFFE0000, 32'hFFFF0000},
            -30.0
        );

        // =============================================
        // CASE 4: decimal values
        // V=[1.5,2.5,3.5,4.5] q=[1.5,2.5,3.5,4.5]
        // expected = 2.25+6.25+12.25+20.25 = 41.0
        // =============================================
        $display("CASE 4: V=[1.5,2.5,3.5,4.5] q=[1.5,2.5,3.5,4.5] expected=41.0");
        run_dot(
            {32'h00048000, 32'h00038000, 32'h00028000, 32'h00018000},
            {32'h00048000, 32'h00038000, 32'h00028000, 32'h00018000},
            41.0
        );

        // =============================================
        // CASE 5: negative decimals mixed
        // V=[-1.5,-2.5,3.5,-4.5] q=[1.5,-2.5,-3.5,4.5]
        // expected = -2.25+6.25-12.25-20.25 = -28.5
        // =============================================
        $display("CASE 5: V=[-1.5,-2.5,3.5,-4.5] q=[1.5,-2.5,-3.5,4.5] expected=-28.5");
        run_dot(
            {32'hFFFB8000, 32'hFFFD8000, 32'h00038000, 32'hFFFE8000},
            {32'h00048000, 32'hFFFD8000, 32'hFFFC8000, 32'h00018000},
            -28.5
        );

        // =============================================
        // CASE 6: orthogonal vectors
        // V=[1,0,0,0] q=[0,1,0,0]
        // expected = 0.0
        // =============================================
        $display("CASE 6: orthogonal vectors expected=0.0");
        run_dot(
            {32'h00000000, 32'h00000000, 32'h00000000, 32'h00010000},
            {32'h00000000, 32'h00010000, 32'h00000000, 32'h00000000},
            0.0
        );

        // =============================================
        // CASE 7: unit vector dot with itself
        // V=[0.5,0.5,0.5,0.5] q=[0.5,0.5,0.5,0.5]
        // expected = 0.25*4 = 1.0
        // =============================================
        $display("CASE 7: V=[0.5,0.5,0.5,0.5] q=[0.5,0.5,0.5,0.5] expected=1.0");
        run_dot(
            {32'h00008000, 32'h00008000, 32'h00008000, 32'h00008000},
            {32'h00008000, 32'h00008000, 32'h00008000, 32'h00008000},
            1.0
        );

        // =============================================
        // CASE 8: realistic decimal values
        // V=[13.86, -7.23, 5.44, -2.91]
        // q=[0.567, -0.423, 0.812, -0.234]
        // expected = 13.86*0.567 + (-7.23)*(-0.423) + 5.44*0.812 + (-2.91)*(-0.234)
        //          = 7.85862 + 3.05829 + 4.41728 + 0.68094
        //          = 16.01513
        // =============================================
        $display("CASE 8: realistic values V=[13.86,-7.23,5.44,-2.91] q=[0.567,-0.423,0.812,-0.234] expected=16.01513");
        run_dot(
            {real_to_q1616(-2.91), real_to_q1616(5.44), real_to_q1616(-7.23), real_to_q1616(13.86)},
            {real_to_q1616(-0.234), real_to_q1616(0.812), real_to_q1616(-0.423), real_to_q1616(0.567)},
            16.01513
        );

        $display("Done.");
        $finish;
    end

endmodule