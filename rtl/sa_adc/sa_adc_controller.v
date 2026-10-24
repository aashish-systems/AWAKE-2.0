module sa_adc_controller (
    input wire clk,
    input wire rst_n,
    input wire sample_valid,
    input wire [7:0] moisture,
    input wire [7:0] leaf_temp,
    input wire [7:0] humidity,
    input wire [7:0] air_temp,
    input wire [7:0] light,
    input wire [2:0] fusion_score,
    input wire [7:0] battery_level,

    input wire [7:0] moisture_t1,
    input wire [7:0] moisture_t2,
    input wire [7:0] leaf_t1,
    input wire [7:0] leaf_t2,
    input wire [7:0] humidity_t1,
    input wire [7:0] humidity_t2,
    input wire [7:0] air_t1,
    input wire [7:0] air_t2,
    input wire [7:0] light_t1,
    input wire [7:0] light_t2,
    input wire [7:0] b_crit,
    input wire [7:0] b_low,

    output reg [9:0] adc_mode_vector,
    output reg mode_valid
);

    function [1:0] get_channel_mode;
        input [7:0] sample_value;
        input [2:0] f_score;
        input [7:0] t1;
        input [7:0] t2;
        input [7:0] batt;
        input [7:0] bcrit;
        input [7:0] blow;
        reg [1:0] base_mode;
        reg [1:0] escalated_mode;
        begin
            if (sample_value < t1)
                base_mode = 2'b00;
            else if (sample_value < t2)
                base_mode = 2'b01;
            else
                base_mode = 2'b10;

            if (f_score >= 3'd2 && base_mode == 2'b01)
                escalated_mode = 2'b10;
            else
                escalated_mode = base_mode;

            if (batt < bcrit)
                get_channel_mode = 2'b00;
            else if (batt < blow)
                get_channel_mode = (escalated_mode > 2'b01) ? 2'b01 : escalated_mode;
            else
                get_channel_mode = escalated_mode;
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adc_mode_vector <= 10'b00_00_00_00_00;
            mode_valid <= 1'b0;
        end else if (sample_valid) begin
            adc_mode_vector <= {
                get_channel_mode(light, fusion_score, light_t1, light_t2, battery_level, b_crit, b_low),
                get_channel_mode(air_temp, fusion_score, air_t1, air_t2, battery_level, b_crit, b_low),
                get_channel_mode(humidity, fusion_score, humidity_t1, humidity_t2, battery_level, b_crit, b_low),
                get_channel_mode(leaf_temp, fusion_score, leaf_t1, leaf_t2, battery_level, b_crit, b_low),
                get_channel_mode(moisture, fusion_score, moisture_t1, moisture_t2, battery_level, b_crit, b_low)
            };
            mode_valid <= 1'b1;
        end
    end

endmodule
