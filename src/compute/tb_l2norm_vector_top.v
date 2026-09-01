`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 22:37:33
// Design Name: 
// Module Name: tb_l2norm_vector_top
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

module tb_l2norm_vector_top();

    parameter N     = 4;
    parameter WIDTH = 32;

    reg                     clk;
    reg                     start;
    reg  [N*WIDTH-1:0]      Vout_flat;
    wire [N*WIDTH-1:0]      Qout_flat;
    wire signed [WIDTH-1:0] Rval_out;
    wire                    done;

    // Unpack Qout for checking
    wire signed [WIDTH-1:0] Q [N-1:0];
    genvar k;
    generate
        for (k=0; k<N; k=k+1) begin : unpack_q
            assign Q[k] = Qout_flat[(k+1)*WIDTH-1 -: WIDTH];
        end
    endgenerate

    l2norm_divide_top #(
        .N(N),
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .start(start),
        .Vout_flat(Vout_flat),
        .Qout_flat(Qout_flat),
        .Rval_out(Rval_out),
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

    // Function to calculate L2 norm of a vector
    function real l2norm;
        input real v0, v1, v2, v3;
        begin
            l2norm = $sqrt(v0*v0 + v1*v1 + v2*v2 + v3*v3);
        end
    endfunction

    task run_test;
        input real v0, v1, v2, v3;
        real norm_val;
        real expected_q0, expected_q1, expected_q2, expected_q3;
        begin
            // Calculate expected values
            norm_val = l2norm(v0, v1, v2, v3);
            expected_q0 = v0 / norm_val;
            expected_q1 = v1 / norm_val;
            expected_q2 = v2 / norm_val;
            expected_q3 = v3 / norm_val;
            
            @(negedge clk);
            Vout_flat = {toQ(v3), toQ(v2), toQ(v1), toQ(v0)};
            start = 1;
            
            $display("");
            $display("==========================================");
            $display("  Input V = [%f, %f, %f, %f]", v0, v1, v2, v3);
            $display("  Expected Norm = %f", norm_val);
            $display("  Expected Q = [%f, %f, %f, %f]", 
                     expected_q0, expected_q1, expected_q2, expected_q3);
            
            @(posedge clk);
            #1;
            start = 0;
            
            @(posedge done);
            #1;
            
            $display("");
            $display("--- RESULTS ---");
            $display("  Rval_out (Norm) = %h (%f) [expected %f]", 
                     Rval_out, fromQ(Rval_out), norm_val);
            $display("");
            $display("  Q[0] = %h (%f) [expected %f]", 
                     Q[0], fromQ(Q[0]), expected_q0);
            $display("  Q[1] = %h (%f) [expected %f]", 
                     Q[1], fromQ(Q[1]), expected_q1);
            $display("  Q[2] = %h (%f) [expected %f]", 
                     Q[2], fromQ(Q[2]), expected_q2);
            $display("  Q[3] = %h (%f) [expected %f]", 
                     Q[3], fromQ(Q[3]), expected_q3);
            $display("");
            $display("  Norm Error = %f", norm_val - fromQ(Rval_out));
            $display("  Q[0] Error = %f", expected_q0 - fromQ(Q[0]));
            $display("  Q[1] Error = %f", expected_q1 - fromQ(Q[1]));
            $display("  Q[2] Error = %f", expected_q2 - fromQ(Q[2]));
            $display("  Q[3] Error = %f", expected_q3 - fromQ(Q[3]));
            $display("==========================================");
        end
    endtask

    initial begin
        clk = 0;
        start = 0;
        Vout_flat = 0;
        
        #10;
        
        $display("==========================================");
        $display("  L2NORM + VECTOR DIVIDE TOP MODULE");
        $display("==========================================");
        
        // Test 1: Simple integer vector
        run_test(10.0, 20.0, 30.0, 40.0);
        
        // Test 2: Vector with fractions
        run_test(1.5, 2.5, 3.5, 4.5);
        
        // Test 3: Negative vector
        run_test(-10.0, -20.0, -30.0, -40.0);
        
        // Test 4: Mixed signs
        run_test(10.0, -20.0, 30.0, -40.0);
        
        // Test 5: Unit vector (should give same vector)
        run_test(0.5, 0.5, 0.5, 0.5);
        
        // Test 6: Realistic QR scenario
        run_test(13.86, -7.23, 5.44, -2.91);
        
        // Test 7: Large values
        run_test(30000.0, 20000.0, 10000.0, 5000.0);
        
        $display("");
        $display("==========================================");
        $display("     ALL TESTS COMPLETED");
        $display("==========================================");
        
        #1000;
        $finish;
    end

endmodule
