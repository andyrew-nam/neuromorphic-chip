`timescale 1ns / 1ns

module testbench;
    reg [3:0] num_hazards;
    reg [10:0] top    [0:15];
    reg [10:0] left   [0:15];
    reg [10:0] bottom [0:15];
    reg [10:0] right  [0:15];
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
        // Number of hazards
        num_hazards = 4'd2;

        // Hazard 0: Top-left, should affect cell (0,0)
        top[0]    = 11'd10;
        left[0]   = 11'd20;
        bottom[0] = 11'd200;
        right[0]  = 11'd300;

        // Hazard 1: Bottom-right, should affect cells in row 3, columns 6-7
        top[1]    = 11'd100;
        left[1]   = 11'd900;
        bottom[1] = 11'd300;
        right[1]  = 11'd1230;

        // Fill remaining hazards with zeros
        for (i = 2; i < 16; i = i + 1) begin
            top[i]    = 11'd0;
            left[i]   = 11'd0;
            bottom[i] = 11'd0;
            right[i]  = 11'd0;
        end

        // Wait for output to stabilize
        #10;

        // Display output vectors
        $display("vec1 = %b", vec1);
        $display("vec2 = %b", vec2);

        $finish;
    end
endmodule
