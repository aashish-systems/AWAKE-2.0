// Self-checking fusion_unit bench: threshold edges, window expiry, pulse/re-arm,
// repeated and simultaneous crossovers, direction patterns, reset.
module tb_fusion;
    reg        clk = 0, rst_n = 0;
    reg  [4:0] cf = 0, td = 0;
    reg  [9:0] pat = 0;
    reg  [2:0] th = 0;
    reg  [7:0] win = 0;
    wire [2:0] score;
    wire       ev;
    integer    errors = 0;
    integer    n;

    fusion_unit dut(.clk(clk), .rst_n(rst_n), .cross_flag_vector(cf),
        .trend_direction_vector(td), .fusion_pattern(pat), .vote_threshold(th),
        .window_size(win), .fusion_score(score), .stress_event(ev));

    always #5 clk = ~clk;

    task check(input [2:0] es, input ee, input [8*40-1:0] msg);
        begin
            if (score !== es || ev !== ee) begin
                $display("FAIL: %0s : score=%0d ev=%b expected score=%0d ev=%b", msg, score, ev, es, ee);
                errors = errors + 1;
            end
        end
    endtask

    task tick; @(negedge clk); endtask

    // one-cycle crossover vector; latency cross_flag -> recent_cross -> registered
    // fusion_score/stress_event is two clock edges, so check after the second.
    task pulse(input [4:0] v, input [4:0] d);
        begin @(negedge clk); cf = v; td = d; @(negedge clk); cf = 0; @(negedge clk); end
    endtask

    task do_reset;
        begin @(negedge clk); rst_n = 0; cf = 0; td = 0; tick; rst_n = 1; end
    endtask

    initial begin
        tick; rst_n = 1; tick;
        check(0, 0, "reset idle");

        th = 0; win = 3; pulse(5'b11111, 0); check(5, 0, "th=0 never fires");

        do_reset; th = 1; win = 0; pulse(5'b00001, 0); check(1, 1, "w0 crossover cycle");
        tick; check(0, 0, "w0 expired next cycle");

        do_reset; th = 1; win = 2; pulse(5'b00001, 0); check(1, 1, "w2 c0 pulse");
        tick; check(1, 0, "w2 c1 held, no re-pulse");
        tick; check(1, 0, "w2 c2 held");
        tick; check(0, 0, "w2 expired");
        pulse(5'b00001, 0); check(1, 1, "re-armed pulse");

        do_reset; th = 1; win = 2; pulse(5'b00010, 0); check(1, 1, "rep first");
        pulse(5'b00010, 0); check(1, 0, "rep reload no pulse");
        tick; tick; check(1, 0, "rep window extended");
        tick; check(0, 0, "rep expired");

        do_reset; th = 2; win = 4; pulse(5'b00001, 0); check(1, 0, "lag ch0 alone");
        tick; pulse(5'b00010, 0); check(2, 1, "lag ch0+ch1 pulse");
        do_reset; th = 2; win = 1; pulse(5'b00001, 0); tick; tick; pulse(5'b00010, 0);
        check(1, 0, "outside window no event");

        do_reset; th = 5; win = 1; pulse(5'b11111, 0); check(5, 1, "th=5 all five");
        do_reset; th = 6; win = 1; pulse(5'b11111, 0); check(5, 0, "th=6 unreachable");
        do_reset; th = 7; win = 1; pulse(5'b11111, 0); check(5, 0, "th=7 unreachable");

        do_reset; th = 1; win = 8'hFF; pulse(5'b00100, 0);
        for (n = 0; n < 255; n = n + 1) tick;
        check(1, 0, "w255 held at +255");
        tick; check(0, 0, "w255 expired at +256");

        do_reset; th = 1; win = 1; pat = 10'b00_00_00_00_01;
        pulse(5'b00001, 5'b00001); check(1, 1, "rising matches 01");
        do_reset; pulse(5'b00001, 5'b00000); check(0, 0, "falling rejected by 01");
        do_reset; pat = 10'b00_00_00_00_10;
        pulse(5'b00001, 5'b00000); check(1, 1, "falling matches 10");
        do_reset; pat = 10'b00_00_00_00_11;
        pulse(5'b00001, 5'b00001); check(0, 0, "excluded 11");

        do_reset; pat = 0; th = 1; win = 8'd50; pulse(5'b00001, 0);
        @(negedge clk); rst_n = 0; #1;
        if (score !== 0 || ev !== 0 || dut.recent_cross !== 0) begin
            $display("FAIL: async reset mid-window"); errors = errors + 1;
        end
        rst_n = 1;

        if (errors == 0) $display("TEST PASSED tb_fusion");
        else $fatal(1, "tb_fusion: %0d errors", errors);
        $finish;
    end
endmodule
