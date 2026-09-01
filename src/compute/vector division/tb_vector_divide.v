`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 22:22:00
// Design Name: 
// Module Name: tb_vector_divide
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

module tb_vector_divide;

    parameter N     = 4;
    parameter WIDTH = 32;

    reg                     clk;
    reg                     start;
    reg  [N*WIDTH-1:0]      Vout_flat;
    reg  signed [WIDTH-1:0] norm;
    wire [N*WIDTH-1:0]      result_flat;
    wire                    done;

    // Unpack result for checking
    wire signed [WIDTH-1:0] result [N-1:0];
    genvar k;
    generate
        for (k=0; k<N; k=k+1) begin : unpack_result
            assign result[k] = result_flat[(k+1)*WIDTH-1 -: WIDTH];
        end
    endgenerate

    vector_divide #(
        .N(N),
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .start(start),
        .Vout_flat(Vout_flat),
        .norm(norm),
        .result_flat(result_flat),
        .done(done)
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
        input real V0, V1, V2, V3;
        input real norm_val;
        input real exp0, exp1, exp2, exp3;
        begin
            @(negedge clk);
            Vout_flat = {toQ(V3), toQ(V2), toQ(V1), toQ(V0)};
            norm = toQ(norm_val);
            start = 1;
            
            $display("");
            $display("==========================================");
            $display("  Norm = %f", norm_val);
            $display("  V = [%f, %f, %f, %f]", V0, V1, V2, V3);
            $display("  Expected = [%f, %f, %f, %f]", exp0, exp1, exp2, exp3);
            
            @(posedge clk);
            #1;
            start = 0;
            
            @(posedge done);
            #1;
            
            $display("");
            $display("--- RESULTS ---");
            $display("  result[0] = %h (%f) [expected %f]", 
                     result[0], fromQ(result[0]), exp0);
            $display("  result[1] = %h (%f) [expected %f]", 
                     result[1], fromQ(result[1]), exp1);
            $display("  result[2] = %h (%f) [expected %f]", 
                     result[2], fromQ(result[2]), exp2);
            $display("  result[3] = %h (%f) [expected %f]", 
                     result[3], fromQ(result[3]), exp3);
            $display("==========================================");
        end
    endtask

    initial begin
        clk = 0;
        start = 0;
        Vout_flat = 0;
        norm = 0;
        
        #10;
        
        $display("==========================================");
        $display("     VECTOR DIVIDE TESTBENCH");
        $display("==========================================");
        
        // Test 1: Simple integer vector
        run_test(10.0, 20.0, 30.0, 40.0, 
                 2.0,
                 5.0, 10.0, 15.0, 20.0);
        
        // Test 2: Vector with fractions
        run_test(1.5, 2.5, 3.5, 4.5,
                 2.0,
                 0.75, 1.25, 1.75, 2.25);
        
        // Test 3: Negative vector
        run_test(-10.0, -20.0, -30.0, -40.0,
                 2.0,
                 -5.0, -10.0, -15.0, -20.0);
        
        // Test 4: Mixed signs
        run_test(10.0, -20.0, 30.0, -40.0,
                 2.0,
                 5.0, -10.0, 15.0, -20.0);
        
        // Test 5: Realistic QR scenario (Q = V / norm)
        run_test(13.86, -7.23, 5.44, -2.91,
                 16.8058,
                 13.86/16.8058, -7.23/16.8058, 5.44/16.8058, -2.91/16.8058);
        
        // Test 6: Small numbers
        run_test(0.5, 0.5, 0.5, 0.5,
                 1.0,
                 0.5, 0.5, 0.5, 0.5);
        
        // Test 7: Large numbers
        run_test(30000.0, 30000.0, 30000.0, 30000.0,
                 2.0,
                 15000.0, 15000.0, 15000.0, 15000.0);
        
        $display("");
        $display("==========================================");
        $display("     ALL TESTS COMPLETED");
        $display("==========================================");
        
        #1000;
        $finish;
    end

endmodule
