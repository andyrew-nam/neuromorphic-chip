`timescale 1ns/1ns

$dumpfile("UCSB-tb.vcd");
$dumpvars(0, testbench);

module testbench;
  reg clk;
  reg n1, n2, n3;
  wire n7, n8;

  // Instantiate the spiking network
  spiking_network uut (
    .clk(clk),
    .n1(n1),
    .n2(n2),
    .n3(n3),
    .n7(n7),
    .n8(n8)
  );

  // Clock generation (10ns period)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Input spike patterns (40-bit sequences)
  reg [39:0] pattern1_n1 = 40'b0000000000111110000000000111110000000000;
  reg [39:0] pattern1_n2 = 40'b0000011111000000000011111000000000000000;
  reg [39:0] pattern1_n3 = 40'b1111100000000001111100000000001111100000;

  reg [39:0] pattern2_n1 = 40'b1111100111110011111001111100111110011111;
  reg [39:0] pattern2_n2 = 40'b0000011000001100000110000011000001100000;
  reg [39:0] pattern2_n3 = 40'b1111100000000001111100000000001111100000;

  reg [39:0] pattern3_n1 = 40'b0000011000001100000110000011000001100000;
  reg [39:0] pattern3_n2 = 40'b1100000000110000000011000000001100000000;
  reg [39:0] pattern3_n3 = 40'b0000011000001100000110000011000001100000;

  reg [39:0] pattern4_n1 = 40'b1010101010101010101010101010101010101010;
  reg [39:0] pattern4_n2 = 40'b0101010101010101010101010101010101010101;
  reg [39:0] pattern4_n3 = 40'b0000011000001100000110000011000001100000;

  // Task to run one 40-cycle test
  task run_test_case(input [39:0] p1, input [39:0] p2, input [39:0] p3, input integer test_num);
    integer i;
    begin
      $display("==== TEST CASE %0d START ====", test_num);
      for (i = 0; i < 40; i = i + 1) begin
        n1 = p1[39 - i];
        n2 = p2[39 - i];
        n3 = p3[39 - i];
        #10; // wait for rising edge of clk
        $display("Cycle %0d | n1=%b n2=%b n3=%b || n7=%b n8=%b", i, n1, n2, n3, n7, n8);
      end
      $display("==== TEST CASE %0d END ====\n", test_num);
    end
  endtask

  // Run all tests
  initial begin
    $dumpfile("spiking_network_tb.vcd");
    $dumpvars(0, testbench);

    // Wait some time before starting
    n1 = 0; n2 = 0; n3 = 0;
    #20;

    run_test_case(pattern1_n1, pattern1_n2, pattern1_n3, 1);
    run_test_case(pattern2_n1, pattern2_n2, pattern2_n3, 2);
    run_test_case(pattern3_n1, pattern3_n2, pattern3_n3, 3);
    run_test_case(pattern4_n1, pattern4_n2, pattern4_n3, 4);

    $finish;
  end
endmodule

