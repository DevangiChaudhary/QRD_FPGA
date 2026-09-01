`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 14:39:42
// Design Name: 
// Module Name: tb_sqrt_cordic
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


module tb_sqrt_cordic;

    parameter WIDTH = 32;

    reg                     clk;
    reg                     start;
    reg  [WIDTH-1:0]        radicand;
    wire signed [WIDTH-1:0] result;
    wire                    done;

    sqrt_cordic #(
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .start(start),
        .radicand(radicand),
        .result(result),
        .done(done)
    );

    always #5 clk = ~clk;

    function [31:0] toQ;
        input real val;
        reg signed [31:0] scaled;
        begin
            scaled = $rtoi(val * 65536.0);
            toQ    = scaled;
        end
    endfunction

    function real fromQ;
        input [31:0] val;
        begin
            fromQ = $itor($signed(val)) / 65536.0;
        end
    endfunction

    // input values
    real inputs [0:9];
    real expected [0:9];
    integer idx;

    // print when done fires
    always @(posedge clk) begin
        if (done) begin
            $display("done=1 result=%h (decimal: %f)", result, fromQ(result));
        end
    end

    initial begin
        clk   = 0;
        start = 0;
        radicand = 0;

        // define 10 inputs and their expected sqrt
        inputs[0] = 1.0;     expected[0] = 1.0;
        inputs[1] = 4.0;     expected[1] = 2.0;
        inputs[2] = 9.0;     expected[2] = 3.0;
        inputs[3] = 2.0;     expected[3] = 1.41421;
        inputs[4] = 0.25;    expected[4] = 0.5;
        inputs[5] = 3.75;    expected[5] = 1.93649;
        inputs[6] = 0.5;     expected[6] = 0.70710;
        inputs[7] = 100.0;   expected[7] = 10.0;
        inputs[8] = 0.0625;  expected[8] = 0.25;
        inputs[9] = 282.4342; expected[9] = 16.8058;

        #10;

        // send all 10 inputs one per cycle
        $display("Sending 10 inputs one per cycle:");
        for (idx = 0; idx < 10; idx = idx + 1) begin
            @(negedge clk);
            radicand = toQ(inputs[idx]);
            start    = 1;
            $display("  cycle input[%0d] = %f (hex: %h) expected sqrt = %f",
                idx, inputs[idx], toQ(inputs[idx]), expected[idx]);
            @(posedge clk);
            #1;
            start = 0;
        end

        $display("");
        $display("Waiting for results:");

        // wait long enough for all results to come out
        // 10 inputs + 17 cycle latency = 27 cycles
        repeat(30) @(posedge clk);

        $display("Done.");
        $finish;
    end

endmodule
