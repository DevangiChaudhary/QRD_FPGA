`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.04.2026 15:40:59
// Design Name: 
// Module Name: Rmem_tb
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


module Rmem_tb();
    parameter N     = 4;
    parameter WIDTH = 32;

    reg                     clk;
    reg                     wrR;
    reg  [$clog2(N)-1:0]    row_addr;
    reg  [$clog2(N)-1:0]    col_addr;
    reg  [WIDTH-1:0]        data_in;

    Rmemory #(
        .N(N),
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .wrR(wrR),
        .row_addr(row_addr),
        .col_addr(col_addr),
        .data_in(data_in)
    );

    // clock generation
    always #5 clk = ~clk;

    // task to write one element
    task write_R;
        input [$clog2(N)-1:0] row;
        input [$clog2(N)-1:0] col;
        input [WIDTH-1:0]     val;
        begin
            @(negedge clk); // drive on negedge so it is stable at posedge
            wrR      = 1;
            row_addr = row;
            col_addr = col;
            data_in  = val;
            @(posedge clk); // wait for write to happen
            #1;
            wrR      = 0;
        end
    endtask

    // task to display one column
    task display_column;
        input [$clog2(N)-1:0] col;
        integer row;
        begin
            $display("Column %0d:", col);
            for (row = 0; row < N; row = row + 1) begin
                $display("  R[%0d][%0d] = %h", row, col, uut.R[row][col]);
            end
            $display("");
        end
    endtask

    integer j;

    initial begin
        clk      = 0;
        wrR      = 0;
        row_addr = 0;
        col_addr = 0;
        data_in  = 0;

        #10;

        // write in your specified order
        // r00, r01, r11, r02, r12, r22, r03, r13, r23, r33
        write_R(0, 0, 32'h00010000); // r00 = 1.0
        write_R(0, 1, 32'h00020000); // r01 = 2.0
        write_R(1, 1, 32'h00030000); // r11 = 3.0
        write_R(0, 2, 32'h00040000); // r02 = 4.0
        write_R(1, 2, 32'h00050000); // r12 = 5.0
        write_R(2, 2, 32'h00060000); // r22 = 6.0
        write_R(0, 3, 32'h00070000); // r03 = 7.0
        write_R(1, 3, 32'h00080000); // r13 = 8.0
        write_R(2, 3, 32'h00090000); // r23 = 9.0
        write_R(3, 3, 32'h000A0000); // r33 = 10.0

        #10;

        // display all columns
        for (j = 0; j < N; j = j + 1)
            display_column(j);

        $display("Done.");
        $finish;
    end

endmodule
