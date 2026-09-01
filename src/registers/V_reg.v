`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.04.2026 05:05:15
// Design Name: 
// Module Name: V_reg
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


module V_reg #(
    parameter N     = 4,
    parameter WIDTH = 32
)(
    input                       clk,
    input                       ldV,
    input      [N*WIDTH-1:0]    V_bus,
    output reg [N*WIDTH-1:0]    Vout_flat
);

    always @(posedge clk) begin
        if (ldV)
            Vout_flat <= V_bus;
    end

endmodule
