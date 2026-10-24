`timescale 1ns/1ps
`include "agrisense_defs.vh"

module tb_ipm_state_workload;
    reg clk = 1'b0;
    reg rst_n = 1'b0;
    reg wake_timer = 1'b0;
    reg stress_event = 1'b0;
    reg [3:0] leaf_output = 4'b0000;
    reg leaf_valid = 1'b0;

    wire [1:0] state;
    wire domain2_pwr_en;
    wire domain3_pwr_en;
    wire sensor_en;
    wire decde_en;
    wire csa_en;
    wire dtree_en;
    wire comm_en;

    integer trace_file;
    integer cycle_count = 0;
    integer state_counts [0:3];

    ipm_fsm dut (
        .clk(clk),
        .rst_n(rst_n),
        .wake_timer(wake_timer),
        .stress_event(stress_event),
        .leaf_output(leaf_output),
        .leaf_valid(leaf_valid),
        .state(state),
        .domain2_pwr_en(domain2_pwr_en),
        .domain3_pwr_en(domain3_pwr_en),
        .sensor_en(sensor_en),
        .decde_en(decde_en),
        .csa_en(csa_en),
        .dtree_en(dtree_en),
        .comm_en(comm_en)
    );

    always #10 clk = ~clk;

    task step;
        input [7:0] phase;
        input wake;
        input stress;
        input valid;
        input [1:0] severity;
        input [1:0] expected_state;
        reg [6:0] expected_enables;
        reg [6:0] actual_enables;
        begin
            @(negedge clk);
            wake_timer = wake;
            stress_event = stress;
            leaf_valid = valid;
            leaf_output = {severity, 2'b00};

            @(posedge clk);
            #1;
            case (expected_state)
                `IPM_SLEEP:   expected_enables = 7'b0000000;
                `IPM_MONITOR: expected_enables = 7'b1100000;
                `IPM_WARNING: expected_enables = 7'b1111100;
                `IPM_CRITICAL: expected_enables = 7'b1111111;
                default:      expected_enables = 7'bxxxxxxx;
            endcase
            actual_enables = {
                sensor_en, decde_en, domain2_pwr_en, csa_en, dtree_en,
                domain3_pwr_en, comm_en
            };
            if (state !== expected_state || actual_enables !== expected_enables) begin
                $display(
                    "FAIL cycle=%0d phase=%0d state=%b expected=%b enables=%b expected_enables=%b",
                    cycle_count + 1, phase, state, expected_state,
                    actual_enables, expected_enables
                );
                $fatal(1, "IPM state workload did not follow the expected state/output contract");
            end

            cycle_count = cycle_count + 1;
            state_counts[state] = state_counts[state] + 1;
            $fdisplay(
                trace_file,
                "%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d",
                cycle_count, phase, state, wake_timer, stress_event, leaf_valid,
                leaf_output[3:2], sensor_en, decde_en, domain2_pwr_en, csa_en,
                dtree_en, domain3_pwr_en, comm_en
            );
        end
    endtask

    integer i;
    initial begin
        state_counts[0] = 0;
        state_counts[1] = 0;
        state_counts[2] = 0;
        state_counts[3] = 0;

        trace_file = $fopen("sim/power_characterization/state_trace.csv", "w");
        if (trace_file == 0)
            $fatal(1, "Could not open sim/power_characterization/state_trace.csv");

        $fdisplay(
            trace_file,
            "cycle,phase,state_code,wake_timer,stress_event,leaf_valid,leaf_severity,sensor_en,decde_en,domain2_pwr_en,csa_en,dtree_en,domain3_pwr_en,comm_en"
        );
        $dumpfile("build/power_characterization/ipm_state_workload.vcd");
        $dumpvars(0, tb_ipm_state_workload);

        step(0, 0, 0, 0, 0, `IPM_SLEEP);
        step(0, 0, 0, 0, 0, `IPM_SLEEP);
        @(negedge clk);
        rst_n = 1'b1;

        // SLEEP hold, then a one-cycle wake into MONITOR.
        for (i = 0; i < 12; i = i + 1)
            step(1, 0, 0, 0, 0, `IPM_SLEEP);
        step(2, 1, 0, 0, 0, `IPM_MONITOR);
        for (i = 0; i < 15; i = i + 1)
            step(3, 0, 0, 0, 0, `IPM_MONITOR);

        // Trigger WARNING and hold it with invalid leaf outputs.
        step(4, 0, 1, 0, 0, `IPM_WARNING);
        for (i = 0; i < 15; i = i + 1)
            step(5, 0, 0, 0, 0, `IPM_WARNING);

        // Escalate to CRITICAL, then recover to WARNING.
        step(6, 0, 0, 1, 3, `IPM_CRITICAL);
        for (i = 0; i < 15; i = i + 1)
            step(7, 0, 0, 1, 3, `IPM_CRITICAL);
        step(8, 0, 0, 1, 2, `IPM_WARNING);

        // Hold WARNING, then supply the two valid normal results required
        // by the implemented exit hysteresis.
        for (i = 0; i < 3; i = i + 1)
            step(9, 0, 0, 1, 2, `IPM_WARNING);
        step(10, 0, 0, 1, 0, `IPM_WARNING);
        step(11, 0, 0, 1, 0, `IPM_MONITOR);
        for (i = 0; i < 15; i = i + 1)
            step(12, 0, 0, 0, 0, `IPM_MONITOR);

        if (state_counts[0] != 14 || state_counts[1] != 32 ||
            state_counts[2] != 21 || state_counts[3] != 16)
            $fatal(
                1,
                "Unexpected state sample counts SLEEP=%0d MONITOR=%0d WARNING=%0d CRITICAL=%0d",
                state_counts[0], state_counts[1], state_counts[2], state_counts[3]
            );

        $fclose(trace_file);
        $display(
            "WORKLOAD PASSED cycles=%0d sleep=%0d monitor=%0d warning=%0d critical=%0d",
            cycle_count, state_counts[0], state_counts[1], state_counts[2], state_counts[3]
        );
        $finish;
    end
endmodule
