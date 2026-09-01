`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 22:20:39
// Design Name: 
// Module Name: vector_divide
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


module vector_divide #(
    parameter N     = 4,
    parameter WIDTH = 32
)(
    input                           clk,
    input                           start,
    input      [N*WIDTH-1:0]        Vout_flat,
    input      signed [WIDTH-1:0]   norm,
    output reg [N*WIDTH-1:0]        result_flat,
    output reg                      done
);

    // Unpack V
    wire signed [WIDTH-1:0] V [N-1:0];
    genvar k;
    generate
        for (k=0; k<N; k=k+1) begin : unpack
            assign V[k] = Vout_flat[(k+1)*WIDTH-1 -: WIDTH];
        end
    endgenerate

    // Division results and handshake signals
    wire signed [WIDTH-1:0] div_result [N-1:0];
    wire                    div_done [N-1:0];
    wire                    div_ready [N-1:0];
    
    // Start signals for each divider
    reg                     start_div [N-1:0];
    reg                     all_started;
    
    integer i;
    
    // Instantiate N dividers in parallel
    generate
        for (k=0; k<N; k=k+1) begin : gen_div
            division #(.WIDTH(WIDTH)) div_inst (
                .clk(clk),
                .start(start_div[k]),
                .dividend(V[k]),
                .divisor(norm),
                .result(div_result[k]),
                .done(div_done[k]),
                .ready(div_ready[k])
            );
        end
    endgenerate
    
    // Pack results
    generate
        for (k=0; k<N; k=k+1) begin : pack
            always @(*) begin
                result_flat[(k+1)*WIDTH-1 -: WIDTH] = div_result[k];
            end
        end
    endgenerate
    
    // Control logic - start all dividers only when all are ready
    always @(posedge clk) begin
        if (start) begin
            // Check if all dividers are ready
            all_started = 1;
            for (i = 0; i < N; i = i + 1) begin
                if (!div_ready[i]) all_started = 0;
            end
            
            // Start all dividers simultaneously when ready
            if (all_started) begin
                for (i = 0; i < N; i = i + 1) begin
                    start_div[i] <= 1;
                end
            end else begin
                for (i = 0; i < N; i = i + 1) begin
                    start_div[i] <= 0;
                end
            end
        end else begin
            for (i = 0; i < N; i = i + 1) begin
                start_div[i] <= 0;
            end
        end
    end
    
    // All divisions done when all individual dividers are done
    always @(posedge clk) begin
        if (start) begin
            done <= 0;
        end else if (div_done[0] && div_done[1] && div_done[2] && div_done[3]) begin
            done <= 1;
        end else begin
            done <= 0;
        end
    end

endmodule
