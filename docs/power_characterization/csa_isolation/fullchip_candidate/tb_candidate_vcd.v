`timescale 1ns/1ps

module tb_candidate_vcd;
    reg clk = 0;
    reg rst_n = 0;
    reg m_re = 0, m_we = 0;
    reg sample_valid = 0, wake_timer = 0;
    reg [7:0] air_temp = 30, battery = 200, humidity = 30;
    reg [7:0] leaf_temp = 60, light = 30, m_addr = 0;
    reg [7:0] m_wdata = 0, moisture = 20;

    wire comm_en_out, domain2_pwr_en, domain3_pwr_en;
    wire [9:0] adc_mode_vector;
    wire [1:0] ipm_state;
    wire [3:0] leaf_output;
    wire [7:0] m_rdata;

    integer errors = 0;
    integer i;

    always #10 clk = ~clk;

    agrisense_ipms_top uut (
        .clk(clk), .rst_n(rst_n),
        .m_re(m_re), .m_we(m_we),
        .m_addr(m_addr), .m_wdata(m_wdata), .m_rdata(m_rdata),
        .sample_valid(sample_valid), .wake_timer(wake_timer),
        .air_temp(air_temp), .battery(battery), .humidity(humidity),
        .leaf_temp(leaf_temp), .light(light), .moisture(moisture),
        .comm_en_out(comm_en_out),
        .domain2_pwr_en(domain2_pwr_en),
        .domain3_pwr_en(domain3_pwr_en),
        .adc_mode_vector(adc_mode_vector),
        .ipm_state(ipm_state), .leaf_output(leaf_output)
    );

    task check_outputs;
        input [1:0] expected_state;
        input expected_d2, expected_d3, expected_comm;
        input [8*64-1:0] label_text;
        begin
            repeat (2) @(negedge clk);
            $display("CHECK %0s t=%0t state=%b d2=%b d3=%b comm=%b",
                label_text, $time, ipm_state,
                domain2_pwr_en, domain3_pwr_en, comm_en_out);

            if ((ipm_state !== expected_state) ||
                (domain2_pwr_en !== expected_d2) ||
                (domain3_pwr_en !== expected_d3) ||
                (comm_en_out !== expected_comm)) begin
                $display("FAIL %0s expected state=%b d2=%b d3=%b comm=%b",
                    label_text, expected_state,
                    expected_d2, expected_d3, expected_comm);
                errors = errors + 1;
            end
        end
    endtask

    task wr;
        input [7:0] address;
        input [7:0] data;
        begin
            @(negedge clk);
            m_addr = address;
            m_wdata = data;
            m_we = 1;
            @(negedge clk);
            m_we = 0;
        end
    endtask

    task sample;
        input [7:0] m;
        input [7:0] lt;
        begin
            @(negedge clk);
            moisture = m;
            leaf_temp = lt;
            sample_valid = 1;
            @(negedge clk);
            sample_valid = 0;
            repeat (8) @(negedge clk);
        end
    endtask

    task wake;
        begin
            @(negedge clk);
            wake_timer = 1;
            @(negedge clk);
            wake_timer = 0;
            repeat (4) @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("build/csa_isolation/fullchip_candidate/candidate_workload.vcd");
        $dumpvars(0, tb_candidate_vcd);

        // Reset and verify SLEEP.
        repeat (3) @(negedge clk);
        rst_n = 1;
        repeat (2) @(negedge clk);
        check_outputs(2'b00, 0, 0, 0, "SLEEP");

        // Wake into MONITOR.
        wake;
        check_outputs(2'b01, 0, 0, 0, "MONITOR");

        // Match the validated RTL test's CSA/fusion configuration.
        wr(8'h10, 8'd64);
        wr(8'h52, 8'd1);
        wr(8'h51, 8'd4);
        for (i = 8'h20; i <= 8'h24; i = i + 1)
            wr(i, 8'd0);

        // Prime the EMA/crossover logic.
        sample(8'd20, 8'd60);
        sample(8'd20, 8'd60);
        sample(8'd120, 8'd60);
        check_outputs(2'b01, 0, 0, 0, "MONITOR_AFTER_PRIME");

        // Configure the decision tree exactly as in tb_top.v.
        wr(8'h60, 8'd100);
        wr(8'h62, 8'hFF);
        wr(8'h65, 8'd100);
        wr(8'h63, 8'd50);

        sample(8'd20, 8'd60);
        sample(8'd20, 8'd60);
        sample(8'd150, 8'd60);

        // Do not assume a transition succeeded: record and check it.
        check_outputs(2'b11, 1, 1, 1, "CRITICAL_EXPECTED");

        // Follow the RTL regression's lower-score recovery stimulus.
        @(negedge clk);
        moisture = 8'd60;
        leaf_temp = 8'd60;
        sample_valid = 1;
        @(negedge clk);
        sample_valid = 0;
        repeat (10) @(negedge clk);
        check_outputs(2'b10, 1, 0, 0, "WARNING_EXPECTED");

        sample(8'd60, 8'd10);
        check_outputs(2'b01, 0, 0, 0, "MONITOR_RECOVERY");

        // Exercise another wake and reset.
        wake;
        check_outputs(2'b01, 0, 0, 0, "MONITOR_REWAKE");

        @(negedge clk);
        rst_n = 0;
        repeat (2) @(negedge clk);
        check_outputs(2'b00, 0, 0, 0, "RESET_SLEEP");

        if (errors == 0)
            $display("GATELEVEL CHECKS PASSED");
        else
            $fatal(1, "GATELEVEL CHECKS FAILED: %0d mismatches", errors);

        $finish;
    end

    initial begin
        #200000;
        $fatal(1, "TIMEOUT: gate-level workload did not finish");
    end
endmodule
