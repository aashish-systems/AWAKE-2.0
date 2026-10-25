`timescale 1ns/1ps

module tb_csa_isolation;
    reg clk = 0;
    reg rst_n = 0;
    reg enable = 0;
    reg sample_valid = 0;

    reg [7:0] moisture = 0, leaf_temp = 0, humidity = 0;
    reg [7:0] air_temp = 0, light = 0;
    reg [7:0] w_moisture = 0, w_leaftemp = 0, w_humidity = 0;
    reg [7:0] w_airtemp = 0, w_light = 0;
    reg [3:0] shift_factor = 6;

    wire [7:0] baseline_score, isolated_score;
    wire baseline_valid, isolated_valid;

    reg [7:0] iso_moisture, iso_leaf_temp, iso_humidity;
    reg [7:0] iso_air_temp, iso_light;
    reg [7:0] iso_w_moisture, iso_w_leaftemp, iso_w_humidity;
    reg [7:0] iso_w_airtemp, iso_w_light;

    integer i;
    integer base_disabled_toggles = 0;
    integer iso_disabled_toggles = 0;
    integer base_enabled_toggles = 0;
    integer iso_enabled_toggles = 0;
    reg [79:0] previous_base_products;
    reg [79:0] previous_iso_products;
    reg have_previous = 0;

    always #5 clk = ~clk;

    // Reference design: unchanged production CSA RTL.
    crop_stress_accelerator baseline (
        .clk(clk), .rst_n(rst_n), .enable(enable),
        .sample_valid(sample_valid),
        .moisture(moisture), .leaf_temp(leaf_temp),
        .humidity(humidity), .air_temp(air_temp), .light(light),
        .w_moisture(w_moisture), .w_leaftemp(w_leaftemp),
        .w_humidity(w_humidity), .w_airtemp(w_airtemp),
        .w_light(w_light), .shift_factor(shift_factor),
        .stress_score(baseline_score), .score_valid(baseline_valid)
    );

    // Experiment candidate: isolate both sensor operands and weights.
    always @* begin
        iso_moisture  = enable ? moisture : 8'd0;
        iso_leaf_temp = enable ? leaf_temp : 8'd0;
        iso_humidity  = enable ? humidity : 8'd0;
        iso_air_temp  = enable ? air_temp : 8'd0;
        iso_light     = enable ? light : 8'd0;

        iso_w_moisture = enable ? w_moisture : 8'd0;
        iso_w_leaftemp = enable ? w_leaftemp : 8'd0;
        iso_w_humidity = enable ? w_humidity : 8'd0;
        iso_w_airtemp  = enable ? w_airtemp : 8'd0;
        iso_w_light    = enable ? w_light : 8'd0;
    end

    crop_stress_accelerator candidate (
        .clk(clk), .rst_n(rst_n), .enable(enable),
        .sample_valid(sample_valid),
        .moisture(iso_moisture), .leaf_temp(iso_leaf_temp),
        .humidity(iso_humidity), .air_temp(iso_air_temp),
        .light(iso_light),
        .w_moisture(iso_w_moisture), .w_leaftemp(iso_w_leaftemp),
        .w_humidity(iso_w_humidity), .w_airtemp(iso_w_airtemp),
        .w_light(iso_w_light), .shift_factor(shift_factor),
        .stress_score(isolated_score), .score_valid(isolated_valid)
    );

    function integer bit_changes;
        input [79:0] a;
        input [79:0] b;
        integer k;
        begin
            bit_changes = 0;
            for (k = 0; k < 80; k = k + 1)
                if (a[k] !== b[k])
                    bit_changes = bit_changes + 1;
        end
    endfunction

    task change_inputs;
        input [7:0] seed;
        begin
            moisture   = seed + 8'd3;
            leaf_temp  = seed + 8'd17;
            humidity   = seed + 8'd29;
            air_temp   = seed + 8'd41;
            light      = seed + 8'd53;
            w_moisture = seed + 8'd7;
            w_leaftemp = seed + 8'd13;
            w_humidity = seed + 8'd19;
            w_airtemp  = seed + 8'd23;
            w_light    = seed + 8'd31;
        end
    endtask

    task sample_product_transitions;
        reg [79:0] base_now;
        reg [79:0] iso_now;
        integer base_delta;
        integer iso_delta;
        begin
            #1;
            base_now = {baseline.p_moisture, baseline.p_leaftemp,
                        baseline.p_humidity, baseline.p_airtemp,
                        baseline.p_light};
            iso_now = {candidate.p_moisture, candidate.p_leaftemp,
                       candidate.p_humidity, candidate.p_airtemp,
                       candidate.p_light};

            if (have_previous) begin
                base_delta = bit_changes(base_now, previous_base_products);
                iso_delta = bit_changes(iso_now, previous_iso_products);

                if (enable) begin
                    base_enabled_toggles = base_enabled_toggles + base_delta;
                    iso_enabled_toggles = iso_enabled_toggles + iso_delta;
                end else begin
                    base_disabled_toggles = base_disabled_toggles + base_delta;
                    iso_disabled_toggles = iso_disabled_toggles + iso_delta;
                end
            end

            previous_base_products = base_now;
            previous_iso_products = iso_now;
            have_previous = 1;
        end
    endtask

    initial begin
        $dumpfile("docs/power_characterization/csa_isolation/csa_isolation.vcd");
        $dumpvars(0, tb_csa_isolation);

        #12 rst_n = 1;

        // Disabled interval: vary inputs while enable remains low.
        for (i = 0; i < 30; i = i + 1) begin
            @(negedge clk);
            change_inputs(i * 7);
            sample_product_transitions;
        end

        // Start a fresh transition baseline for the enabled interval.
        // Exclude the enable-edge transition from steady-state counts.
        @(negedge clk);
        enable = 1;
        #1;
        previous_base_products = {
            baseline.p_moisture, baseline.p_leaftemp,
            baseline.p_humidity, baseline.p_airtemp, baseline.p_light
        };
        previous_iso_products = {
            candidate.p_moisture, candidate.p_leaftemp,
            candidate.p_humidity, candidate.p_airtemp, candidate.p_light
        };
        have_previous = 1;
        for (i = 0; i < 20; i = i + 1) begin
            change_inputs(i * 9);
            sample_product_transitions;
            sample_valid = 1;
            @(posedge clk); #1;
            if (baseline_score !== isolated_score ||
                baseline_valid !== isolated_valid)
                $fatal(1, "Mismatch at enabled sample %0d", i);
            @(negedge clk);
            sample_valid = 0;
        end

        // Disable again. Exclude the enable-falling edge from the
        // disabled steady-state transition count.
        @(negedge clk);
        enable = 0;
        #1;
        previous_base_products = {
            baseline.p_moisture, baseline.p_leaftemp,
            baseline.p_humidity, baseline.p_airtemp, baseline.p_light
        };
        previous_iso_products = {
            candidate.p_moisture, candidate.p_leaftemp,
            candidate.p_humidity, candidate.p_airtemp, candidate.p_light
        };
        @(posedge clk); #1;
        if (baseline_valid !== 0 || isolated_valid !== 0)
            $fatal(1, "Validity did not clear when disabled");

        $display("DISABLED_PRODUCT_BIT_TRANSITIONS baseline=%0d isolated=%0d",
                 base_disabled_toggles, iso_disabled_toggles);
        $display("ENABLED_PRODUCT_BIT_TRANSITIONS baseline=%0d isolated=%0d",
                 base_enabled_toggles, iso_enabled_toggles);
        $display("TEST PASSED tb_csa_isolation");
        $finish;
    end

    initial begin
        #10000;
        $fatal(1, "Timeout");
    end
endmodule
