`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.04.2026 15:20:57
// Design Name: 
// Module Name: Amemory
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


module Amemory#(
    parameter N     = 4,
    parameter WIDTH = 32
)(
    input  [$clog2(N)-1:0]   addr,
    output [N*WIDTH-1:0]     V_flat
);

    // bank output is one full column = N*WIDTH bits
    wire [N*WIDTH-1:0] bankout;

    bank #(
        .DEPTH(N),
        .WIDTH(WIDTH)
    ) b (
        .addr(addr),
        .dout(bankout)
    );

    assign V_flat = bankout;

endmodule
