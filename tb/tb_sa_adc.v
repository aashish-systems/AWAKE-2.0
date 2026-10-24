`timescale 1ns / 1ps

module tb_sa_adc;

    reg clk;
    reg rst_n;
    reg sample_valid;
    reg [7:0] moisture;
    reg [7:0] leaf_temp;
    reg [7:0] humidity;
    reg [7:0] air_temp;
    reg [7:0] light;
    reg [2:0] fusion_score;
    reg [7:0] battery_level;

    reg [7:0] moisture_t1, moisture_t2;
    reg [7:0] leaf_t1, leaf_t2;
    reg [7:0] humidity_t1, humidity_t2;
    reg [7:0] air_t1, air_t2;
    reg [7:0] light_t1, light_t2;
    reg [7:0] b_crit, b_low;

    wire [9:0] adc_mode_vector;
    wire mode_valid;

    sa_adc_controller uut (
        .clk(clk), .rst_n(rst_n), .sample_valid(sample_valid),
        .moisture(moisture), .leaf_temp(leaf_temp), .humidity(humidity),
        .air_temp(air_temp), .light(light),
        .fusion_score(fusion_score),
        .battery_level(battery_level),
        .moisture_t1(moisture_t1), .moisture_t2(moisture_t2),
        .leaf_t1(leaf_t1), .leaf_t2(leaf_t2),
        .humidity_t1(humidity_t1), .humidity_t2(humidity_t2),
        .air_t1(air_t1), .air_t2(air_t2),
        .light_t1(light_t1), .light_t2(light_t2),
        .b_crit(b_crit), .b_low(b_low),
        .adc_mode_vector(adc_mode_vector), .mode_valid(mode_valid)
    );

    always #5 clk = ~clk;

    task send_sample;
        input [7:0] moisture_value;
        input [7:0] leaf_temp_value;
        input [7:0] humidity_value;
        input [7:0] air_temp_value;
        input [7:0] light_value;
        input [7:0] battery_value;
        input [2:0] fusion_value;
        input [9:0] expected;
        input [8*48-1:0] label;
        begin
            @(negedge clk);
            sample_valid = 1'b1;
            moisture = moisture_value;
            leaf_temp = leaf_temp_value;
            humidity = humidity_value;
            air_temp = air_temp_value;
            light = light_value;
            battery_level = battery_value;
            fusion_score = fusion_value;
            @(posedge clk); #1;
            if (mode_valid !== 1'b1)
                $fatal(1, "%0s: mode_valid not asserted for accepted sample", label);
            if (adc_mode_vector !== expected)
                $fatal(1, "%0s: expected %b, got %b", label, expected, adc_mode_vector);
            $display("PASS: %0s = %b", label, adc_mode_vector);
            @(negedge clk);
            sample_valid = 1'b0;
        end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        sample_valid = 0;
        moisture = 0; leaf_temp = 0; humidity = 0; air_temp = 0; light = 0;
        fusion_score = 0;
        battery_level = 200;
        moisture_t1 = 100; moisture_t2 = 200;
        leaf_t1 = 100; leaf_t2 = 200;
        humidity_t1 = 100; humidity_t2 = 200;
        air_t1 = 100; air_t2 = 200;
        light_t1 = 100; light_t2 = 200;
        b_crit = 50;
        b_low = 120;
        #12 rst_n = 1;
        @(posedge clk); #1;
        if (mode_valid !== 1'b0 || adc_mode_vector !== 10'b00_00_00_00_00)
            $fatal(1, "Reset must select safe 8-bit defaults and mark mode invalid");

        @(negedge clk);
        moisture = 255; leaf_temp = 255; humidity = 255; air_temp = 255; light = 255;
        battery_level = 49;
        @(posedge clk); #1;
        if (mode_valid !== 1'b0 || adc_mode_vector !== 10'b00_00_00_00_00)
            $fatal(1, "Invalid sample must not create an ADC mode decision");

        send_sample(99, 99, 99, 99, 99, 200, 0, 10'b00_00_00_00_00, "below T1");
        send_sample(100, 100, 100, 100, 100, 200, 0, 10'b01_01_01_01_01, "exact T1");
        send_sample(199, 199, 199, 199, 199, 200, 0, 10'b01_01_01_01_01, "below T2");
        send_sample(200, 200, 200, 200, 200, 200, 0, 10'b10_10_10_10_10, "exact T2");
        send_sample(100, 100, 100, 100, 100, 200, 2, 10'b10_10_10_10_10, "fusion escalation");
        send_sample(200, 200, 200, 200, 200, 49, 0, 10'b00_00_00_00_00, "below critical battery");
        send_sample(200, 200, 200, 200, 200, 50, 0, 10'b01_01_01_01_01, "at critical battery");
        send_sample(200, 200, 200, 200, 200, 119, 0, 10'b01_01_01_01_01, "below low battery");
        send_sample(200, 200, 200, 200, 200, 120, 0, 10'b10_10_10_10_10, "at low battery");

        @(negedge clk);
        moisture = 0; leaf_temp = 0; humidity = 0; air_temp = 0; light = 0;
        battery_level = 49;
        sample_valid = 0;
        @(posedge clk); #1;
        if (mode_valid !== 1'b1 || adc_mode_vector !== 10'b10_10_10_10_10)
            $fatal(1, "Invalid cycle must hold the last accepted mode and validity");

        $display("SA-ADC controller tests complete.");
        $display("TEST PASSED tb_sa_adc");
        $finish;
    end

endmodule