`timescale 1ns / 1ps

module hazard_detector_nn (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [7:0] image_pixels [0:207],  // 208 pixels, 8-bit grayscale
    output reg done,
    output reg [15:0] outputs [0:14]        // 15 outputs Q8.8 fixed-point
);

    // Sizes
    localparam IN_SIZE = 208;
    localparam H1_SIZE = 128;
    localparam H2_SIZE = 64;
    localparam OUT_SIZE = 15;

    // Fixed-point Q8.8 signed format
    // 16 bits: [15] sign, [14:8] integer, [7:0] fraction

    // State machine states
    typedef enum reg [2:0] {
        IDLE,
        LAYER1_NEURON,
        LAYER1_MAC,
        LAYER1_RELU,
        LAYER2_NEURON,
        LAYER2_MAC,
        LAYER2_RELU,
        LAYER3_NEURON,
        LAYER3_MAC,
        LAYER3_SIGMOID,
        DONE_STATE
    } state_t;

    state_t state;

    // Counters for neurons and inputs
    reg [7:0] neuron_idx;    // Enough for max 128 neurons
    reg [7:0] input_idx;

    // Accumulator for MAC (32-bit signed to avoid overflow)
    reg signed [31:0] acc;

    // Intermediate neuron output storage
    reg signed [15:0] layer1_out [0:H1_SIZE-1];
    reg signed [15:0] layer2_out [0:H2_SIZE-1];

    // Weights and biases
    reg signed [15:0] fc1_weights [0:H1_SIZE-1][0:IN_SIZE-1];
    reg signed [15:0] fc1_biases  [0:H1_SIZE-1];

    reg signed [15:0] fc2_weights [0:H2_SIZE-1][0:H1_SIZE-1];
    reg signed [15:0] fc2_biases  [0:H2_SIZE-1];

    reg signed [15:0] fc3_weights [0:OUT_SIZE-1][0:H2_SIZE-1];
    reg signed [15:0] fc3_biases  [0:OUT_SIZE-1];

    // Output registers
    reg signed [15:0] fc3_out [0:OUT_SIZE-1];

    // ReLU activation
    function signed [15:0] relu;
        input signed [31:0] x;
        begin
            if (x < 0)
                relu = 0;
            else if (x > 32767)
                relu = 32767;
            else
                relu = x[15:0]; // Keep lower 16 bits after MAC shift (you may need shift)
        end
    endfunction

    // Sigmoid approximation (hard sigmoid)
    function signed [15:0] sigmoid_approx;
        input signed [15:0] x;
        reg signed [15:0] val;
        begin
            // scale input from Q8.8 to approx range and clip
            // simple: f(x) = max(0, min(1, 0.5 + x/4))
            val = 16'd128 + (x >>> 2);
            if (val < 0)
                sigmoid_approx = 0;
            else if (val > 16'd256)
                sigmoid_approx = 16'd256;
            else
                sigmoid_approx = val;
        end
    endfunction

    // Main sequential logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
            neuron_idx <= 0;
            input_idx <= 0;
            acc <= 0;
        end else begin
            case (state)

                IDLE: begin
                    done <= 0;
                    neuron_idx <= 0;
                    input_idx <= 0;
                    acc <= 0;
                    if (start)
                        state <= LAYER1_NEURON;
                end

                // Layer 1: compute each neuron MAC sequentially
                LAYER1_NEURON: begin
                    acc <= (fc1_biases[neuron_idx] <<< 8);  // bias scaled to Q16.16 for accumulation
                    input_idx <= 0;
                    state <= LAYER1_MAC;
                end

                LAYER1_MAC: begin
                    acc <= acc + $signed(fc1_weights[neuron_idx][input_idx]) * $signed({8'd0, image_pixels[input_idx]});
                    if (input_idx == IN_SIZE - 1)
                        state <= LAYER1_RELU;
                    else
                        input_idx <= input_idx + 1;
                end

                LAYER1_RELU: begin
                    layer1_out[neuron_idx] <= relu(acc >>> 8); // shift back from Q16.16 to Q8.8
                    if (neuron_idx == H1_SIZE - 1) begin
                        neuron_idx <= 0;
                        state <= LAYER2_NEURON;
                    end else
                        neuron_idx <= neuron_idx + 1;
                end

                // Layer 2: same sequential MAC for hidden layer 2
                LAYER2_NEURON: begin
                    acc <= (fc2_biases[neuron_idx] <<< 8);
                    input_idx <= 0;
                    state <= LAYER2_MAC;
                end

                LAYER2_MAC: begin
                    acc <= acc + $signed(fc2_weights[neuron_idx][input_idx]) * $signed(layer1_out[input_idx]);
                    if (input_idx == H1_SIZE - 1)
                        state <= LAYER2_RELU;
                    else
                        input_idx <= input_idx + 1;
                end

                LAYER2_RELU: begin
                    layer2_out[neuron_idx] <= relu(acc >>> 8);
                    if (neuron_idx == H2_SIZE - 1) begin
                        neuron_idx <= 0;
                        state <= LAYER3_NEURON;
                    end else
                        neuron_idx <= neuron_idx + 1;
                end

                // Layer 3: output layer neurons
                LAYER3_NEURON: begin
                    acc <= (fc3_biases[neuron_idx] <<< 8);
                    input_idx <= 0;
                    state <= LAYER3_MAC;
                end

                LAYER3_MAC: begin
                    acc <= acc + $signed(fc3_weights[neuron_idx][input_idx]) * $signed(layer2_out[input_idx]);
                    if (input_idx == H2_SIZE - 1)
                        state <= LAYER3_SIGMOID;
                    else
                        input_idx <= input_idx + 1;
                end

                LAYER3_SIGMOID: begin
                    fc3_out[neuron_idx] <= sigmoid_approx(acc[23:8]); // use middle bits for Q8.8
                    if (neuron_idx == OUT_SIZE - 1) begin
                        // Copy outputs to output port
                        for (input_idx = 0; input_idx < OUT_SIZE; input_idx = input_idx + 1) begin
                            outputs[input_idx] <= fc3_out[input_idx];
                        end
                        done <= 1;
                        state <= DONE_STATE;
                    end else
                        neuron_idx <= neuron_idx + 1;
                end

                DONE_STATE: begin
                    if (!start)
                        state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

    initial begin
        // Initialize weights and biases here
        // Example: fc1_weights[0][0] = 16'sd12; // 0.046875 in Q8.8 fixed-point
        // You must fill these arrays with your trained weights and biases scaled and rounded to Q8.8
    end

endmodule
