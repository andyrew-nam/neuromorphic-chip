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

    // Instantiate the hazard_encoder module
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
        // Set number of hazards
        num_hazards = 4'd2;

        // Hazard 0: should hit top-left cell (row 0, col 0)
        top[0]    = 5'd0;
        left[0]   = 5'd0;
        bottom[0] = 5'd1;
        right[0]  = 5'd2;

        // Hazard 1: should hit bottom-right cell (row 3, col 7)
        top[1]    = 5'd6;
        left[1]   = 5'd23;
        bottom[1] = 5'd7;
        right[1]  = 5'd25;

        // Clear remaining hazards
        for (i = 2; i < 16; i = i + 1) begin
            top[i]    = 5'd0;
            left[i]   = 5'd0;
            bottom[i] = 5'd0;
            right[i]  = 5'd0;
        end

        // Wait for logic to settle
        #10;

        // Display outputs
        $display("vec1 = %b", vec1);  // bits 0–15
        $display("vec2 = %b", vec2);  // bits 16–31

        $finish;
    end
endmodule
