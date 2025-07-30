module tb_block_pooling;

    reg clk = 0;
    always #5 clk = ~clk; // 100 MHz clock

    reg rst = 1;
    reg [7:0] pixel_in;
    reg valid_in = 0;
    reg new_frame = 0;

    wire [7:0] pixel_out;
    wire valid_out;

    // Instantiate the DUT
    block_pooling_1242x375_to_26x8 uut (
        .clk(clk),
        .rst(rst),
        .pixel_in(pixel_in),
        .valid_in(valid_in),
        .new_frame(new_frame),
        .pixel_out(pixel_out),
        .valid_out(valid_out)
    );

    integer infile, outfile, status;
    reg [7:0] mem [0:465749]; // 1242x375
    integer i;

    initial begin
        // Reset and open files
        rst = 1;
        #20 rst = 0;
        infile = $fopen("pixels.txt", "r");
        outfile = $fopen("output_pixels.txt", "w");

        // Load pixels from file
        for (i = 0; i < 465750; i = i + 1) begin
            status = $fscanf(infile, "%d\n", mem[i]);
        end

        // Start new frame
        new_frame = 1;
        #10;
        new_frame = 0;

        // Feed pixels in raster scan
        for (i = 0; i < 465750; i = i + 1) begin
            @(posedge clk);
            pixel_in = mem[i];
            valid_in = 1;
        end

        // Drain remaining outputs
        @(posedge clk);
        valid_in = 0;
        repeat (5000) begin
            @(posedge clk);
            if (valid_out) $fwrite(outfile, "%d\n", pixel_out);
        end

        $fclose(infile);
        $fclose(outfile);
        $finish;
    end
endmodule
