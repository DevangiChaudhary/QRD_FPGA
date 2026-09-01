`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 13:15:10
// Design Name: 
// Module Name: Vc_reg
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


module Vc_reg #(
    parameter N     = 4
)(
    input                       clk,
    input                       clrVc,
    input                       incVc,
    output reg [3:0]    Vcout
);

    always @(posedge clk) begin
        if (clrVc)
            Vcout <= 0;
        else if (incVc)
            Vcout <= Vcout + 1;
    end

endmodule
