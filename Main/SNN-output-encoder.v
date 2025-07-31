module hazard_encoder (
    input [3:0] num_hazards,
    input [7:0] top    [0:15],
    input [7:0] left   [0:15],
    input [7:0] bottom [0:15],
    input [7:0] right  [0:15],
    output reg [15:0] vec1,
    output reg [15:0] vec2
);

    integer i, row, col;
    integer row_top, row_bottom;
    integer col_left, col_right;
    reg [4:0] cell_num;

    always @(*) begin
        vec1 = 16'b0;
        vec2 = 16'b0;

        for (i = 0; i < num_hazards; i = i + 1) begin
            for (row = 0; row < 4; row = row + 1) begin
                row_top = row * 2;
                row_bottom = row_top + 1;

                for (col = 0; col < 8; col = col + 1) begin
                    if (col < 6) begin
                        col_left = col * 3;
                        col_right = col_left + 2;
                    end else begin
                        col_left = 18 + (col - 6) * 4;
                        col_right = col_left + 3;
                    end

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
