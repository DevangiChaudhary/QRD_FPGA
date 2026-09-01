`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.04.2026 05:05:27
// Design Name: 
// Module Name: q_reg
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


module q_reg #(
    parameter N     = 4,
    parameter WIDTH = 32
)(
    input                       clk,
    input                       ldq,
    input      [N*WIDTH-1:0]    q_bus,
    output reg [N*WIDTH-1:0]    qout_flat
);

    always @(posedge clk) begin
        if (ldq)
            qout_flat <= q_bus;
    end

endmodule
