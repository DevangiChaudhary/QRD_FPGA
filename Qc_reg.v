`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 13:15:38
// Design Name: 
// Module Name: Qc_reg
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


module Qc_reg #(
    parameter N     = 4
)(
    input                       clk,
    input                       clrQc,
    input                       incQc,
    output reg [3:0]    Qcout
);

    always @(posedge clk) begin
        if (clrQc)
            Qcout <= 0;
        else if (incQc)
            Qcout <= Qcout + 1;
    end

endmodule
