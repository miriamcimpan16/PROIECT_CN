// Modul: counter.v


module counter #(
    parameter BITS = 3      // Numarul de biti necesari (3 biti duc pâna la 7)
)(
    input wire clk,
    input wire reset,
    input wire clear,
    input wire increment,
    input wire [BITS-1:0] limit, 
    output reg done
);

    reg [BITS-1:0] count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            done <= 0;
        end
        else if (clear) begin
            count <= 0;
            done <= 0;
        end
        else if (increment) begin
            if (count == limit - 1) begin
                count <= count + 1;
                done <= 1'b1; // am atins limita
            end
            else if (count < limit) begin
                count <= count + 1;
                done <= 1'b0;
            end
        end
    end

endmodule
