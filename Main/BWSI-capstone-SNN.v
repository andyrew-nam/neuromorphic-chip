`timescale 1ns / 1ns

// Simple spiking neuron model with leak and threshold
module spike_neuron_model (
    input wire clk,
    input wire [9:0] weighted_sum,   // increased bitwidth to 10 bits
    output reg n_out
);
    // Use signed for potential to handle underflow properly
    reg signed [10:0] V_i;           // membrane potential (signed)
    localparam signed V_rest = 6;
    localparam signed V_leak = 1;
    localparam signed V_thresh = 14;

    initial begin
        V_i = V_rest;
        n_out = 0;
    end

    always @(posedge clk) begin
        n_out <= 0;
        // Integrate input and leak
        V_i <= V_i + $signed(weighted_sum) - V_leak;

        if (V_i >= V_thresh) begin
            V_i <= V_rest;
            n_out <= 1;
        end else if (V_i < V_rest) begin
            V_i <= V_rest;
        end
    end
endmodule

// Weighted sum accumulator with flattened weight input
module weighted_sum_accumulator #(
    parameter N_INPUTS = 208
)(
    input wire [N_INPUTS-1:0] inputs,           // input spikes (1-bit each)
    input wire [3*N_INPUTS-1:0] weights_flat,  // packed weights: 3 bits per input
    output reg [9:0] sum                        // wider sum output
);
    integer i;
    reg [2:0] weight_i;
    reg [9:0] acc;

    always @(*) begin
        acc = 0;
        for (i = 0; i < N_INPUTS; i = i + 1) begin
            weight_i = weights_flat[3*i +: 3]; // extract 3 bits per weight
            if (inputs[i])
                acc = acc + weight_i;
        end
        sum = acc;
    end
endmodule

// Top-level spiking network module
module spiking_network #(
    parameter N_INPUTS = 208,
    parameter N_HIDDEN = 40,
    parameter N_OUTPUTS = 4
)(
    input wire clk,
    input wire [N_INPUTS-1:0] inputs,
    input wire [3*N_INPUTS*N_HIDDEN-1:0] w_input_hidden_flat,  // flattened weights input->hidden
    input wire [3*N_HIDDEN*N_OUTPUTS-1:0] w_hidden_output_flat, // flattened weights hidden->output
    output wire [N_OUTPUTS-1:0] outputs
);

    // Hidden and output neuron spikes
    wire [N_HIDDEN-1:0] hidden;
    wire [N_OUTPUTS-1:0] out_wires;
    assign outputs = out_wires;

    genvar h;
    generate
        for (h = 0; h < N_HIDDEN; h = h + 1) begin : hidden_layer
            wire [9:0] acc_hidden;
            
            // Slice flattened weights for this hidden neuron (3 bits * N_INPUTS)
            // weights from inputs to this hidden neuron are contiguous
            wire [3*N_INPUTS-1:0] w_h;
            assign w_h = w_input_hidden_flat[h*3*N_INPUTS +: 3*N_INPUTS];

            weighted_sum_accumulator #(
                .N_INPUTS(N_INPUTS)
            ) acc_hidden_unit (
                .inputs(inputs),
                .weights_flat(w_h),
                .sum(acc_hidden)
            );

            spike_neuron_model hidden_neuron (
                .clk(clk),
                .weighted_sum(acc_hidden),
                .n_out(hidden[h])
            );
        end
    endgenerate

    genvar o;
    generate
        for (o = 0; o < N_OUTPUTS; o = o + 1) begin : output_layer
            wire [9:0] acc_output;

            // Slice weights for this output neuron (3 bits * N_HIDDEN)
            wire [3*N_HIDDEN-1:0] w_o;
            assign w_o = w_hidden_output_flat[o*3*N_HIDDEN +: 3*N_HIDDEN];

            weighted_sum_accumulator #(
                .N_INPUTS(N_HIDDEN)
            ) acc_output_unit (
                .inputs(hidden),
                .weights_flat(w_o),
                .sum(acc_output)
            );

            spike_neuron_model output_neuron (
                .clk(clk),
                .weighted_sum(acc_output),
                .n_out(out_wires[o])
            );
        end
    endgenerate

endmodule
