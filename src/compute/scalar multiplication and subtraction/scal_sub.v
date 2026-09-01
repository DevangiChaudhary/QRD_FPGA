`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 02:15:37
// Design Name: 
// Module Name: scal_sub
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

module scal_sub #(
    parameter N     = 4,
    parameter WIDTH = 32
)(
    input                           clk,
    input                           start,
    input      [N*WIDTH-1:0]        Vout_flat,
    input      [N*WIDTH-1:0]        qout_flat,
    input  signed [WIDTH-1:0]       R_val,
    output     [N*WIDTH-1:0]        result_flat,
    output reg                      done
);

    wire signed [WIDTH-1:0] V [N-1:0];
    wire signed [WIDTH-1:0] q [N-1:0];

    genvar k;
    generate
        for (k=0; k<N; k=k+1) begin : unpack
            assign V[k] = Vout_flat[(k+1)*WIDTH-1 -: WIDTH];
            assign q[k] = qout_flat[(k+1)*WIDTH-1 -: WIDTH];
        end
    endgenerate

    reg signed [WIDTH-1:0] res [N-1:0];

    reg signed [63:0]      full_product;
    reg signed [WIDTH-1:0] V_delay;
    reg                    valid_s1;

    reg [$clog2(N):0] count;
    reg [$clog2(N):0] count_sub;
    reg               running;

    genvar j;
    generate
        for (j=0; j<N; j=j+1) begin : flatten
            assign result_flat[(j+1)*WIDTH-1 -: WIDTH] = res[j];
        end
    endgenerate

    always @(posedge clk) begin
        if (start) begin
            count        <= 0;
            count_sub    <= 0;
            running      <= 1;
            valid_s1     <= 0;
            done         <= 0;
            full_product <= 0;
            V_delay      <= 0;
        end else begin

            // stage 1: scalar multiply
            if (running && count < N) begin
                full_product <= R_val * q[count];
                V_delay      <= V[count];
                count        <= count + 1;
                valid_s1     <= 1;
            end else begin
                valid_s1     <= 0;
            end

            // stage 2: truncate and subtract
            if (valid_s1) begin
                res[count_sub] <= V_delay - full_product[51:20];
                count_sub      <= count_sub + 1;
            end

            // done when all elements written
            if (count_sub == N) begin
                done    <= 1;
                running <= 0;
            end

        end
    end

endmodule
