// Direction-aware temporal crossover fusion.
//
// Contract:
//  * A crossover on channel j is held "recent" for window_size+1 clock cycles
//    counting the crossover cycle itself (window_size = 0 -> crossover cycle
//    only, i.e. coincident crossovers). All 8 bits of window_size are honoured.
//    A new crossover on a channel reloads its window and its direction.
//  * fusion_score = number of recent crossovers matching fusion_pattern.
//  * stress_event is a ONE-CYCLE pulse when the qualified count first reaches
//    vote_threshold. It re-arms only after the count falls below threshold.
//    vote_threshold = 0 disables events; values 6..7 can never be reached.

module fusion_unit(
    input  wire       clk,
    input  wire       rst_n,

    input  wire [4:0] cross_flag_vector,
    input  wire [4:0] trend_direction_vector,
    input  wire [9:0] fusion_pattern,
    input  wire [2:0] vote_threshold,
    input  wire [7:0] window_size,

    output reg  [2:0] fusion_score,
    output reg        stress_event
);

    reg [7:0] window_ctr [0:4];
    reg [4:0] recent_cross;
    reg [4:0] recent_direction;
    reg       event_active;

    integer j;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            recent_cross     <= 5'b0;
            recent_direction <= 5'b0;
            for (j = 0; j < 5; j = j + 1)
                window_ctr[j] <= 8'd0;
        end else begin
            for (j = 0; j < 5; j = j + 1) begin
                if (cross_flag_vector[j]) begin
                    recent_cross[j]     <= 1'b1;
                    recent_direction[j] <= trend_direction_vector[j];
                    window_ctr[j]       <= window_size;
                end else if (window_ctr[j] != 8'd0) begin
                    window_ctr[j] <= window_ctr[j] - 8'd1;
                end else begin
                    recent_cross[j]     <= 1'b0;
                    recent_direction[j] <= 1'b0;
                end
            end
        end
    end

    reg [4:0] qualified_cross;
    integer k;
    always @(*) begin
        for (k = 0; k < 5; k = k + 1) begin
            case (fusion_pattern[2*k +: 2])
                2'b00:   qualified_cross[k] = recent_cross[k];                        // Don't care
                2'b01:   qualified_cross[k] = recent_cross[k] &  recent_direction[k]; // Rising
                2'b10:   qualified_cross[k] = recent_cross[k] & ~recent_direction[k]; // Falling
                default: qualified_cross[k] = 1'b0;                                   // Excluded
            endcase
        end
    end

    wire [2:0] count = {2'b00, qualified_cross[0]} + {2'b00, qualified_cross[1]} +
                       {2'b00, qualified_cross[2]} + {2'b00, qualified_cross[3]} +
                       {2'b00, qualified_cross[4]};

    wire over_threshold = (vote_threshold != 3'd0) && (count >= vote_threshold);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fusion_score <= 3'd0;
            stress_event <= 1'b0;
            event_active <= 1'b0;
        end else begin
            fusion_score <= count;
            event_active <= over_threshold;
            stress_event <= over_threshold & ~event_active;
        end
    end

endmodule
