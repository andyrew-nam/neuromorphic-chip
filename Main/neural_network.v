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

  
