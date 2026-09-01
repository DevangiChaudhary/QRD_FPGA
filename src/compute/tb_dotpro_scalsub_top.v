`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 14:01:45
// Design Name: 
// Module Name: tb_dotpro_scalsub_top
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


module tb_dotpro_scalsub_top();

    parameter N     = 4;
    parameter WIDTH = 32;

    reg                     clk;
    reg                     start;
    reg  [N*WIDTH-1:0]      Vout_flat;
    reg  [N*WIDTH-1:0]      qout_flat;
    wire [N*WIDTH-1:0]      result_flat;
    wire signed [WIDTH-1:0] Rval_out;
    wire                    done;

    // timing measurement
    integer start_time;
    integer end_time;

    dotpro_scalsub_top #(
        .N(N),
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .start(start),
        .Vout_flat(Vout_flat),
        .qout_flat(qout_flat),
        .result_flat(result_flat),
        .Rval_out(Rval_out),
        .done(done)
    );

    always #5 clk = ~clk;

    // convert real to Q16.16
    function [31:0] toQ;
        input real val;
        reg signed [31:0] scaled;
        begin
            scaled = $rtoi(val * 65536.0);
            toQ    = scaled;
        end
    endfunction

    // convert Q16.16 to real
    function real fromQ;
        input [31:0] val;
        begin
            fromQ = $itor($signed(val)) / 65536.0;
        end
    endfunction

    task run_top;
        input [N*WIDTH-1:0] V_in;
        input [N*WIDTH-1:0] q_in;
        integer j;
        begin
            @(negedge clk);
            Vout_flat  = V_in;
            qout_flat  = q_in;
            start      = 1;
            start_time = $time;
            @(posedge clk);
            #1;
            start = 0;

            @(posedge done);
            end_time = $time;
            #1;

            $display("  Rval_out (dot product) = %h  (decimal: %f)",
                Rval_out, fromQ(Rval_out));
            $display("  Updated V (result_flat):");
            for (j = 0; j < N; j = j + 1) begin
                $display("    res[%0d] = %h  (decimal: %f)",
                    j,
                    result_flat[(j+1)*WIDTH-1 -: WIDTH],
                    fromQ(result_flat[(j+1)*WIDTH-1 -: WIDTH]));
            end
            $display("  Time taken: %0d ns  (%0d clock cycles)",
                end_time - start_time,
                (end_time - start_time) / 10);
            $display("");
        end
    endtask

    initial begin
        clk   = 0;
        start = 0;
        Vout_flat = 0;
        qout_flat = 0;

        #10;

        // =============================================
        // CASE 1: simple positive integers
        // V=[4,3,2,1] q=[1,2,3,4]
        // dot = 4+6+6+4 = 20... wait
        // dot = 4*1+3*2+2*3+1*4 = 4+6+6+4 = 20
        // result[i] = V[i] - dot*q[i]
        // = [4-20, 3-40, 2-60, 1-80] = [-16,-37,-58,-79]
        // =============================================
        $display("CASE 1: V=[4,3,2,1] q=[1,2,3,4]");
        $display("expected dot=20.0 result=[-16,-37,-58,-79]");
        run_top(
            {toQ(1), toQ(2), toQ(3), toQ(4)},
            {toQ(4), toQ(3), toQ(2), toQ(1)}
        );

        // =============================================
        // CASE 2: unit vector q dot with V
        // V=[4,3,2,1] q=[0.5,0.5,0.5,0.5]
        // dot = 4*0.5+3*0.5+2*0.5+1*0.5 = 5.0
        // result[i] = V[i] - 5.0*0.5 = V[i] - 2.5
        // = [1.5, 0.5, -0.5, -1.5]
        // =============================================
        $display("CASE 2: V=[4,3,2,1] q=[0.5,0.5,0.5,0.5]");
        $display("expected dot=5.0 result=[1.5, 0.5, -0.5, -1.5]");
        run_top(
            {toQ(1), toQ(2), toQ(3), toQ(4)},
            {toQ(0.5), toQ(0.5), toQ(0.5), toQ(0.5)}
        );

        // =============================================
        // CASE 3: orthogonal vectors
        // V=[1,0,0,0] q=[0,1,0,0]
        // dot = 0
        // result = V unchanged = [1,0,0,0]
        // =============================================
        $display("CASE 3: orthogonal V=[1,0,0,0] q=[0,1,0,0]");
        $display("expected dot=0.0 result=[1,0,0,0]");
        run_top(
            {toQ(0), toQ(0), toQ(0), toQ(1)},
            {toQ(0), toQ(0), toQ(1), toQ(0)}
        );

        // =============================================
        // CASE 4: negative values
        // V=[-4,-3,-2,-1] q=[-1,-2,-3,-4]
        // dot = 4+6+6+4 = 20
        // result[i] = V[i] - 20*q[i]
        // = [-4-(-20), -3-(-40), -2-(-60), -1-(-80)]
        // = [16, 37, 58, 79]
        // =============================================
        $display("CASE 4: V=[-4,-3,-2,-1] q=[-1,-2,-3,-4]");
        $display("expected dot=20.0 result=[16,37,58,79]");
        run_top(
            {toQ(-1), toQ(-2), toQ(-3), toQ(-4)},
            {toQ(-4), toQ(-3), toQ(-2), toQ(-1)}
        );

        // =============================================
        // CASE 5: realistic MGS values
        // V=[13.86,-7.23,5.44,-2.91]
        // q=[0.567,-0.423,0.812,-0.234]
        // dot ~ 15.9469
        // result ~ [4.818, -0.484, -7.511, 0.822]
        // =============================================
        $display("CASE 5: realistic MGS values");
        $display("V=[13.86,-7.23,5.44,-2.91] q=[0.567,-0.423,0.812,-0.234]");
        $display("expected dot~15.9469 result~[4.818,-0.484,-7.511,0.822]");
        run_top(
            {toQ(-2.91), toQ(5.44), toQ(-7.23), toQ(13.86)},
            {toQ(-0.234), toQ(0.812), toQ(-0.423), toQ(0.567)}
        );

        // =============================================
        // CASE 6: decimal mixed signs
        // V=[1.5,-2.5,3.5,-4.5] q=[-0.5,0.5,-0.5,0.5]
        // dot = 1.5*(-0.5)+(-2.5)*0.5+3.5*(-0.5)+(-4.5)*0.5
        //     = -0.75-1.25-1.75-2.25 = -6.0
        // result[i] = V[i] - (-6)*q[i] = V[i] + 6*q[i]
        // = [1.5-3, -2.5+3, 3.5-3, -4.5+3]
        // = [-1.5, 0.5, 0.5, -1.5]
        // =============================================
        $display("CASE 6: decimal mixed signs");
        $display("V=[1.5,-2.5,3.5,-4.5] q=[-0.5,0.5,-0.5,0.5]");
        $display("expected dot=-6.0 result=[-1.5,0.5,0.5,-1.5]");
        run_top(
            {toQ(-4.5), toQ(3.5), toQ(-2.5), toQ(1.5)},
            {toQ(0.5), toQ(-0.5), toQ(0.5), toQ(-0.5)}
        );

        $display("Done.");
        $finish;
    end

endmodule
