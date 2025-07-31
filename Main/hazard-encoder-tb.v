`timescale 1ns / 1ns

module testbench;
    reg [3:0] num_hazards;
    reg [4:0] top    [0:15];
    reg [4:0] left   [0:15];
    reg [4:0] bottom [0:15];
    reg [4:0] right  [0:15];
    wire [15:0] vec1;
    wire [15:0] vec2;

    integer i;

    hazard_encoder uut (
        .num_hazards(num_hazards),
        .top(top),
        .left(left),
        .bottom(bottom),
        .right(right),
        .vec1(vec1),
        .vec2(vec2)
    );

    initial begin
        num_hazards = 4'd2;

        // Hazard 0: Covers rows 0–2, cols 0–1
        // Each cell is ~3 px wide × 2 px tall
        // So cols 0–1 → x = 0–5
        // rows 0–2 → y = 0–5
        top[0]    = 5'd1;
        left[0]   = 5'd1;
        bottom[0] = 5'd5;
        right[0]  = 5'd5;

        // Hazard 1: Covers rows 1–3, cols 5–7
        // cols 5–7 → x = 15–25
        // rows 1–3 → y = 2–7
        top[1]    = 5'd3;
        left[1]   = 5'd17;
        bottom[1] = 5'd7;
        right[1]  = 5'd25;

        // Clear the rest
        for (i = 2; i < 16; i = i + 1) begin
            top[i]    = 5'd0;
            left[i]   = 5'd0;
            bottom[i] = 5'd0;
            right[i]  = 5'd0;
        end

        #10;

        $display("vec1 = %b", vec1);
        $display("vec2 = %b", vec2);

        $finish;
    end
endmodule
