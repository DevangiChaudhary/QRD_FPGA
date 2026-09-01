`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 00:30:13
// Design Name: 
// Module Name: dot_product
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


module dot_product #(
    parameter N     = 4,
    parameter WIDTH = 32
)(
    input                           clk,
    input                           start,
    input      [N*WIDTH-1:0]        Vout_flat,
    input      [N*WIDTH-1:0]        qout_flat,
    output reg signed [WIDTH-1:0]   result,
    output reg                      done
);

    // unpack internally
    wire signed [WIDTH-1:0] V [N-1:0];
    wire signed [WIDTH-1:0] q [N-1:0];

    genvar k;
    generate
        for (k=0; k<N; k=k+1) begin : unpack
            assign V[k] = Vout_flat[(k+1)*WIDTH-1 -: WIDTH];
            assign q[k] = qout_flat[(k+1)*WIDTH-1 -: WIDTH];
        end
    endgenerate

    // stage 1: N parallel multipliers
    reg signed [63:0] products [N-1:0];
    reg               valid_s1;

    // stage 2: N/2 parallel adders
    reg signed [65:0] sum_l1 [N/2-1:0];
    reg               valid_s2;

    // stage 3: N/4 parallel adders
    reg signed [66:0] sum_l2 [N/4-1:0];
    reg               valid_s3;

    integer i;

    always @(posedge clk) begin

        // stage 1
        valid_s1 <= start;
        if (start) begin
            done<=0;
            for (i = 0; i < N; i = i + 1)
                products[i] <= V[i] * q[i];
        end

        // stage 2
        valid_s2 <= valid_s1;
        if (valid_s1) begin
            for (i = 0; i < N/2; i = i + 1)
                sum_l1[i] <= products[2*i] + products[2*i+1];
        end

        // stage 3
        valid_s3 <= valid_s2;
        if (valid_s2) begin
            for (i = 0; i < N/4; i = i + 1)
                sum_l2[i] <= sum_l1[2*i] + sum_l1[2*i+1];
        end

        // output
        done <= valid_s3;
        if (valid_s3)
            result <= sum_l2[0][51:20];

    end

endmodule