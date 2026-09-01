`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 19:50:15
// Design Name: 
// Module Name: tb_division
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

module tb_division;

    parameter WIDTH = 32;

    reg                     clk;
    reg                     start;
    reg  signed [WIDTH-1:0] dividend;
    reg  signed [WIDTH-1:0] divisor;
    wire signed [WIDTH-1:0] result;
    wire                    done;
    wire                    ready;

    division #(
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .start(start),
        .dividend(dividend),
        .divisor(divisor),
        .result(result),
        .done(done),
        .ready(ready)
    );

    always #5 clk = ~clk;

    function [31:0] toQ;
        input real val;
        begin
            toQ = $rtoi(val * 65536.0);
        end
    endfunction

    function real fromQ;
        input [31:0] val;
        begin
            fromQ = $itor($signed(val)) / 65536.0;
        end
    endfunction

    task run_test;
        input real dividend_real;
        input real divisor_real;
        input real expected;
        begin
            // Wait for IP to be ready
            @(negedge clk);
            while (!ready) begin
                @(posedge clk);
                @(negedge clk);
            end
            
            // Setup inputs
            dividend = toQ(dividend_real);
            divisor = toQ(divisor_real);
            start = 1;
            
            $display("");
            $display("==========================================");
            $display("  %f / %f = %f", dividend_real, divisor_real, expected);
            $display("  Dividend Q16.16 = %h (%f)", dividend, dividend_real);
            $display("  Divisor  Q16.16 = %h (%f)", divisor, divisor_real);
            $display("  Ready before start = %b", ready);
            
            @(posedge clk);
            #1;
            start = 0;
            
            // Wait for done
            while (!done) begin
                @(posedge clk);
            end
            #1;
            
            $display("");
            $display("--- RESULT ---");
            $display("  Result = %h (%f)", result, fromQ(result));
            $display("  Expected = %f", expected);
            $display("  Error = %f", expected - fromQ(result));
            $display("==========================================");
        end
    endtask

    // Test back-to-back divisions to check handshaking
    task run_back_to_back;
        input real dividend_real1;
        input real divisor_real1;
        input real expected1;
        input real dividend_real2;
        input real divisor_real2;
        input real expected2;
        begin
            // First division
            run_test(dividend_real1, divisor_real1, expected1);
            
            // Second division immediately after
            run_test(dividend_real2, divisor_real2, expected2);
        end
    endtask

    initial begin
        clk = 0;
        start = 0;
        dividend = 0;
        divisor = 0;
        
        #10;
        
        $display("==========================================");
        $display("     DIVISION MODULE TESTBENCH");
        $display("     WITH HANDSHAKING (ready signal)");
        $display("==========================================");
        
        // Test 1: Basic integer division
        run_test(10.0, 2.0, 5.0);
        
        // Test 2: Division with remainder
        run_test(10.0, 3.0, 3.33333);
        
        // Test 3: Small fraction
        run_test(1.0, 4.0, 0.25);
        
        // Test 4: Negative dividend
        run_test(-10.0, 3.0, -3.33333);
        
        // Test 5: Negative divisor
        run_test(10.0, -3.0, -3.33333);
        
        // Test 6: Both negative
        run_test(-10.0, -3.0, 3.33333);
        
        // Test 7: Negative small fraction
        run_test(-1.0, 4.0, -0.25);
        
        // Test 8: Realistic QR case
        run_test(13.86, 16.8058, 13.86/16.8058);
        
        // Test 9: Back-to-back divisions (test handshaking)
        $display("");
        $display("==========================================");
        $display("  BACK-TO-BACK DIVISIONS TEST");
        $display("  (Testing handshaking and congestion)");
        $display("==========================================");
        run_back_to_back(10.0, 2.0, 5.0, 20.0, 4.0, 5.0);
        
        // Test 10: Multiple rapid divisions
        $display("");
        $display("==========================================");
        $display("  RAPID SUCCESSIVE DIVISIONS TEST");
        $display("==========================================");
        run_test(100.0, 10.0, 10.0);
        run_test(81.0, 9.0, 9.0);
        run_test(64.0, 8.0, 8.0);
        run_test(49.0, 7.0, 7.0);
        
        $display("");
        $display("==========================================");
        $display("     ALL TESTS COMPLETED");
        $display("==========================================");
        
        #1000;
        $finish;
    end

endmodule
