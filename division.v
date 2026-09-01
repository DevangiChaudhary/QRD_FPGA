`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 19:48:54
// Design Name: 
// Module Name: division
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

module division #(
    parameter WIDTH = 32
)(
    input                           clk,
    input                           start,
    input  signed [WIDTH-1:0]       dividend,   
    input  signed [WIDTH-1:0]       divisor,    
    output reg signed [WIDTH-1:0]   result,     
    output reg                      done,
    output                          ready       
);

    // Divider IP signals
    wire                    divider_tvalid;
    wire [55:0]             divider_tdata;
    wire                    dividend_tready;
    wire                    divisor_tready;
    
    // Control signals
    reg                     valid;
    
    // IP is ready when both tready signals are high
    assign ready = dividend_tready && divisor_tready;
    
    // Instantiate Divider IP
    div_gen_0 div_inst (
        .aclk(clk),
        .s_axis_divisor_tvalid(valid),
        .s_axis_divisor_tready(divisor_tready),
        .s_axis_divisor_tdata(divisor),
        .s_axis_dividend_tvalid(valid),
        .s_axis_dividend_tready(dividend_tready),
        .s_axis_dividend_tdata(dividend),
        .m_axis_dout_tvalid(divider_tvalid),
        .m_axis_dout_tdata(divider_tdata)
    );
    
    // Handshaking control
    always @(posedge clk) begin
        if (start && ready) begin
            valid <= 1;
        end else begin
            valid <= 0;
        end
    end
    
    // Output result
    always @(posedge clk) begin
        done <= 0;
        if (divider_tvalid) begin //Q12.20 format
            result <= {divider_tdata[31:20], divider_tdata[19:0]}; // in implementation details of IP block it can be seen the quotient part and fractional part
            done   <= 1;
        end
    end

endmodule