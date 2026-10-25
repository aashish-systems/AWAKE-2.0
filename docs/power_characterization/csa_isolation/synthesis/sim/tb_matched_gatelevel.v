`timescale 1ns/1ps
module tb_matched_gatelevel;
    reg clk=0, rst_n=0, enable=0, sample_valid=0;
    reg [7:0] moisture=0, leaf_temp=0, humidity=0, air_temp=0, light=0;
    reg [7:0] w_moisture=0, w_leaftemp=0, w_humidity=0, w_airtemp=0, w_light=0;
    reg [3:0] shift_factor=0;

    wire [7:0] base_score, iso_score;
    wire base_valid, iso_valid;
    integer i, errors=0;

    crop_stress_accelerator baseline (
        .clk(clk), .rst_n(rst_n), .enable(enable),
        .sample_valid(sample_valid),
        .moisture(moisture), .leaf_temp(leaf_temp), .humidity(humidity),
        .air_temp(air_temp), .light(light),
        .w_moisture(w_moisture), .w_leaftemp(w_leaftemp),
        .w_humidity(w_humidity), .w_airtemp(w_airtemp), .w_light(w_light),
        .shift_factor(shift_factor),
        .stress_score(base_score), .score_valid(base_valid)
    );

    crop_stress_accelerator_isolated isolated (
        .clk(clk), .rst_n(rst_n), .enable(enable),
        .sample_valid(sample_valid),
        .moisture(moisture), .leaf_temp(leaf_temp), .humidity(humidity),
        .air_temp(air_temp), .light(light),
        .w_moisture(w_moisture), .w_leaftemp(w_leaftemp),
        .w_humidity(w_humidity), .w_airtemp(w_airtemp), .w_light(w_light),
        .shift_factor(shift_factor),
        .stress_score(iso_score), .score_valid(iso_valid)
    );

    always #10 clk=~clk;

    task compare_outputs;
    begin
        if (base_valid !== iso_valid ||
            (base_valid === 1'b1 && base_score !== iso_score)) begin
            $display("MISMATCH t=%0t enable=%b baseline=%h/%b isolated=%h/%b",
                     $time, enable, base_score, base_valid, iso_score, iso_valid);
            errors=errors+1;
        end
    end
    endtask

    task randomize_inputs;
    begin
        moisture=$random; leaf_temp=$random; humidity=$random;
        air_temp=$random; light=$random;
        w_moisture=$random; w_leaftemp=$random; w_humidity=$random;
        w_airtemp=$random; w_light=$random; shift_factor=$random;
    end
    endtask

    initial begin
        $dumpfile("docs/power_characterization/csa_isolation/synthesis/sim/matched_gatelevel.vcd");
        $dumpvars(0,tb_matched_gatelevel);

        repeat(3) @(negedge clk);
        rst_n=1;
        repeat(2) begin @(negedge clk); #1 compare_outputs(); end

        enable=1; sample_valid=1;
        for(i=0;i<200;i=i+1) begin
            randomize_inputs();
            @(negedge clk); #1 compare_outputs();
        end

        enable=0; sample_valid=0;
        for(i=0;i<200;i=i+1) begin
            randomize_inputs();
            @(negedge clk); #1 compare_outputs();
        end

        enable=1; sample_valid=1;
        for(i=0;i<50;i=i+1) begin
            randomize_inputs();
            @(negedge clk); #1 compare_outputs();
        end

        sample_valid=0;
        @(negedge clk); #1 compare_outputs();

        if(errors==0)
            $display("PASS: matched gate-level outputs; enabled samples=250, disabled cycles=200, mismatches=0");
        else
            $fatal(1,"FAIL: %0d mismatches",errors);

        $finish;
    end
endmodule
