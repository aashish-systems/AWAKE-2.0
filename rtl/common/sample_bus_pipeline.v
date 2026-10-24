module sample_bus_pipeline #(
    parameter WIDTH = 48
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire [WIDTH-1:0] sample_in,
    output reg  [WIDTH-1:0] sample_out
);

    reg [WIDTH-1:0] sample_stage1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_stage1 <= {WIDTH{1'b0}};
            sample_out    <= {WIDTH{1'b0}};
        end else begin
            sample_stage1 <= sample_in;
            sample_out    <= sample_stage1;
        end
    end

endmodule
