module crop_stress_accelerator_isolated (
    input wire clk,
    input wire rst_n,
    input wire enable,
    input wire sample_valid,
    input wire [7:0] moisture,
    input wire [7:0] leaf_temp,
    input wire [7:0] humidity,
    input wire [7:0] air_temp,
    input wire [7:0] light,
    input wire [7:0] w_moisture,
    input wire [7:0] w_leaftemp,
    input wire [7:0] w_humidity,
    input wire [7:0] w_airtemp,
    input wire [7:0] w_light,
    input wire [3:0] shift_factor,
    output wire [7:0] stress_score,
    output wire score_valid
);

    wire [7:0] iso_moisture  = enable ? moisture   : 8'd0;
    wire [7:0] iso_leaf_temp = enable ? leaf_temp  : 8'd0;
    wire [7:0] iso_humidity  = enable ? humidity   : 8'd0;
    wire [7:0] iso_air_temp  = enable ? air_temp   : 8'd0;
    wire [7:0] iso_light     = enable ? light      : 8'd0;

    wire [7:0] iso_w_moisture = enable ? w_moisture : 8'd0;
    wire [7:0] iso_w_leaftemp = enable ? w_leaftemp : 8'd0;
    wire [7:0] iso_w_humidity = enable ? w_humidity : 8'd0;
    wire [7:0] iso_w_airtemp  = enable ? w_airtemp  : 8'd0;
    wire [7:0] iso_w_light    = enable ? w_light    : 8'd0;

    crop_stress_accelerator u_candidate (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .sample_valid(sample_valid),
        .moisture(iso_moisture),
        .leaf_temp(iso_leaf_temp),
        .humidity(iso_humidity),
        .air_temp(iso_air_temp),
        .light(iso_light),
        .w_moisture(iso_w_moisture),
        .w_leaftemp(iso_w_leaftemp),
        .w_humidity(iso_w_humidity),
        .w_airtemp(iso_w_airtemp),
        .w_light(iso_w_light),
        .shift_factor(shift_factor),
        .stress_score(stress_score),
        .score_valid(score_valid)
    );

endmodule
