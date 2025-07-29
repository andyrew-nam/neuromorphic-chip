`timescale 1ns/1ns

// =====================
// Single Neuron Module
// =====================
module spike_neuron_model (
  input wire clk,
  input wire [7:0] weighted_sum, // updated to handle total input sum
  output wire n_out
);

  reg [4:0] V_rest = 6;
  reg [4:0] V_leak = 1;
  reg [4:0] V_thresh = 14;
  reg [4:0] V_i = 6;
  reg n_i_reg = 0;

  always @(posedge clk) begin
    n_i_reg <= 0;
    V_i <= V_i + weighted_sum - V_leak;
    if (V_i >= V_thresh) begin
      V_i <= V_rest;
      n_i_reg <= 1;
    end
    if (V_i < V_rest) begin
      V_i <= V_rest;
    end
  end

  assign n_out = n_i_reg;
endmodule

// =====================
// Spiking Neural Network (Fully Connected)
// =====================
module spiking_network #(parameter N_INPUTS=208, N_HIDDEN=40, N_OUTPUTS=4) (
  input wire clk,
  input wire [N_INPUTS-1:0] inputs,
  output wire [N_OUTPUTS-1:0] outputs
);

  // Hidden layer and output layer wires
  wire [N_HIDDEN-1:0] hidden;
  wire [N_OUTPUTS-1:0] out_wires;
  assign outputs = out_wires;

  // Synaptic weight declarations
  reg [2:0] w_input_hidden[N_INPUTS-1:0][N_HIDDEN-1:0];
  reg [2:0] w_hidden_output[N_HIDDEN-1:0][N_OUTPUTS-1:0];

  // Hidden layer instantiation (fully connected)
  genvar h;
  generate
    for (h = 0; h < N_HIDDEN; h = h + 1) begin : hidden_layer
      reg [7:0] acc_hidden;
      integer i;
      always @(*) begin
        acc_hidden = 0;
        for (i = 0; i < N_INPUTS; i = i + 1) begin
          acc_hidden = acc_hidden + (w_input_hidden[i][h] * inputs[i]);
        end
      end
      spike_neuron_model hidden_neuron (
        .clk(clk),
        .weighted_sum(acc_hidden),
        .n_out(hidden[h])
      );
    end
  endgenerate

  // Output layer instantiation (fully connected)
  genvar o;
  generate
    for (o = 0; o < N_OUTPUTS; o = o + 1) begin : output_layer
      reg [7:0] acc_output;
      integer j;
      always @(*) begin
        acc_output = 0;
        for (j = 0; j < N_HIDDEN; j = j + 1) begin
          acc_output = acc_output + (w_hidden_output[j][o] * hidden[j]);
        end
      end
      spike_neuron_model output_neuron (
        .clk(clk),
        .weighted_sum(acc_output),
        .n_out(out_wires[o])
      );
    end
  endgenerate

endmodule
