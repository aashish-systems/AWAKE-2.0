module tb_decde;

    reg        clk;
    reg        rst_n;
    reg        sample_valid;
    reg  [7:0] sensor_sample;
    reg  [2:0] shift_factor;

    wire       cross_flag;
    wire       trend_direction;
    wire [2:0] sensor_id_out;

    decde_channel #(
        .SENSOR_ID(3'd0)
    ) dut (
        .clk            (clk),
        .rst_n          (rst_n),
        .sample_valid   (sample_valid),
        .sensor_sample  (sensor_sample),
        .shift_factor   (shift_factor),
        .cross_flag     (cross_flag),
        .trend_direction(trend_direction),
        .sensor_id_out  (sensor_id_out)
    );

    always #5 clk = ~clk;

    task send_sample;
        input [7:0] val;
        begin
            @(posedge clk);
            sensor_sample <= val;
            sample_valid  <= 1'b1;
            @(posedge clk);
            sample_valid  <= 1'b0;
            #20;
        end
    endtask

    initial begin
        clk           = 0;
        rst_n         = 0;
        sample_valid  = 0;
        sensor_sample = 0;
        shift_factor  = 3'd2;

        shift_factor = 3'd5;
        #1;
        if (dut.k_fast !== 3'd5 || dut.k_slow !== 3'd7)
            $fatal(1, "Shift 5 must preserve fast/slow separation at the upper legal boundary");
        shift_factor = 3'd6;
        #1;
        if (dut.k_fast !== 3'd5 || dut.k_slow !== 3'd7)
            $fatal(1, "Shift 6 must saturate rather than wrap the slow shift");
        shift_factor = 3'd7;
        #1;
        if (dut.k_fast !== 3'd5 || dut.k_slow !== 3'd7)
            $fatal(1, "Shift 7 must saturate rather than wrap the slow shift");
        shift_factor = 3'd2;

        #25 rst_n = 1;

        sensor_sample = 8'hFF;
        repeat(3) @(posedge clk);
        #1;
        if (dut.fast_ema !== 16'd0 || dut.slow_ema !== 16'd0 ||
            dut.fast_ema_inst.initialized !== 1'b0 || cross_flag !== 1'b0)
            $fatal(1, "Invalid samples must not initialize EMA state or emit crossovers");
        $display("PASS: invalid samples are ignored before initialization");
        rst_n = 0;
        #10 rst_n = 1;
        #10;

        $display("\n=== Trace 1: Moisture Trace (Declining) ===");
        // Pre-establishing a slight bump to set the Prev_Relation logic properly
        send_sample(8'd60); 
        send_sample(8'd61);
        send_sample(8'd60);
        send_sample(8'd58);
        send_sample(8'd56);
        send_sample(8'd54);
        send_sample(8'd52);
        send_sample(8'd50);
        send_sample(8'd48);
        send_sample(8'd46);
        send_sample(8'd44);
        send_sample(8'd42);
        
        #50 rst_n = 0; #20 rst_n = 1;
        $display("\n=== Trace 2: Leaf Temp Trace (Rising) ===");
        // Pre-establishing a slight dip
        send_sample(8'd40);
        send_sample(8'd39);
        send_sample(8'd40);
        send_sample(8'd42);
        send_sample(8'd44);
        send_sample(8'd46);
        send_sample(8'd48);
        send_sample(8'd50);
        send_sample(8'd52);
        send_sample(8'd54);
        send_sample(8'd56);
        send_sample(8'd58);

        #50 rst_n = 0; #20 rst_n = 1;
        $display("\n=== Trace 3: Noise ===");
        send_sample(8'd50);
        send_sample(8'd49);
        send_sample(8'd50);
        send_sample(8'd51);
        send_sample(8'd50);
        send_sample(8'd49);
        send_sample(8'd50);

        #50;
        $display("Verification tests complete.\n");
        $display("TEST PASSED tb_decde");
        $finish;
    end

    always @(posedge clk) begin
        if (cross_flag) begin
            $display("[%0t] *** CROSSOVER DETECTED *** | Trend: %s", 
                     $time, trend_direction ? "Rising" : "Falling");
        end
    end

endmodule
