`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 13:58:52
// Design Name: 
// Module Name: dotpro_scalsub_top
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


module dotpro_scalsub_top #(
    parameter N     = 4,
    parameter WIDTH = 32
)(
    input                           clk,
    input                           start,
    input      [N*WIDTH-1:0]        Vout_flat,
    input      [N*WIDTH-1:0]        qout_flat,
    output     [N*WIDTH-1:0]        result_flat,
    output reg signed [WIDTH-1:0]   Rval_out,
    output                          done
);

    // dotpro done and result
    wire                    dotpro_done;
    wire signed [WIDTH-1:0] dotpro_result;

    // rising edge detector to convert dotpro done to scalsub start pulse
    reg  dotpro_done_prev;
    wire start_scalsub;

    always @(posedge clk) begin
        dotpro_done_prev <= dotpro_done;
        if (dotpro_done)
            Rval_out <= dotpro_result;
    end

    assign start_scalsub = dotpro_done & ~dotpro_done_prev;

    // instantiate dot product
    dot_product #(
        .N(N),
        .WIDTH(WIDTH)
    ) dp (
        .clk(clk),
        .start(start),
        .Vout_flat(Vout_flat),
        .qout_flat(qout_flat),
        .result(dotpro_result),
        .done(dotpro_done)
    );

    // instantiate scal sub
    scal_sub #(
        .N(N),
        .WIDTH(WIDTH)
    ) ss (
        .clk(clk),
        .start(start_scalsub),
        .Vout_flat(Vout_flat),
        .qout_flat(qout_flat),
        .R_val(dotpro_result),
        .result_flat(result_flat),
        .done(done)
    );

endmodule
