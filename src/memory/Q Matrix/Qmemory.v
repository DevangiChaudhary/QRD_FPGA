`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.04.2026 18:09:24
// Design Name: 
// Module Name: Qmemory
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


module Qmemory #(
    parameter N     = 4,
    parameter WIDTH = 32
)(
    input                           clk,
    input                           wrQ,
    input                           rdQ,
    input  [$clog2(N)-1:0]          wr_addr,   // driven by Vc
    input  [$clog2(N)-1:0]          rd_addr,   // driven by Qc
    input  [N*WIDTH-1:0]            col_in,
    output reg [N*WIDTH-1:0]        col_out
);

    reg [N*WIDTH-1:0] Q [N-1:0];

    always @(posedge clk) begin
        if (wrQ)
            Q[wr_addr] <= col_in;
    end

    always @(posedge clk) begin
        if (rdQ)
            col_out <= Q[rd_addr];
    end

endmodule
