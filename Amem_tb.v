`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.04.2026 15:27:42
// Design Name: 
// Module Name: Amem_tb
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


module Amem_tb();

    parameter N     = 4;
    parameter WIDTH = 32;

    reg  [$clog2(N)-1:0]  addr;
    wire [N*WIDTH-1:0]    V_flat;

    Amemory #(
        .N(N),
        .WIDTH(WIDTH)
    ) uut (
        .addr(addr),
        .V_flat(V_flat)
    );

    task display_column;
        input [$clog2(N)-1:0] col_num;
        integer j;
        reg [WIDTH-1:0] element;
        reg signed [WIDTH-1:0] signed_element;
        real float_val;
        begin
            $display("Column %0d:", col_num);
            for (j = 0; j < N; j = j + 1) begin
                element = V_flat[(j+1)*WIDTH-1 -: WIDTH];
                signed_element = element;
                float_val = $itor(signed_element) / 65536.0;
                $display("  V[%0d] = %h  (decimal: %f)", j, element, float_val);
            end
        end
    endtask

    integer i;

    initial begin
        #10;
        for (i = 0; i < N; i = i + 1) begin
            addr = i;
            #10;
            display_column(i);
            $display("");
        end

        $display("Done.");
        $finish;
    end
endmodule
