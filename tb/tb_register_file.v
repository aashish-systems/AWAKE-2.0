// Self-checking register_file bench: reset defaults, R/W boundaries,
// RO/unmapped write protection, status bypass, read-enable gating.
module tb_register_file;
    reg clk = 0, rst_n = 0, we = 0, re = 0;
    reg [7:0] addr = 0, wdata = 0;
    wire [7:0] rdata;
    wire [7:0] t0, t6;
    wire [2:0] vote_threshold;
    wire [3:0] nshift;
    wire       weights_valid;
    integer errors = 0, a;

    register_file dut(.clk(clk), .rst_n(rst_n), .addr(addr), .wdata(wdata), .we(we), .re(re),
        .rdata(rdata), .t0(t0), .t6(t6), .vote_threshold(vote_threshold),
        .normalization_shift(nshift), .weights_valid(weights_valid),
        .status_moisture(8'h11), .status_leaftemp(8'h22), .status_humidity(8'h33),
        .status_airtemp(8'h44), .status_light(8'h55), .status_battery(8'hB7),
        .status_stress_score(8'h99), .status_cross_flags(5'b10101), .status_fusion_score(3'd3),
        .status_stress_event(1'b1), .status_leaf_output(4'b1101),
        .status_adc_mode_lsb(8'hA5), .status_adc_mode_msb(2'b10),
        .status_ipm_state(2'b11), .status_ipm_enables(8'h7F));

    always #5 clk = ~clk;

    task wr(input [7:0] ad, input [7:0] d);
        begin @(negedge clk); addr = ad; wdata = d; we = 1; @(negedge clk); we = 0; end
    endtask

    task rd_expect(input [7:0] ad, input [7:0] exp);
        begin
            @(negedge clk); addr = ad; re = 1; #1;
            if (rdata !== exp) begin
                $display("FAIL: read 0x%h = 0x%h expected 0x%h", ad, rdata, exp);
                errors = errors + 1;
            end
            re = 0;
        end
    endtask

    function is_rw(input [7:0] x);
        is_rw = (x <= 8'h01) || (x >= 8'h10 && x <= 8'h14) || x == 8'h19 ||
                (x >= 8'h20 && x <= 8'h24) || x == 8'h51 || x == 8'h52 ||
                x == 8'h55 || x == 8'h56 || (x >= 8'h60 && x <= 8'h66) ||
                (x >= 8'h80 && x <= 8'h8B);
    endfunction

    initial begin
        @(negedge clk); rst_n = 1;

        // reset defaults: quiet chip
        rd_expect(8'h19, 8'd6);
        rd_expect(8'h60, 8'hFF); rd_expect(8'h66, 8'hFF);
        rd_expect(8'h52, 8'h00); rd_expect(8'h51, 8'h00);
        rd_expect(8'h10, 8'h00); rd_expect(8'h8B, 8'h00);
        if (t0 !== 8'hFF || t6 !== 8'hFF || vote_threshold !== 0 || nshift !== 4'd6 || weights_valid !== 0) begin
            $display("FAIL: reset config outputs"); errors = errors + 1;
        end

        // every R/W register: write/readback 0xFF and 0x00 boundary values
        for (a = 0; a < 256; a = a + 1) if (is_rw(a)) begin
            wr(a, 8'hFF); rd_expect(a, 8'hFF);
            wr(a, 8'h00); rd_expect(a, 8'h00);
        end

        // every unmapped address: write ignored, reads 0
        for (a = 0; a < 256; a = a + 1)
            if (!is_rw(a) && !(a >= 8'h04 && a <= 8'h09) && a != 8'h18 && a != 8'h1A &&
                a != 8'h50 && a != 8'h53 && a != 8'h54 && a != 8'h70 &&
                a != 8'h8C && a != 8'h8D && !(a >= 8'hA0 && a <= 8'hA2)) begin
                wr(a, 8'h5A); rd_expect(a, 8'h00);
            end

        // RO status bypass, including writes to RO addresses being ignored
        wr(8'h04, 8'h00); rd_expect(8'h04, 8'h11);
        rd_expect(8'h09, 8'hB7); rd_expect(8'h18, 8'h99);
        rd_expect(8'h50, 8'h15); rd_expect(8'h53, 8'h03); rd_expect(8'h54, 8'h01);
        rd_expect(8'h70, 8'b01_0000_11); // [7:6] type=01, [1:0] severity=11
        rd_expect(8'h8C, 8'hA5); rd_expect(8'h8D, 8'h02);
        wr(8'hA0, 8'h00); rd_expect(8'hA0, 8'h03);
        rd_expect(8'hA1, 8'h7F);
        wr(8'hA2, 8'h00); rd_expect(8'hA2, 8'hB7); // BATTERY_LEVEL tracks battery

        // weight-sum invariant boundaries
        wr(8'h10, 8'd64); rd_expect(8'h1A, 8'h01);
        wr(8'h11, 8'd1);  rd_expect(8'h1A, 8'h00);
        wr(8'h10, 8'd63); rd_expect(8'h1A, 8'h01);
        wr(8'h10, 8'd255); wr(8'h11, 8'd255); wr(8'h12, 8'd255); wr(8'h13, 8'd255); wr(8'h14, 8'd255);
        rd_expect(8'h1A, 8'h00); // 1275, no wrap to 64

        // vote threshold uses low 3 bits only
        wr(8'h52, 8'h0D); if (vote_threshold !== 3'd5) begin $display("FAIL: vote low bits"); errors = errors + 1; end

        // read enable low -> 0
        @(negedge clk); addr = 8'h19; re = 0; #1;
        if (rdata !== 8'h00) begin $display("FAIL: re=0 must read 0"); errors = errors + 1; end

        // write while in reset is ignored, reset restores defaults
        @(negedge clk); rst_n = 0; #1;
        if (t0 !== 8'hFF || nshift !== 4'd6) begin $display("FAIL: async reset defaults"); errors = errors + 1; end
        addr = 8'h60; wdata = 0; we = 1; @(negedge clk); we = 0; rst_n = 1;
        rd_expect(8'h60, 8'hFF);

        if (errors == 0) $display("TEST PASSED tb_register_file");
        else $fatal(1, "tb_register_file: %0d errors", errors);
        $finish;
    end
endmodule
