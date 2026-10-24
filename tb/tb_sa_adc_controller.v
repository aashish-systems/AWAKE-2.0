`timescale 1ns / 1ps

module tb_sa_adc_controller;

    reg clk;
    reg rst_n;
    reg sample_valid;
    reg [7:0] moisture, leaf_temp, humidity, air_temp, light;
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
        .air_temp(air_temp), .light(light), .fusion_score(fusion_score),
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

    task apply_sample;
        input [7:0] batt;
        input [2:0] fusion;
        input [9:0] expected;
        input [8*40-1:0] label;
        begin
            @(negedge clk);
            sample_valid = 1'b1;
            battery_level = batt;
            fusion_score = fusion;
            @(posedge clk); #1;
            if (mode_valid !== 1'b1 || adc_mode_vector !== expected)
                $fatal(1, "%0s: expected %b, got %b valid=%b", label,
                       expected, adc_mode_vector, mode_valid);
            $display("PASS: %0s = %b", label, adc_mode_vector);
            @(negedge clk);
            sample_valid = 1'b0;
        end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        sample_valid = 0;
        moisture = 110; leaf_temp = 119; humidity = 240; air_temp = 200; light = 255;
        moisture_t1 = 100; moisture_t2 = 200;
        leaf_t1 = 120; leaf_t2 = 220;
        humidity_t1 = 140; humidity_t2 = 240;
        air_t1 = 160; air_t2 = 250;
        light_t1 = 180; light_t2 = 255;
        b_crit = 50;
        b_low = 120;
        fusion_score = 0;
        battery_level = 200;

        #12 rst_n = 1;
        @(posedge clk); #1;
        if (mode_valid !== 1'b0 || adc_mode_vector !== 10'b0)
            $fatal(1, "Reset mode must be safe and invalid");

        apply_sample(200, 0, 10'b10_01_10_00_01, "per-channel thresholds");
        apply_sample(200, 2, 10'b10_10_10_00_10, "fusion escalation per channel");
        apply_sample(80, 2, 10'b01_01_01_00_01, "low-battery cap");

        @(negedge clk);
        moisture = 0; leaf_temp = 0; humidity = 0; air_temp = 0; light = 0;
        battery_level = 30;
        @(posedge clk); #1;
        if (mode_valid !== 1'b1 || adc_mode_vector !== 10'b01_01_01_00_01)
            $fatal(1, "Invalid sample must hold the prior per-channel mode");

        // exact threshold equality: x == t1 -> 01, x == t2 -> 10, x == t1-1 -> 00
        moisture = 100; leaf_temp = 220; humidity = 139; air_temp = 250; light = 179;
        apply_sample(120, 0, 10'b00_10_00_10_01, "x==t1, x==t2, battery==b_low");
        apply_sample(119, 0, 10'b00_01_00_01_01, "battery b_low-1 caps at 01");
        apply_sample(50,  0, 10'b00_01_00_01_01, "battery==b_crit is low only");
        apply_sample(49,  2, 10'b00_00_00_00_00, "battery b_crit-1 forces 8-bit");
        apply_sample(200, 1, 10'b00_10_00_10_01, "fusion 1 does not escalate");
        apply_sample(200, 7, 10'b00_10_00_10_10, "fusion 7 escalates 01 only");
        moisture = 0; leaf_temp = 255; humidity = 0; air_temp = 255; light = 0;
        apply_sample(255, 0, 10'b00_10_00_10_00, "0 and 255 extremes");

        $display("TEST PASSED tb_sa_adc_controller");
        $finish;
    end

endmodule
