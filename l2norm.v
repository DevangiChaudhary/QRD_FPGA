`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 16:33:15
// Design Name: 
// Module Name: l2norm
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

/*module l2norm #(
    parameter N     = 4,
    parameter WIDTH = 32
)(
    input                           clk,
    input                           start,
    input      [N*WIDTH-1:0]        Vout_flat,
    output reg signed [WIDTH-1:0]   norm_result,
    output reg                      done
);

    // dot product output
    wire signed [WIDTH-1:0] sum_of_squares;
    wire                    dotpro_done;

    // rising edge detector for dotpro done
    reg  dotpro_done_prev;
    wire start_sqrt;

    // DEBUG: Add counters
    reg  sqrt_started;
    integer sqrt_wait_count;

    always @(posedge clk) begin
        dotpro_done_prev <= dotpro_done;
        
        // DEBUG: Track if sqrt started but not done
        if (start_sqrt) begin
            sqrt_started <= 1;
            sqrt_wait_count <= 0;
            $display("  [l2norm] sqrt STARTED at time %t, radicand=%h", $time, radicand);
        end
        
        if (sqrt_started && !sqrt_done) begin
            sqrt_wait_count <= sqrt_wait_count + 1;
            if (sqrt_wait_count == 100) begin
                $display("  [l2norm] WARNING: sqrt still not done after %0d cycles at time %t!", 
                         sqrt_wait_count, $time);
            end
            if (sqrt_wait_count == 200) begin
                $display("  [l2norm] ERROR: sqrt TIMEOUT after %0d cycles at time %t!", 
                         sqrt_wait_count, $time);
                $display("  [l2norm] dotpro_done=%b, dotpro_done_prev=%b, start_sqrt=%b", 
                         dotpro_done, dotpro_done_prev, start_sqrt);
                $display("  [l2norm] sum_of_squares=%h, radicand=%h", sum_of_squares, radicand);
            end
        end
        
        if (sqrt_done) begin
            if (sqrt_started) begin
                $display("  [l2norm] sqrt DONE at time %t (waited %0d cycles)", 
                         $time, sqrt_wait_count);
            end
            sqrt_started <= 0;
        end
    end

    assign start_sqrt = dotpro_done & ~dotpro_done_prev;

    // instantiate dot product with V as both inputs
    dot_product #(
        .N(N),
        .WIDTH(WIDTH)
    ) dp (
        .clk(clk),
        .start(start),
        .Vout_flat(Vout_flat),
        .qout_flat(Vout_flat),
        .result(sum_of_squares),
        .done(dotpro_done)
    );

    // sqrt input is sum of squares as unsigned raw bits
    wire [WIDTH-1:0] radicand;
    assign radicand = $unsigned(sum_of_squares);

    // sqrt output
    wire signed [WIDTH-1:0] sqrt_result;
    wire                    sqrt_done;

    // instantiate sqrt
    sqrt_cordic #(
        .WIDTH(WIDTH)
    ) sq (
        .clk(clk),
        .start(start_sqrt),
        .radicand(radicand),
        .result(sqrt_result),
        .done(sqrt_done)
    );

    // capture final result
    always @(posedge clk) begin
        done <= 0;
        if (sqrt_done) begin
            norm_result <= sqrt_result;
            done        <= 1;
        end
    end

endmodule*/

module l2norm #(
    parameter N     = 4,
    parameter WIDTH = 32
)(
    input                           clk,
    input                           start,
    input      [N*WIDTH-1:0]        Vout_flat,
    output reg signed [WIDTH-1:0]   norm_result,
    output reg                      done
);

    // dot product output
    wire signed [WIDTH-1:0] sum_of_squares;
    wire                    dotpro_done;

    // rising edge detector for dotpro done
    reg  dotpro_done_prev;
    wire start_sqrt;

    always @(posedge clk) begin
        dotpro_done_prev <= dotpro_done;
    end

    assign start_sqrt = dotpro_done & ~dotpro_done_prev;

    // instantiate dot product with V as both inputs
    dot_product #(
        .N(N),
        .WIDTH(WIDTH)
    ) dp (
        .clk(clk),
        .start(start),
        .Vout_flat(Vout_flat),
        .qout_flat(Vout_flat),
        .result(sum_of_squares),
        .done(dotpro_done)
    );

    // sqrt input is sum of squares as unsigned raw bits
    wire [WIDTH-1:0] radicand;
    assign radicand = $unsigned(sum_of_squares);

    // sqrt output
    wire signed [WIDTH-1:0] sqrt_result;
    wire                    sqrt_done;

    // instantiate sqrt
    sqrt_cordic #(
        .WIDTH(WIDTH)
    ) sq (
        .clk(clk),
        .start(start_sqrt),
        .radicand(radicand),
        .result(sqrt_result),
        .done(sqrt_done)
    );

    // capture final result
    always @(posedge clk) begin
        done <= 0;
        if (sqrt_done) begin
            norm_result <= sqrt_result;
            done        <= 1;
        end
    end

endmodule
