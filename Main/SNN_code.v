`timescale 1ns/1ns

module spike_neuron_model (clk, n_in1, n_in2, n_in3, w1, w2, w3, n_out);
  // Neuron Input Declarations
  input wire clk;
  input wire [2:0] w1;
  input wire [2:0] w2;
  input wire [2:0] w3;
  input wire n_in1;
  input wire n_in2;
  input wire n_in3;

  // Neuron output
  output wire n_out;

  // Neuron constants (for now)
  reg [4:0] V_rest = 6;
  reg [4:0] V_leak = 1;
  reg K_syn = 1;
  reg [4:0] V_thresh = 14;
  reg [4:0] V_i = 6;
  reg n_i_reg = 0;

  // Neuron behavior
  always @(posedge clk) begin
    n_i_reg <= 0;

    // Math equation used (LIF model below)
    V_i <= V_i + K_syn * (w1 * n_in1 + w2 * n_in2 + w3 * n_in3) - V_leak;

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

module spiking_network (clk, n1, n2, n3, n7, n8);
  // Network inputs
  input wire clk;
  input wire n1;
  input wire n2;
  input wire n3;

  // Hidden layer neurons
  wire n4;
  wire n5;
  wire n6;

  // Neuron outputs
  output wire n7;
  output wire n8;

  // Network synaptic weights
  reg [2:0] w14 = 3;
  reg [2:0] w15 = 1;
  reg [2:0] w16 = 4;
  reg [2:0] w24 = 3;
  reg [2:0] w25 = 2;
  reg [2:0] w26 = 3;
  reg [2:0] w34 = 2;
  reg [2:0] w35 = 3;
  reg [2:0] w36 = 4;
  reg [2:0] w47 = 3;
  reg [2:0] w48 = 2;
  reg [2:0] w57 = 2;
  reg [2:0] w58 = 4;
  reg [2:0] w67 = 3;
  reg [2:0] w68 = 2;


  spike_neuron_model neuron4 (
    .clk (clk),
    .n_in1 (n1),
    .n_in2 (n2),
    .n_in3 (n3),
    .w1 (w14),
    .w2 (w24),
    .w3 (w34),
    .n_out (n4)
  );

  spike_neuron_model neuron5 (
    .clk (clk),
    .n_in1 (n1),
    .n_in2 (n2),
    .n_in3 (n3),
    .w1 (w15),
    .w2 (w25),
    .w3 (w35),
    .n_out (n5)
  );

  spike_neuron_model neuron6 (
    .clk (clk),
    .n_in1 (n1),
    .n_in2 (n2),
    .n_in3 (n3),
    .w1 (w16),
    .w2 (w26),
    .w3 (w36),
    .n_out (n6)
  );

  spike_neuron_model neuron7 (
    .clk (clk),
    .n_in1 (n4),
    .n_in2 (n5),
    .n_in3 (n6),
    .w1 (w47),
    .w2 (w57),
    .w3 (w67),
    .n_out (n7)
  );

  spike_neuron_model neuron8 (
    .clk (clk),
    .n_in1 (n4),
    .n_in2 (n5),
    .n_in3 (n6),
    .w1 (w48),
    .w2 (w58),
    .w3 (w68),
    .n_out (n8)
  );

endmodule
