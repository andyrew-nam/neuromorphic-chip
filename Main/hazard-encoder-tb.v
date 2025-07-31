`timescale 1ns / 1ns

module testbench;
    reg [3:0] num_hazards;
    reg [7:0] top    [0:15];
    reg [7:0] left   [0:15];
    reg [7:0] bottom [0:15];
    reg [7:0] right  [0:15];
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
        // Initialize all hazard inputs to zero
        for (i = 0; i < 16; i = i + 1) begin
            top[i]    = 8'd0;
            left[i]   = 8'd0;
            bottom[i] = 8'd0;
            right[i]  = 8'd0;
        end

        // Test Case: 2 hazards
        num_hazards = 4'd2;

        // Hazard 0: in top-left
        top[0]    = 8'd0;
        left[0]   = 8'd0;
        bottom[0] = 8'd1;
        right[0]  = 8'd2;

        // Hazard 1: in bottom-right
        top[1]    = 8'd6;
        left[1]   = 8'd20;
        bottom[1] = 8'd7;
        right[1]  = 8'd25;

        #10; // wait for combinational logic

        $display("vec1 = %b", vec1);
        $display("vec2 = %b", vec2);

        $finish;
    end
endmodule
