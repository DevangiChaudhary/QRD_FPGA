`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.04.2026 15:23:47
// Design Name: 
// Module Name: bank
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


module bank #(
    parameter DEPTH = 4,
    parameter WIDTH = 32
)(
    input  [$clog2(DEPTH)-1:0]    addr,
    output reg [DEPTH*WIDTH-1:0]  dout
);

    reg [DEPTH*WIDTH-1:0] mem [DEPTH-1:0];

    initial begin
        $readmemh("C:/Users/Devangi Chaudhary/Desktop/internships/BEL PDIC/Vivado/QRD_datapath/Amatrix.mem", mem);
    end

    always @(*) begin
        dout = mem[addr];
    end

endmodule
