`timescale 1ns / 1ps

module hazard_detector_nn_tb;

    reg clk;
    reg rst;
    reg start;
    reg [7:0] image_pixels [0:207];
    wire done;
    wire [15:0] outputs [0:14];

    // Instantiate your hazard_detector_nn module
    hazard_detector_nn uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .image_pixels(image_pixels),
        .done(done),
        .outputs(outputs)
    );

    integer i;

    // Clock generation: 10ns period (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Reset and initialize
        rst = 1;
        start = 0;

        // Initialize image_pixels with your data:
        image_pixels[0] = 8'd123;
        image_pixels[1] = 8'd146;
        image_pixels[2] = 8'd153;
        image_pixels[3] = 8'd150;
        image_pixels[4] = 8'd140;
        image_pixels[5] = 8'd136;
        image_pixels[6] = 8'd153;
        image_pixels[7] = 8'd143;
        image_pixels[8] = 8'd149;
        image_pixels[9] = 8'd159;
        image_pixels[10] = 8'd74;
        image_pixels[11] = 8'd70;
        image_pixels[12] = 8'd52;
        image_pixels[13] = 8'd32;
        image_pixels[14] = 8'd51;
        image_pixels[15] = 8'd61;
        image_pixels[16] = 8'd55;
        image_pixels[17] = 8'd59;
        image_pixels[18] = 8'd48;
        image_pixels[19] = 8'd42;
        image_pixels[20] = 8'd68;
        image_pixels[21] = 8'd69;
        image_pixels[22] = 8'd34;
        image_pixels[23] = 8'd158;
        image_pixels[24] = 8'd154;
        image_pixels[25] = 8'd27;
        image_pixels[26] = 8'd126;
        image_pixels[27] = 8'd121;
        image_pixels[28] = 8'd124;
        image_pixels[29] = 8'd148;
        image_pixels[30] = 8'd143;
        image_pixels[31] = 8'd138;
        image_pixels[32] = 8'd144;
        image_pixels[33] = 8'd137;
        image_pixels[34] = 8'd141;
        image_pixels[35] = 8'd154;
        image_pixels[36] = 8'd103;
        image_pixels[37] = 8'd80;
        image_pixels[38] = 8'd118;
        image_pixels[39] = 8'd66;
        image_pixels[40] = 8'd45;
        image_pixels[41] = 8'd48;
        image_pixels[42] = 8'd42;
        image_pixels[43] = 8'd34;
        image_pixels[44] = 8'd15;
        image_pixels[45] = 8'd25;
        image_pixels[46] = 8'd41;
        image_pixels[47] = 8'd35;
        image_pixels[48] = 8'd47;
        image_pixels[49] = 8'd82;
        image_pixels[50] = 8'd24;
        image_pixels[51] = 8'd5;
        image_pixels[52] = 8'd72;
        image_pixels[53] = 8'd130;
        image_pixels[54] = 8'd134;
        image_pixels[55] = 8'd149;
        image_pixels[56] = 8'd148;
        image_pixels[57] = 8'd149;
        image_pixels[58] = 8'd150;
        image_pixels[59] = 8'd134;
        image_pixels[60] = 8'd144;
        image_pixels[61] = 8'd160;
        image_pixels[62] = 8'd72;
        image_pixels[63] = 8'd50;
        image_pixels[64] = 8'd70;
        image_pixels[65] = 8'd37;
        image_pixels[66] = 8'd22;
        image_pixels[67] = 8'd56;
        image_pixels[68] = 8'd65;
        image_pixels[69] = 8'd39;
        image_pixels[70] = 8'd41;
        image_pixels[71] = 8'd38;
        image_pixels[72] = 8'd41;
        image_pixels[73] = 8'd53;
        image_pixels[74] = 8'd18;
        image_pixels[75] = 8'd0;
        image_pixels[76] = 8'd2;
        image_pixels[77] = 8'd8;
        image_pixels[78] = 8'd42;
        image_pixels[79] = 8'd141;
        image_pixels[80] = 8'd106;
        image_pixels[81] = 8'd60;
        image_pixels[82] = 8'd75;
        image_pixels[83] = 8'd131;
        image_pixels[84] = 8'd160;
        image_pixels[85] = 8'd146;
        image_pixels[86] = 8'd151;
        image_pixels[87] = 8'd159;
        image_pixels[88] = 8'd66;
        image_pixels[89] = 8'd47;
        image_pixels[90] = 8'd64;
        image_pixels[91] = 8'd31;
        image_pixels[92] = 8'd35;
        image_pixels[93] = 8'd58;
        image_pixels[94] = 8'd99;
        image_pixels[95] = 8'd79;
        image_pixels[96] = 8'd61;
        image_pixels[97] = 8'd49;
        image_pixels[98] = 8'd49;
        image_pixels[99] = 8'd48;
        image_pixels[100] = 8'd19;
        image_pixels[101] = 8'd6;
        image_pixels[102] = 8'd9;
        image_pixels[103] = 8'd11;
        image_pixels[104] = 8'd18;
        image_pixels[105] = 8'd69;
        image_pixels[106] = 8'd41;
        image_pixels[107] = 8'd4;
        image_pixels[108] = 8'd20;
        image_pixels[109] = 8'd27;
        image_pixels[110] = 8'd106;
        image_pixels[111] = 8'd140;
        image_pixels[112] = 8'd126;
        image_pixels[113] = 8'd165;
        image_pixels[114] = 8'd103;
        image_pixels[115] = 8'd74;
        image_pixels[116] = 8'd139;
        image_pixels[117] = 8'd89;
        image_pixels[118] = 8'd62;
        image_pixels[119] = 8'd108;
        image_pixels[120] = 8'd127;
        image_pixels[121] = 8'd53;
        image_pixels[122] = 8'd31;
        image_pixels[123] = 8'd46;
        image_pixels[124] = 8'd42;
        image_pixels[125] = 8'd42;
        image_pixels[126] = 8'd11;
        image_pixels[127] = 8'd3;
        image_pixels[128] = 8'd4;
        image_pixels[129] = 8'd7;
        image_pixels[130] = 8'd28;
        image_pixels[131] = 8'd29;
        image_pixels[132] = 8'd28;
        image_pixels[133] = 8'd25;
        image_pixels[134] = 8'd23;
        image_pixels[135] = 8'd23;
        image_pixels[136] = 8'd50;
        image_pixels[137] = 8'd71;
        image_pixels[138] = 8'd88;
        image_pixels[139] = 8'd150;
        image_pixels[140] = 8'd135;
        image_pixels[141] = 8'd111;
        image_pixels[142] = 8'd142;
        image_pixels[143] = 8'd141;
        image_pixels[144] = 8'd126;
        image_pixels[145] = 8'd97;
        image_pixels[146] = 8'd89;
        image_pixels[147] = 8'd112;
        image_pixels[148] = 8'd52;
        image_pixels[149] = 8'd61;
        image_pixels[150] = 8'd57;
        image_pixels[151] = 8'd49;
        image_pixels[152] = 8'd32;
        image_pixels[153] = 8'd10;
        image_pixels[154] = 8'd30;
        image_pixels[155] = 8'd61;
        image_pixels[156] = 8'd26;
        image_pixels[157] = 8'd29;
        image_pixels[158] = 8'd34;
        image_pixels[159] = 8'd37;
        image_pixels[160] = 8'd35;
        image_pixels[161] = 8'd59;
        image_pixels[162] = 8'd158;
        image_pixels[163] = 8'd184;
        image_pixels[164] = 8'd191;
        image_pixels[165] = 8'd197;
        image_pixels[166] = 8'd185;
        image_pixels[167] = 8'd191;
        image_pixels[168] = 8'd187;
        image_pixels[169] = 8'd182;
        image_pixels[170] = 8'd192;
        image_pixels[171] = 8'd156;
        image_pixels[172] = 8'd150;
        image_pixels[173] = 8'd186;
        image_pixels[174] = 8'd176;
        image_pixels[175] = 8'd167;
        image_pixels[176] = 8'd171;
        image_pixels[177] = 8'd67;
        image_pixels[178] = 8'd96;
        image_pixels[179] = 8'd123;
        image_pixels[180] = 8'd70;
        image_pixels[181] = 8'd51;
        image_pixels[182] = 8'd23;
        image_pixels[183] = 8'd26;
        image_pixels[184] = 8'd33;
        image_pixels[185] = 8'd30;
        image_pixels[186] = 8'd39;
        image_pixels[187] = 8'd107;
        image_pixels[188] = 8'd174;
        image_pixels[189] = 8'd193;
        image_pixels[190] = 8'd197;
        image_pixels[191] = 8'd197;
        image_pixels[192] = 8'd193;
        image_pixels[193] = 8'd190;
        image_pixels[194] = 8'd186;
        image_pixels[195] = 8'd177;
        image_pixels[196] = 8'd179;
        image_pixels[197] = 8'd192;
        image_pixels[198] = 8'd194;
        image_pixels[199] = 8'd182;
        image_pixels[200] = 8'd180;
        image_pixels[201] = 8'd174;
        image_pixels[202] = 8'd122;
        image_pixels[203] = 8'd82;
        image_pixels[204] = 8'd107;
        image_pixels[205] = 8'd99;
        image_pixels[206] = 8'd66;
        image_pixels[207] = 8'd48;

        // Release reset
        #20;
        rst = 0;

        // Start the neural network
        #20;
        start = 1;
        #10;
        start = 0;

        // Wait for done signal
        wait(done);

        // Display the output values
        $display("Neural Network Outputs:");
        for (i = 0; i < 15; i = i + 1) begin
            $display("Output[%0d] = %d (Q8.8 fixed point)", i, outputs[i]);
        end

        $stop;
    end

endmodule

