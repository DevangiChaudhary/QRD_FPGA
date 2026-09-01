`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 16:35:37
// Design Name: 
// Module Name: tb_l2norm
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
/*
module tb_l2norm;

    parameter N     = 4;
    parameter WIDTH = 32;

    reg                     clk;
    reg                     start;
    reg  [N*WIDTH-1:0]      Vout_flat;
    wire signed [WIDTH-1:0] norm_result;
    wire                    done;

    l2norm #(
        .N(N),
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .start(start),
        .Vout_flat(Vout_flat),
        .norm_result(norm_result),
        .done(done)
    );

    always #5 clk = ~clk;

    function [31:0] toQ;
        input real val;
        reg signed [31:0] scaled;
        begin
            scaled = $rtoi(val * 65536.0);
            toQ    = scaled;
        end
    endfunction

    function real fromQ;
        input [31:0] val;
        begin
            fromQ = $itor($signed(val)) / 65536.0;
        end
    endfunction

    integer start_time;
    integer end_time;
    integer timeout_cnt;

    task run_norm;
        input [N*WIDTH-1:0] V_in;
        input real          expected;
        begin
            @(negedge clk);
            Vout_flat  = V_in;
            start      = 1;
            start_time = $time;
            $display("  [TB] Starting norm at time %t", $time);
            @(posedge clk);
            #1;
            start = 0;

            // Wait for done with timeout
            timeout_cnt = 0;
            while (done == 0 && timeout_cnt < 500) begin
                @(posedge clk);
                timeout_cnt = timeout_cnt + 1;
            end
            
            if (timeout_cnt >= 500) begin
                $display("  [TB] ERROR: TIMEOUT after %0d cycles!", timeout_cnt);
                $display("  [TB] uut.sqrt_started = %b", uut.sqrt_started);
                $display("  [TB] uut.sqrt_done = %b", uut.sqrt_done);
                $display("  [TB] uut.start_sqrt = %b", uut.start_sqrt);
                $display("  [TB] uut.sum_of_squares = %h", uut.sum_of_squares);
                $display("  [TB] uut.radicand = %h", uut.radicand);
            end
            
            end_time = $time;
            #1;
            $display("  Expected  = %f", expected);
            $display("  Result    = %h  (decimal: %f)", norm_result, fromQ(norm_result));
            $display("  Error     = %f", expected - fromQ(norm_result));
            $display("  Cycles    = %0d", (end_time - start_time) / 10);
            $display("");
        end
    endtask

    initial begin
        clk       = 0;
        start     = 0;
        Vout_flat = 0;

        #10;

        $display("CASE 1: V=[1,0,0,0] expected norm=1.0");
        run_norm({toQ(0), toQ(0), toQ(0), toQ(1)}, 1.0);

        $display("CASE 2: V=[1,1,1,1] expected norm=2.0");
        run_norm({toQ(1), toQ(1), toQ(1), toQ(1)}, 2.0);

        $display("CASE 3: V=[3,4,0,0] expected norm=5.0");
        run_norm({toQ(0), toQ(0), toQ(4), toQ(3)}, 5.0);

        $display("CASE 4: V=[1,2,3,4] expected norm=5.47722");
        run_norm({toQ(4), toQ(3), toQ(2), toQ(1)}, 5.47722);

        $display("CASE 5: V=[-1,-2,-3,-4] expected norm=5.47722");
        run_norm({toQ(-4), toQ(-3), toQ(-2), toQ(-1)}, 5.47722);

        $display("CASE 6: V=[0.5,0.5,0.5,0.5] expected norm=1.0");
        run_norm({toQ(0.5), toQ(0.5), toQ(0.5), toQ(0.5)}, 1.0);

        $display("CASE 7: V=[13.86,-7.23,5.44,-2.91] expected norm=16.8058");
        run_norm({toQ(-2.91), toQ(5.44), toQ(-7.23), toQ(13.86)}, 16.8058);

        $display("CASE 8: V=[0.707,0.707,0,0] expected norm~1.0");
        run_norm({toQ(0), toQ(0), toQ(0.707), toQ(0.707)}, 1.0);

        $display("==========================================");
        $display("ALL TESTS COMPLETED");
        $display("==========================================");
        
    end

endmodule */

module tb_l2norm;

    parameter N     = 4;
    parameter WIDTH = 32;

    reg                     clk;
    reg                     start;
    reg  [N*WIDTH-1:0]      Vout_flat;
    wire signed [WIDTH-1:0] norm_result;
    wire                    done;

    l2norm #(
        .N(N),
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .start(start),
        .Vout_flat(Vout_flat),
        .norm_result(norm_result),
        .done(done)
    );

    always @(posedge clk) begin
        if (uut.start_sqrt)
            $display("  sqrt started at time %t", $time);
        if (uut.sqrt_done)
            $display("  sqrt done at time %t", $time);
    end

    always @(posedge clk) begin
        if (uut.dotpro_done)
            $display("  dotpro_done at time %t", $time);
    end

    always #5 clk = ~clk;

    function [31:0] toQ;
        input real val;
        reg signed [31:0] scaled;
        begin
            scaled = $rtoi(val * 65536.0);
            toQ    = scaled;
        end
    endfunction

    function real fromQ;
        input [31:0] val;
        begin
            fromQ = $itor($signed(val)) / 65536.0;
        end
    endfunction

    integer start_time;
    integer end_time;

    task run_norm;
        input [N*WIDTH-1:0] V_in;
        input real          expected;
        begin
            @(negedge clk);
            Vout_flat  = V_in;
            start      = 1;
            start_time = $time;
            @(posedge clk);
            #1;
            start = 0;

            @(posedge done);
            end_time = $time;
            #1;
            $display("  Expected  = %f", expected);
            $display("  Result    = %h  (decimal: %f)", norm_result, fromQ(norm_result));
            $display("  Error     = %f", expected - fromQ(norm_result));
            $display("  Cycles    = %0d", (end_time - start_time) / 10);
            $display("");
        end
    endtask

    initial begin
        clk       = 0;
        start     = 0;
        Vout_flat = 0;

        #10;

        // =============================================
        // CASE 1: V=[1,0,0,0] norm=1.0
        // =============================================
        $display("CASE 1: V=[1,0,0,0] expected norm=1.0");
        run_norm(
            {toQ(0), toQ(0), toQ(0), toQ(1)},
            1.0
        );

        // =============================================
        // CASE 2: V=[1,1,1,1] norm=2.0
        // sum of squares = 4.0
        // sqrt(4.0) = 2.0
        // =============================================
        $display("CASE 2: V=[1,1,1,1] expected norm=2.0");
        run_norm(
            {toQ(1), toQ(1), toQ(1), toQ(1)},
            2.0
        );

        // =============================================
        // CASE 3: V=[3,4,0,0] norm=5.0
        // sum of squares = 9+16 = 25
        // sqrt(25) = 5.0
        // =============================================
        $display("CASE 3: V=[3,4,0,0] expected norm=5.0");
        run_norm(
            {toQ(0), toQ(0), toQ(4), toQ(3)},
            5.0
        );

        // =============================================
        // CASE 4: V=[1,2,3,4] norm=sqrt(30)=5.47722
        // sum of squares = 1+4+9+16 = 30
        // =============================================
        $display("CASE 4: V=[1,2,3,4] expected norm=5.47722");
        run_norm(
            {toQ(4), toQ(3), toQ(2), toQ(1)},
            5.47722
        );

        // =============================================
        // CASE 5: V=[-1,-2,-3,-4] norm=sqrt(30)=5.47722
        // negative values same norm as positive
        // =============================================
        $display("CASE 5: V=[-1,-2,-3,-4] expected norm=5.47722");
        run_norm(
            {toQ(-4), toQ(-3), toQ(-2), toQ(-1)},
            5.47722
        );

        // =============================================
        // CASE 6: V=[0.5,0.5,0.5,0.5] norm=1.0
        // sum of squares = 0.25*4 = 1.0
        // sqrt(1.0) = 1.0
        // =============================================
        $display("CASE 6: V=[0.5,0.5,0.5,0.5] expected norm=1.0");
        run_norm(
            {toQ(0.5), toQ(0.5), toQ(0.5), toQ(0.5)},
            1.0
        );

        // =============================================
        // CASE 7: realistic MGS vector
        // V=[13.86,-7.23,5.44,-2.91]
        // sum = 192.0996+52.2729+29.5936+8.4681 = 282.4342
        // sqrt(282.4342) = 16.8058
        // =============================================
        $display("CASE 7: V=[13.86,-7.23,5.44,-2.91] expected norm=16.8058");
        run_norm(
            {toQ(-2.91), toQ(5.44), toQ(-7.23), toQ(13.86)},
            16.8058
        );

        // =============================================
        // CASE 8: unit vector norm should be 1.0
        // V=[0.707,0.707,0,0] norm~1.0
        // sum = 0.5+0.5 = 1.0
        // =============================================
        $display("CASE 8: V=[0.707,0.707,0,0] expected norm~1.0");
        run_norm(
            {toQ(0), toQ(0), toQ(0.707), toQ(0.707)},
            1.0
        );

        $display("Done.");
        $finish;
    end

endmodule
