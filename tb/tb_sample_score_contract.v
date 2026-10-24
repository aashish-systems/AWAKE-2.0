`timescale 1ns / 1ps

module tb_sample_score_contract;

    reg clk;
    reg rst_n;
    reg [7:0] m_addr;
    reg [7:0] m_wdata;
    reg m_we;
    reg m_re;
    wire [7:0] m_rdata;
    reg sample_valid;
    reg [7:0] moisture;
    reg [7:0] leaf_temp;
    reg [7:0] humidity;
    reg [7:0] air_temp;
    reg [7:0] light;
    reg [7:0] battery;
    reg wake_timer;
    wire [3:0] leaf_output;
    wire [1:0] ipm_state;
    wire domain2_pwr_en;
    wire domain3_pwr_en;
    wire comm_en_out;
    wire [9:0] adc_mode_vector;

    agrisense_ipms_top dut (
        .clk(clk), .rst_n(rst_n),
        .m_addr(m_addr), .m_wdata(m_wdata), .m_we(m_we), .m_re(m_re), .m_rdata(m_rdata),
        .sample_valid(sample_valid),
        .moisture(moisture), .leaf_temp(leaf_temp), .humidity(humidity),
        .air_temp(air_temp), .light(light), .battery(battery),
        .wake_timer(wake_timer),
        .leaf_output(leaf_output), .ipm_state(ipm_state),
        .domain2_pwr_en(domain2_pwr_en), .domain3_pwr_en(domain3_pwr_en),
        .comm_en_out(comm_en_out), .adc_mode_vector(adc_mode_vector)
    );

    always #5 clk = ~clk;

    task write_reg;
        input [7:0] address;
        input [7:0] value;
        begin
            @(negedge clk);
            m_addr = address;
            m_wdata = value;
            m_we = 1'b1;
            @(negedge clk);
            m_we = 1'b0;
        end
    endtask

    task sample_step;
        input valid_value;
        input [7:0] sample_value;
        input expected_accept;
        input [7:0] expected_sample;
        input expected_ema_initialized;
        input [7:0] expected_fast_ema_integer;
        input expected_mode_valid;
        input [9:0] expected_adc_mode;
        input [8*48-1:0] label;
        begin
            @(negedge clk);
            sample_valid = valid_value;
            moisture = sample_value;
            leaf_temp = sample_value;
            humidity = sample_value;
            air_temp = sample_value;
            light = sample_value;
            #1;

            if (dut.sample_accept !== expected_accept)
                $fatal(1, "%0s: expected sample_accept=%b got %b", label,
                       expected_accept, dut.sample_accept);
            if (expected_accept && dut.sensor_bundle_sync[7:0] !== expected_sample)
                $fatal(1, "%0s: aligned moisture tuple expected %0d got %0d", label,
                       expected_sample, dut.sensor_bundle_sync[7:0]);

            @(posedge clk); #1;
            if (dut.sampled_moisture !== expected_sample)
                $fatal(1, "%0s: held sample expected %0d got %0d", label,
                       expected_sample, dut.sampled_moisture);
            if (dut.u_decde_0.fast_ema_inst.initialized !== expected_ema_initialized)
                $fatal(1, "%0s: EMA initialized state mismatch", label);
            if (dut.u_decde_0.fast_ema_inst.ema_out !== {expected_fast_ema_integer, 8'h00})
                $fatal(1, "%0s: fast EMA expected %0d, got %0d", label,
                       expected_fast_ema_integer, dut.u_decde_0.fast_ema_inst.ema_out[15:8]);
            if (dut.csa_score_valid !== 1'b0 || dut.stress_score_raw !== 8'd0)
                $fatal(1, "%0s: CSA score must remain invalid while Domain2 is off", label);
            if (dut.adc_mode_valid !== expected_mode_valid || adc_mode_vector !== expected_adc_mode)
                $fatal(1, "%0s: accepted sample ADC mode mismatch expected %b got %b", label,
                       expected_adc_mode, adc_mode_vector);
            if (ipm_state !== 2'b01 || domain2_pwr_en !== 1'b0 || dut.stress_event !== 1'b0)
                $fatal(1, "%0s: timing probe unexpectedly changed IPM state", label);

            $display("PASS: %0s raw_valid=%b accept=%b sample=%0d fast_ema=%0d CSA_valid=%b ADC_mode=%b",
                     label, valid_value, expected_accept, dut.sampled_moisture,
                     dut.u_decde_0.fast_ema_inst.ema_out[15:8],
                     dut.csa_score_valid, adc_mode_vector);
        end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        m_addr = 0;
        m_wdata = 0;
        m_we = 0;
        m_re = 0;
        sample_valid = 0;
        moisture = 0;
        leaf_temp = 0;
        humidity = 0;
        air_temp = 0;
        light = 0;
        battery = 200;
        wake_timer = 0;

        #12 rst_n = 1;
        repeat (2) @(posedge clk);
        #1;
        if (dut.stress_score_raw !== 8'd0)
            $fatal(1, "CSA reset value must be zero");

        write_reg(8'h10, 8'd64);
        write_reg(8'h11, 8'd0);
        write_reg(8'h12, 8'd0);
        write_reg(8'h13, 8'd0);
        write_reg(8'h14, 8'd0);
        write_reg(8'h52, 8'd7);
        write_reg(8'h80, 8'd20); write_reg(8'h81, 8'd40);
        write_reg(8'h82, 8'd20); write_reg(8'h83, 8'd40);
        write_reg(8'h84, 8'd20); write_reg(8'h85, 8'd40);
        write_reg(8'h86, 8'd20); write_reg(8'h87, 8'd40);
        write_reg(8'h88, 8'd20); write_reg(8'h89, 8'd40);
        write_reg(8'h8A, 8'd50); write_reg(8'h8B, 8'd120);
        write_reg(8'h51, 8'd4);
        write_reg(8'h20, 8'd0);
        write_reg(8'h21, 8'd0);
        write_reg(8'h22, 8'd0);
        write_reg(8'h23, 8'd0);
        write_reg(8'h24, 8'd0);
        write_reg(8'h80, 8'd20); write_reg(8'h81, 8'd40);
        write_reg(8'h82, 8'd20); write_reg(8'h83, 8'd40);
        write_reg(8'h84, 8'd20); write_reg(8'h85, 8'd40);
        write_reg(8'h86, 8'd20); write_reg(8'h87, 8'd40);
        write_reg(8'h88, 8'd20); write_reg(8'h89, 8'd40);
        write_reg(8'h8A, 8'd50); write_reg(8'h8B, 8'd120);
        repeat (2) @(posedge clk);
        #1;

        @(negedge clk);
        wake_timer = 1'b1;
        repeat (4) @(negedge clk);
        wake_timer = 1'b0;
        repeat (3) @(posedge clk);
        #1;
        if (ipm_state !== 2'b01)
            $fatal(1, "Wake timer must place timing probe in MONITOR");

        sample_step(1'b1, 8'd10, 1'b0, 8'd0, 1'b0, 8'd0, 1'b0, 10'b00_00_00_00_00, "raw sample 10 staged");
        sample_step(1'b1, 8'd20, 1'b0, 8'd0, 1'b0, 8'd0, 1'b0, 10'b00_00_00_00_00, "raw sample 20 staged");
        sample_step(1'b1, 8'd30, 1'b1, 8'd10, 1'b1, 8'd10, 1'b1, 10'b00_00_00_00_00, "first accepted sample 10");
        sample_step(1'b1, 8'd40, 1'b1, 8'd20, 1'b1, 8'd20, 1'b1, 10'b01_01_01_01_01, "consecutive accepted sample 20");
        sample_step(1'b1, 8'd50, 1'b1, 8'd30, 1'b1, 8'd30, 1'b1, 10'b01_01_01_01_01, "consecutive accepted sample 30");
        sample_step(1'b0, 8'd60, 1'b1, 8'd40, 1'b1, 8'd40, 1'b1, 10'b10_10_10_10_10, "aligned delayed tuple 40");
        sample_step(1'b0, 8'd70, 1'b1, 8'd50, 1'b1, 8'd50, 1'b1, 10'b10_10_10_10_10, "last valid tuple 50");
        sample_step(1'b0, 8'd80, 1'b0, 8'd50, 1'b1, 8'd50, 1'b1, 10'b10_10_10_10_10, "invalid cycle holds sample 50");
        sample_step(1'b1, 8'd90, 1'b0, 8'd50, 1'b1, 8'd50, 1'b1, 10'b10_10_10_10_10, "post-gap raw sample staged");
        sample_step(1'b0, 8'd100, 1'b0, 8'd50, 1'b1, 8'd50, 1'b1, 10'b10_10_10_10_10, "post-gap valid reaches aligned pipeline");
        sample_step(1'b0, 8'd110, 1'b1, 8'd90, 1'b1, 8'd90, 1'b1, 10'b10_10_10_10_10, "post-gap tuple 90 accepted");
        sample_step(1'b0, 8'd120, 1'b0, 8'd90, 1'b1, 8'd90, 1'b1, 10'b10_10_10_10_10, "post-gap invalid hold");

        if (dut.csa_score_valid !== 1'b0 || dut.stress_score_raw !== 8'd0 || domain2_pwr_en !== 1'b0)
            $fatal(1, "CSA score must remain invalid while Domain2 is logically off");

        $display("PASS: sample-to-score contract observations complete");
        $display("TEST PASSED tb_sample_score_contract");
        $finish;
    end

endmodule