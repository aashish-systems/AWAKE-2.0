`include "agrisense_defs.vh"
// Self-checking ipm_fsm bench: reset, wake, warning, critical, recovery,
// hysteresis, invalid-leaf handling, simultaneous inputs.
module tb_ipm_fsm;
    reg clk = 0, rst_n = 0, wake = 0, sev = 0, lv = 0;
    reg [3:0] leaf = 0;
    wire [1:0] st;
    wire d2, d3, sen, dec, csa, dt, com;
    integer errors = 0;

    ipm_fsm dut(.clk(clk), .rst_n(rst_n), .wake_timer(wake), .stress_event(sev),
        .leaf_output(leaf), .leaf_valid(lv), .state(st), .domain2_pwr_en(d2),
        .domain3_pwr_en(d3), .sensor_en(sen), .decde_en(dec), .csa_en(csa),
        .dtree_en(dt), .comm_en(com));

    always #5 clk = ~clk;
    task tick; @(negedge clk); endtask

    // enables {sensor, decde, d2, csa, dtree, d3, comm} per docs/fsm.md
    task expect_state(input [1:0] es, input [8*40-1:0] msg);
        reg [6:0] exp_en, got;
        begin
            case (es)
                `IPM_SLEEP:   exp_en = 7'b0000000;
                `IPM_MONITOR: exp_en = 7'b1100000;
                `IPM_WARNING: exp_en = 7'b1111100;
                default:      exp_en = 7'b1111111;
            endcase
            got = {sen, dec, d2, csa, dt, d3, com};
            if (st !== es || got !== exp_en) begin
                $display("FAIL: %0s : state=%0d en=%b expected state=%0d en=%b", msg, st, got, es, exp_en);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        tick; expect_state(`IPM_SLEEP, "in reset");
        rst_n = 1; tick; tick; expect_state(`IPM_SLEEP, "idle after reset");
        sev = 1; tick; sev = 0; expect_state(`IPM_SLEEP, "event ignored in SLEEP");
        leaf = 4'b1100; lv = 1; tick; expect_state(`IPM_SLEEP, "leaf ignored in SLEEP");
        lv = 0; leaf = 0;

        wake = 1; tick; wake = 0; expect_state(`IPM_MONITOR, "wake");
        wake = 1; tick; wake = 0; expect_state(`IPM_MONITOR, "repeat wake stays MONITOR");
        leaf = 4'b1100; lv = 1; tick; expect_state(`IPM_MONITOR, "leaf ignored in MONITOR");
        lv = 0; leaf = 0;
        sev = 1; tick; sev = 0; expect_state(`IPM_WARNING, "event to WARNING");

        lv = 0; leaf = 4'b0000; repeat (5) tick; expect_state(`IPM_WARNING, "invalid NORMAL held");
        if (dut.exit_ctr !== 2'd0) begin $display("FAIL: invalid leaf counted"); errors = errors + 1; end
        leaf = 4'b1111; tick; expect_state(`IPM_WARNING, "invalid CRITICAL held");

        lv = 1; leaf = 4'b0100; tick; expect_state(`IPM_WARNING, "sev01 holds");
        leaf = 4'b1000; tick; expect_state(`IPM_WARNING, "sev10 holds");

        leaf = 4'b1101; tick; expect_state(`IPM_CRITICAL, "sev11 to CRITICAL");
        tick; expect_state(`IPM_CRITICAL, "CRITICAL holds");
        lv = 0; leaf = 0; tick; expect_state(`IPM_CRITICAL, "invalid leaf holds CRITICAL");
        lv = 1; leaf = 4'b1000; tick; expect_state(`IPM_WARNING, "recovery to WARNING");

        leaf = 4'b0000; tick; expect_state(`IPM_WARNING, "1st NORMAL holds");
        leaf = 4'b0100; tick; expect_state(`IPM_WARNING, "interrupt resets");
        leaf = 4'b0000; tick; expect_state(`IPM_WARNING, "NORMAL #1");
        lv = 0; tick; expect_state(`IPM_WARNING, "invalid gap does not exit");
        lv = 1; tick; expect_state(`IPM_MONITOR, "NORMAL #2 to MONITOR");

        sev = 1; tick; sev = 0; leaf = 4'b1100; tick; expect_state(`IPM_CRITICAL, "re-escalate");
        rst_n = 0; #1; expect_state(`IPM_SLEEP, "async reset from CRITICAL");
        tick; rst_n = 1; lv = 0; leaf = 0; tick; expect_state(`IPM_SLEEP, "post-reset SLEEP");

        wake = 1; sev = 1; tick; wake = 0; sev = 0; expect_state(`IPM_MONITOR, "simultaneous wake+event");

        if (errors == 0) $display("TEST PASSED tb_ipm_fsm");
        else $fatal(1, "tb_ipm_fsm: %0d errors", errors);
        $finish;
    end
endmodule
