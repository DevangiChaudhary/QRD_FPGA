`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 22:36:41
// Design Name: 
// Module Name: l2norm_divide_top
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


module l2norm_divide_top#(
    parameter N     = 4,
    parameter WIDTH = 32
)(
    input                           clk,
    input                           start,
    input      [N*WIDTH-1:0]        Vout_flat,      // Input column vector
    output reg [N*WIDTH-1:0]        Qout_flat,      // Normalized Q column
    output reg signed [WIDTH-1:0]   Rval_out,       // Norm value for R matrix
    output reg                      done
);

    // l2norm signals
    wire signed [WIDTH-1:0] norm_result;
    wire                    l2norm_done;
    
    // Rising edge detector for l2norm done
    reg  l2norm_done_prev;
    wire start_vector_divide;
    
    // vector_divide signals
    wire [N*WIDTH-1:0]      divided_result;
    wire                    vector_divide_done;
    
    // Edge detector for l2norm done to start vector divide
    always @(posedge clk) begin
        l2norm_done_prev <= l2norm_done;
    end
    
    assign start_vector_divide = l2norm_done & ~l2norm_done_prev;
    
    // Instantiate l2norm module
    l2norm #(
        .N(N),
        .WIDTH(WIDTH)
    ) l2norm_inst (
        .clk(clk),
        .start(start),
        .Vout_flat(Vout_flat),
        .norm_result(norm_result),
        .done(l2norm_done)
    );
    
    // Instantiate vector_divide module
    vector_divide #(
        .N(N),
        .WIDTH(WIDTH)
    ) vector_divide_inst (
        .clk(clk),
        .start(start_vector_divide),
        .Vout_flat(Vout_flat),
        .norm(norm_result),
        .result_flat(divided_result),
        .done(vector_divide_done)
    );
    
    // Output Rval (norm value) when l2norm is done
    always @(posedge clk) begin
        if (l2norm_done) begin
            Rval_out <= norm_result;
        end
    end
    
    // Output Q column and done signal
    always @(posedge clk) begin
        if (vector_divide_done) begin
            Qout_flat <= divided_result;
            done <= 1;
        end else begin
            done <= 0;
        end
    end

endmodule
