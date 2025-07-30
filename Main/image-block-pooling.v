module block_pooling_1242x375_to_26x8 (
    input wire clk,
    input wire rst,
    input wire [7:0] pixel_in,
    input wire valid_in,
    input wire new_frame,

    output reg [7:0] pixel_out,
    output reg valid_out
);
    // Image and block size constants
    localparam IMG_WIDTH  = 1242;
    localparam IMG_HEIGHT = 375;
    localparam BLOCK_W = 48;
    localparam BLOCK_H = 47;
    localparam BLOCK_PIXELS = BLOCK_W * BLOCK_H; // 2256

    // Internal row/col counters
    reg [11:0] col = 0;
    reg [9:0] row = 0;

    // Block accumulators
    reg [31:0] block_sum = 0;
    reg [11:0] block_count = 0;

    // Output control
    reg [5:0] out_col = 0;
    reg [3:0] out_row = 0;

    always @(posedge clk or posedge rst) begin
        if (rst || new_frame) begin
            col <= 0;
            row <= 0;
            block_sum <= 0;
            block_count <= 0;
            valid_out <= 0;
            out_col <= 0;
            out_row <= 0;
        end else if (valid_in) begin
            // Accumulate pixels into block sum
            block_sum <= block_sum + pixel_in;
            block_count <= block_count + 1;

            // Advance column
            if (col == IMG_WIDTH - 1) begin
                col <= 0;
                row <= row + 1;
            end else begin
                col <= col + 1;
            end

            // When block is full, output average
            if (block_count == BLOCK_PIXELS - 1) begin
                pixel_out <= block_sum / BLOCK_PIXELS;
                valid_out <= 1;
                block_sum <= 0;
                block_count <= 0;

                // Track output image location (optional)
                if (out_col == 25) begin // 26 output cols
                    out_col <= 0;
                    out_row <= out_row + 1;
                end else begin
                    out_col <= out_col + 1;
                end
            end else begin
                valid_out <= 0;
            end
        end else begin
            valid_out <= 0;
        end
    end
endmodule

