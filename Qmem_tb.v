`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Devangi Chaudhary
// 
// Create Date: 18.04.2026 18:30:18
// Design Name: 
// Module Name: Qmem_tb
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


//works perfectly just the hex values inputted might be wrong!
module Qmem_tb();

    parameter N     = 4;
    parameter WIDTH = 32;

    reg                     clk;
    reg                     wrQ;
    reg                     rdQ;
    reg  [$clog2(N)-1:0]    wr_addr;
    reg  [$clog2(N)-1:0]    rd_addr;
    reg  [N*WIDTH-1:0]      col_in;
    wire [N*WIDTH-1:0]      col_out;

    Qmemory #(
        .N(N),
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .wrQ(wrQ),
        .rdQ(rdQ),
        .wr_addr(wr_addr),
        .rd_addr(rd_addr),
        .col_in(col_in),
        .col_out(col_out)
    );

    always #5 clk = ~clk;

    // convert real to Q16.16 signed 32 bit
    function [31:0] toQ;
        input real val;
        reg signed [31:0] scaled;
        begin
            scaled = $rtoi(val * 65536.0);
            toQ    = scaled;
        end
    endfunction

    // convert Q16.16 to real for display
    function real fromQ;
        input [31:0] val;
        begin
            fromQ = $itor($signed(val)) / 65536.0;
        end
    endfunction

    task write_col;
        input [$clog2(N)-1:0] col;
        input [WIDTH-1:0]     e0, e1, e2, e3;
        begin
            @(negedge clk);
            wrQ     = 1;
            rdQ     = 0;
            wr_addr = col;
            col_in  = {e3, e2, e1, e0};
            @(posedge clk);
            #1;
            wrQ = 0;
        end
    endtask

    task read_col;
        input [$clog2(N)-1:0] col;
        begin
            @(negedge clk);
            rdQ     = 1;
            wrQ     = 0;
            rd_addr = col;
            @(posedge clk);
            #1;
            rdQ = 0;
        end
    endtask

    task display_col_out;
        input [$clog2(N)-1:0] col;
        integer j;
        begin
            $display("  Read Column %0d:", col);
            for (j = 0; j < N; j = j + 1) begin
                $display("    Q[%0d][%0d] = %h  (decimal: %f)",
                    j, col,
                    col_out[(j+1)*WIDTH-1 -: WIDTH],
                    fromQ(col_out[(j+1)*WIDTH-1 -: WIDTH]));
            end
            $display("");
        end
    endtask

    initial begin
        clk     = 0;
        wrQ     = 0;
        rdQ     = 0;
        wr_addr = 0;
        rd_addr = 0;
        col_in  = 0;

        #10;

        // =============================================
        // CASE 1: write all 4 columns
        // =============================================
        $display("CASE 1: Writing all 4 columns");
        $display("");

        // col 0: [3.75, -7.5, 0.25, -0.25]
        write_col(0, toQ(3.75), toQ(-7.5), toQ(0.25), toQ(-0.25));
        $display("  Wrote Column 0: [3.75, -7.5, 0.25, -0.25]");

        // col 1: [-3.75, 7.5, -0.25, 0.25]
        write_col(1, toQ(-3.75), toQ(7.5), toQ(-0.25), toQ(0.25));
        $display("  Wrote Column 1: [-3.75, 7.5, -0.25, 0.25]");

        // col 2: [0.707, -0.707, 12.333, -12.333]
        write_col(2, toQ(0.707), toQ(-0.707), toQ(12.333), toQ(-12.333));
        $display("  Wrote Column 2: [0.707, -0.707, 12.333, -12.333]");

        // col 3: [100.5, -100.5, 0.707, -0.707]
        write_col(3, toQ(100.5), toQ(-100.5), toQ(0.707), toQ(-0.707));
        $display("  Wrote Column 3: [100.5, -100.5, 0.707, -0.707]");
        $display("");

        // =============================================
        // CASE 2: read all 4 columns and verify
        // =============================================
        $display("CASE 2: Reading all 4 columns and verifying");
        $display("");

        read_col(0); display_col_out(0);
        read_col(1); display_col_out(1);
        read_col(2); display_col_out(2);
        read_col(3); display_col_out(3);

        // =============================================
        // CASE 3: overwrite col 0 and read back
        // =============================================
        $display("CASE 3: Overwrite col 0 with [-12.333, 0.707, -100.5, 3.75]");
        $display("");

        write_col(0, toQ(-12.333), toQ(0.707), toQ(-100.5), toQ(3.75));
        $display("  Overwrote Column 0: [-12.333, 0.707, -100.5, 3.75]");
        read_col(0); display_col_out(0);

        // =============================================
        // CASE 4: simultaneous write col 3 read col 1
        // =============================================
        $display("CASE 4: Simultaneous write col 3 and read col 1");
        $display("");

        @(negedge clk);
        wrQ     = 1;
        rdQ     = 1;
        wr_addr = 3;
        rd_addr = 1;
        col_in  = {toQ(-3.75), toQ(0.707), toQ(-7.5), toQ(100.5)};
        @(posedge clk);
        #1;
        wrQ = 0;
        rdQ = 0;
        $display("  Wrote [100.5, -7.5, 0.707, -3.75] to col 3");
        $display("  Simultaneously read col 1 (should show old col 1 values):");
        display_col_out(1);

        $display("  Verify col 3 was written correctly:");
        read_col(3); display_col_out(3);

        // =============================================
        // CASE 5: simultaneous write and read same col
        // =============================================
        $display("CASE 5: Simultaneous write and read same column 2");
        $display("");

        @(negedge clk);
        wrQ     = 1;
        rdQ     = 1;
        wr_addr = 2;
        rd_addr = 2;
        col_in  = {toQ(-0.707), toQ(-100.5), toQ(3.75), toQ(-3.75)};
        @(posedge clk);
        #1;
        wrQ = 0;
        rdQ = 0;
        $display("  Wrote [-3.75, 3.75, -100.5, -0.707] to col 2 while reading");
        $display("  col_out should show OLD col 2 values [0.707, -0.707, 12.333, -12.333]:");
        display_col_out(2);

        $display("  Read col 2 again to confirm new value [-3.75, 3.75, -100.5, -0.707]:");
        read_col(2); display_col_out(2);

        $display("Done.");
        $finish;
    end

endmodule