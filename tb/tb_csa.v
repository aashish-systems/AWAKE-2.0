`timescale 1ns / 1ps

module tb_csa;

    reg clk;
    reg rst_n;
    reg enable;
    reg sample_valid;
    reg [7:0] moisture;
    reg [7:0] leaf_temp;
    reg [7:0] humidity;
    reg [7:0] air_temp;
    reg [7:0] light;

    reg [7:0] w_moisture;
    reg [7:0] w_leaftemp;
    reg [7:0] w_humidity;
    reg [7:0] w_airtemp;
    reg [7:0] w_light;
    reg [3:0] shift_factor;

    wire [7:0] stress_score;
    wire score_valid;

    crop_stress_accelerator dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .sample_valid(sample_valid),
        .moisture(moisture),
        .leaf_temp(leaf_temp),
        .humidity(humidity),
        .air_temp(air_temp),
        .light(light),
        .w_moisture(w_moisture),
        .w_leaftemp(w_leaftemp),
        .w_humidity(w_humidity),
        .w_airtemp(w_airtemp),
        .w_light(w_light),
        .shift_factor(shift_factor),
        .stress_score(stress_score),
        .score_valid(score_valid)
    );

    always #5 clk = ~clk;

    task capture_score;
        input [7:0] expected;
        input [8*56-1:0] label;
        begin
            @(negedge clk);
            sample_valid = 1'b1;
            @(posedge clk); #1;
            if (stress_score !== expected)
                $fatal(1, "%0s: expected %0d, got %0d", label, expected, stress_score);
            if (score_valid !== 1'b1)
                $fatal(1, "%0s: score_valid not asserted for captured sample", label);
            $display("PASS: %0s = %0d", label, stress_score);
            @(negedge clk);
            sample_valid = 1'b0;
        end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        enable = 0;
        sample_valid = 0;
        moisture = 0; leaf_temp = 0; humidity = 0; air_temp = 0; light = 0;
        w_moisture = 0; w_leaftemp = 0; w_humidity = 0; w_airtemp = 0; w_light = 0;
        shift_factor = 6;

        #12 rst_n = 1;
        enable = 1;
        if (score_valid !== 1'b0)
            $fatal(1, "score_valid must be low before the first accepted sample");
        capture_score(8'd0, "zero inputs");

        moisture = 255; leaf_temp = 255; humidity = 255; air_temp = 255; light = 255;
        w_moisture = 255; w_leaftemp = 255; w_humidity = 255; w_airtemp = 255; w_light = 255;
        shift_factor = 11;
        @(negedge clk); #1;
        if (stress_score !== 8'd0)
            $fatal(1, "CSA score must retain its prior value before capture edge");
        capture_score(8'd158, "maximum unsigned products and 19-bit sum");

        shift_factor = 10;
        capture_score(8'd255, "above-255 normalized score saturates");

        w_moisture = 64; w_leaftemp = 0; w_humidity = 0; w_airtemp = 0; w_light = 0;
        shift_factor = 6;
        capture_score(8'd255, "normalized maximum and saturation boundary");

        moisture = 0; leaf_temp = 0; humidity = 0; air_temp = 0; light = 0;
        w_moisture = 0;
        capture_score(8'd0, "zero weight sum");

        moisture = 255;
        @(negedge clk);
        if (sample_valid !== 1'b0)
            $fatal(1, "test setup error: sample_valid should be low");
        @(posedge clk); #1;
        if (stress_score !== 8'd0 || score_valid !== 1'b1)
            $fatal(1, "Invalid cycle must hold the last accepted score and validity");
        enable = 0;
        @(posedge clk); #1;
        if (score_valid !== 1'b0)
            $fatal(1, "Disabling the CSA session must invalidate its held score");

        $display("TEST PASSED tb_csa");
        $finish;
    end
endmodule
