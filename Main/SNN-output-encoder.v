module hazard_encoder (
    input [3:0] num_hazards,
    input [10:0] top    [0:15],    // up to 2047, enough for 375
    input [10:0] left   [0:15],    // up to 2047, enough for 1240
    input [10:0] bottom [0:15],
    input [10:0] right  [0:15],
    output reg [15:0] vec1,
    output reg [15:0] vec2
);

    integer i, row, col;
    reg [5:0] cell_num;

    // Grid cell dimensions
    localparam IMG_WIDTH  = 1240;
    localparam IMG_HEIGHT = 375;

    localparam CELL_WIDTH  = IMG_WIDTH / 8;   // 155 pixels
    localparam CELL_HEIGHT = IMG_HEIGHT / 4;  // 93.75 pixels

    integer row_top, row_bottom, col_left, col_right;

    always @(*) begin
        vec1 = 16'b0;
        vec2 = 16'b0;

        for (i = 0; i < num_hazards; i = i + 1) begin
            for (row = 0; row < 4; row = row + 1) begin
                row_top    = row * CELL_HEIGHT;
                row_bottom = (row + 1) * CELL_HEIGHT - 1;

                for (col = 0; col < 8; col = col + 1) begin
                    col_left  = col * CELL_WIDTH;
                    col_right = (col + 1) * CELL_WIDTH - 1;

                    // Check if the hazard overlaps this cell
                    if (!(bottom[i] < row_top || top[i] > row_bottom ||
                          right[i] < col_left || left[i] > col_right)) begin
                        cell_num = row * 8 + col;
                        if (cell_num < 16)
                            vec1[cell_num] = 1'b1;
                        else
                            vec2[cell_num - 16] = 1'b1;
                    end
                end
            end
        end
    end
endmodule
