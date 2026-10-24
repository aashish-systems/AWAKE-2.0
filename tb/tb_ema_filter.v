// Self-checking ema_filter bench: exact Q8.8 values for constant, rising,
// falling and full-scale inputs; first-sample init; hold without valid; reset.
module tb_ema_filter;
    reg        clk = 0, rst_n = 0, sample_valid = 0;
    reg  [7:0] sample = 0;
    reg  [2:0] shift_factor = 3'd1;
    wire [15:0] ema_out;
    integer errors = 0;

    ema_filter dut(.clk(clk), .rst_n(rst_n), .sample_valid(sample_valid),
        .sample(sample), .shift_factor(shift_factor), .ema_out(ema_out));

    always #5 clk = ~clk;

    task send_expect(input [7:0] val, input [15:0] exp);
        begin
            @(negedge clk); sample = val; sample_valid = 1;
            @(negedge clk); sample_valid = 0;
            if (ema_out !== exp) begin
                $display("FAIL: sample %0d k=%0d ema=%0d expected %0d", val, shift_factor, ema_out, exp);
                errors = errors + 1;
            end
        end
    endtask

    task do_reset; begin @(negedge clk); rst_n = 0; @(negedge clk); rst_n = 1; end endtask

    initial begin
        @(negedge clk); rst_n = 1;

        repeat (5) send_expect(8'd50, 16'd12800);           // constant: exact, no drift

        do_reset;
        if (ema_out !== 16'd0 || dut.initialized !== 1'b0) begin $display("FAIL: reset"); errors = errors + 1; end
        send_expect(8'd50, 16'd12800); send_expect(8'd60, 16'd14080);   // rise, k=1
        send_expect(8'd70, 16'd16000); send_expect(8'd80, 16'd18240);
        send_expect(8'd90, 16'd20640);

        do_reset;
        send_expect(8'd90, 16'd23040); send_expect(8'd80, 16'd21760);   // fall, k=1
        send_expect(8'd70, 16'd19840); send_expect(8'd60, 16'd17600);
        send_expect(8'd50, 16'd15200);

        do_reset; shift_factor = 3'd0;                                  // full scale, k=0
        send_expect(8'd0, 16'd0); send_expect(8'd255, 16'd65280); send_expect(8'd0, 16'd0);
        shift_factor = 3'd7;
        send_expect(8'd255, 16'd510);                                   // 65280 >>> 7

        repeat (5) @(negedge clk);
        if (ema_out !== 16'd510) begin $display("FAIL: hold without valid"); errors = errors + 1; end

        if (errors == 0) $display("TEST PASSED tb_ema_filter");
        else $fatal(1, "tb_ema_filter: %0d errors", errors);
        $finish;
    end
endmodule
