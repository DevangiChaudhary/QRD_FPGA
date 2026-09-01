`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.04.2026 15:33:50
// Design Name: 
// Module Name: Rmemory
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


module Rmemory#(
    parameter N     = 4,
    parameter WIDTH = 32
)(
    input                       clk,
    input                       wrR,
    input                       ltQc,
    input  [$clog2(N)-1:0]      Qcout,
    input  [$clog2(N)-1:0]      Vcout,
    input  [WIDTH-1:0]          data_in
);

    reg [WIDTH-1:0] R [N-1:0][N-1:0];

    always @(posedge clk) begin
        if (wrR) begin
            if (ltQc)
            R[Qcout][Vcout] <= data_in;
            else
            R[Vcout][Vcout] <= data_in;
        end
    end

endmodule
