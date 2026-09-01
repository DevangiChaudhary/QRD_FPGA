`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 14:38:59
// Design Name: 
// Module Name: sqrt_cordic
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

module sqrt_cordic #(
    parameter WIDTH = 32
)(
    input                           clk,
    input                           start,
    input      [WIDTH-1:0]          radicand,
    output reg signed [WIDTH-1:0]   result,
    output reg                      done
);

    wire        cordic_valid;
    wire [23:0] cordic_out;

    cordic_sqrt cordic_inst (
        .aclk                       (clk),
        .s_axis_cartesian_tvalid    (start),
        .s_axis_cartesian_tdata     (radicand),
        .m_axis_dout_tvalid         (cordic_valid),
        .m_axis_dout_tdata          (cordic_out)
    );

    always @(posedge clk) begin
        done <= 0;
        if (cordic_valid) begin
            result <= {{(WIDTH-24){1'b0}}, cordic_out} << 10;  // was << 8, now << 4 for Q12.20
            done   <= 1;
        end
    end

endmodule