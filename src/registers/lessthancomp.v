`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 13:20:09
// Design Name: 
// Module Name: lessthancomp
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


module lessthancomp#(
    parameter WIDTH = 4
)(
    input  [WIDTH-1:0]  A,
    input  [WIDTH-1:0]  B,
    output              lt    // lt=1 when A < B
);
    assign lt = (A < B) ? 1 : 0;

endmodule
