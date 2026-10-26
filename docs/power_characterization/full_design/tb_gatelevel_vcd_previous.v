`timescale 1ns/1ps

module tb_gatelevel_vcd;

    reg clk = 0;
    reg m_re = 0, m_we = 0, rst_n = 0;
    reg sample_valid = 0, wake_timer = 0;
    reg [7:0] air_temp = 0, battery = 0, humidity = 0;
    reg [7:0] leaf_temp = 0, light = 0, m_addr = 0;
    reg [7:0] m_wdata = 0, moisture = 0;

    wire comm_en_out, domain2_pwr_en, domain3_pwr_en;
    wire [9:0] adc_mode_vector;
    wire [1:0] ipm_state;
    wire [3:0] leaf_output;
    wire [7:0] m_rdata;

    // 20 ns clock period = 50 MHz.
    always #10 clk = ~clk;

    agrisense_ipms_top uut (
        .clk(clk),
        .comm_en_out(comm_en_out),
        .domain2_pwr_en(domain2_pwr_en),
        .domain3_pwr_en(domain3_pwr_en),
        .m_re(m_re),
        .m_we(m_we),
        .rst_n(rst_n),
        .sample_valid(sample_valid),
        .wake_timer(wake_timer),
        .adc_mode_vector(adc_mode_vector),
        .air_temp(air_temp),
        .battery(battery),
        .humidity(humidity),
        .ipm_state(ipm_state),
        .leaf_output(leaf_output),
        .leaf_temp(leaf_temp),
        .light(light),
        .m_addr(m_addr),
        .m_rdata(m_rdata),
        .m_wdata(m_wdata),
        .moisture(moisture)
    );

    integer i;

    initial begin
        $dumpfile("docs/power_characterization/full_design/gatelevel_workload.vcd");
        $dumpvars(0, tb_gatelevel_vcd);

        // Hold reset, then release it.
        repeat (5) @(negedge clk);
        rst_n = 1;

        // Sensor sampling workload.
        for (i = 0; i < 40; i = i + 1) begin
            @(negedge clk);
            sample_valid = 1;
            air_temp = 8'd20 + i;
            humidity = 8'd40 + (i * 3);
            battery = 8'd220 - i;
            leaf_temp = 8'd18 + (i / 2);
            light = i * 5;
            moisture = 8'd100 - i;
        end

        // Exercise memory-interface inputs.
        @(negedge clk);
        sample_valid = 0;
        m_we = 1;
        m_addr = 8'h24;
        m_wdata = 8'hA5;

        repeat (4) @(negedge clk);
        m_we = 0;
        m_re = 1;

        repeat (8) @(negedge clk);
        m_re = 0;

        // Wake request and additional sensor activity.
        wake_timer = 1;
        repeat (10) @(negedge clk);
        wake_timer = 0;

        for (i = 0; i < 30; i = i + 1) begin
            @(negedge clk);
            sample_valid = (i % 3 != 0);
            air_temp = $random;
            humidity = $random;
            battery = $random;
            leaf_temp = $random;
            light = $random;
            moisture = $random;
        end

        repeat (10) @(negedge clk);
        $display("GATELEVEL VCD TEST COMPLETED");
        $display("Final ipm_state=%b domain2=%b domain3=%b comm=%b",
                 ipm_state, domain2_pwr_en, domain3_pwr_en, comm_en_out);
        $finish;
    end

endmodule
