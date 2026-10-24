`timescale 1ns / 1ps

module tb_sample_bus_pipeline;

    reg clk;
    reg rst_n;
    reg sample_valid_raw;
    reg [47:0] sample_in;
    wire sample_valid_sync;
    wire [47:0] sample_out;
    reg [47:0] accepted_sample;
    integer accepted_count;

    synchronizer valid_sync (
        .clk(clk), .rst_n(rst_n),
        .async_in(sample_valid_raw), .sync_out(sample_valid_sync)
    );

    sample_bus_pipeline #(.WIDTH(48)) data_sync (
        .clk(clk), .rst_n(rst_n),
        .sample_in(sample_in), .sample_out(sample_out)
    );

    always #5 clk = ~clk;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accepted_sample <= 48'd0;
            accepted_count <= 0;
        end else if (sample_valid_sync) begin
            accepted_sample <= sample_out;
            accepted_count <= accepted_count + 1;
        end
    end

    task cycle;
        input valid_value;
        input [47:0] data_value;
        input expected_valid_after;
        input [47:0] expected_data_after;
        input integer expected_accept_count;
        input [47:0] expected_last_accept;
        input [8*36-1:0] label;
        begin
            @(negedge clk);
            sample_valid_raw = valid_value;
            sample_in = data_value;
            @(posedge clk); #1;
            if (sample_valid_sync !== expected_valid_after)
                $fatal(1, "%0s: synchronized valid mismatch", label);
            if (sample_out !== expected_data_after)
                $fatal(1, "%0s: delayed data bundle mismatch", label);
            if (accepted_count !== expected_accept_count)
                $fatal(1, "%0s: accepted count expected %0d got %0d", label,
                       expected_accept_count, accepted_count);
            if (accepted_sample !== expected_last_accept)
                $fatal(1, "%0s: accepted tuple mismatch", label);
            $display("PASS: %0s valid=%b data=%h accepted=%0d", label,
                     sample_valid_sync, sample_out, accepted_count);
        end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        sample_valid_raw = 0;
        sample_in = 0;
        accepted_sample = 0;
        accepted_count = 0;
        #12 rst_n = 1;

        cycle(0, 48'h0000_0000_0000, 0, 48'h0000_0000_0000, 0, 48'h0000_0000_0000, "reset idle");
        cycle(1, 48'h0000_0000_000A, 0, 48'h0000_0000_0000, 0, 48'h0000_0000_0000, "first sample stage one");
        cycle(1, 48'h0000_0000_0014, 1, 48'h0000_0000_000A, 0, 48'h0000_0000_0000, "first sample aligned at stage two");
        cycle(1, 48'h0000_0000_001E, 1, 48'h0000_0000_0014, 1, 48'h0000_0000_000A, "first accepted tuple");
        cycle(0, 48'h0000_0000_0028, 1, 48'h0000_0000_001E, 2, 48'h0000_0000_0014, "synchronized tail tuple");
        cycle(1, 48'h0000_0000_0032, 0, 48'h0000_0000_0028, 3, 48'h0000_0000_001E, "last pre-gap tuple accepted");
        cycle(0, 48'h0000_0000_003C, 1, 48'h0000_0000_0032, 3, 48'h0000_0000_001E, "next valid tuple staged");
        cycle(0, 48'h0000_0000_0046, 0, 48'h0000_0000_003C, 4, 48'h0000_0000_0032, "post-gap tuple accepted");
        cycle(0, 48'h0000_0000_0050, 0, 48'h0000_0000_0046, 4, 48'h0000_0000_0032, "invalid stream remains idle");

        $display("PASS: two-stage sensor bundle and valid remain cycle-aligned");
        $display("TEST PASSED tb_sample_bus_pipeline");
        $finish;
    end

endmodule