// Modul: alu.v 
// Descriere: Integreaza Unitatea de Control cu Calea de Date.

module alu (
    input wire clk,
    input wire reset,
    input wire begin_op,
    input wire [1:0] op_code,
    input wire [7:0] INBUS,
    output wire [7:0] OUTBUS_A,
    output wire [7:0] OUTBUS_Q,
    output wire end_op
);

    // Fire interne pentru a lega Control Unit de Datapath
    wire c0, c0_prime, c1, c2, c2_prime, c3, c3_prime, c4, c5, c6, c7, c8;
    wire [2:0] booth_bits;
    wire A_sign, count_done;

    // Instantiere Control Unit 
    control_unit ctrl (
        .clk(clk), .reset(reset), .begin_op(begin_op), .op_code(op_code),
        .booth_bits(booth_bits), .A_sign(A_sign), .count_done(count_done),
        .c0(c0), .c0_prime(c0_prime), .c1(c1), .c2(c2), .c2_prime(c2_prime),
        .c3(c3), .c3_prime(c3_prime), .c4(c4), .c5(c5), .c6(c6), .c7(c7), .c8(c8),
        .end_op(end_op)
    );

    // Instantiere Datapath 
    alu_datapath dp (
        .clk(clk), .reset(reset), .INBUS(INBUS),.op_code(op_code),
        .OUTBUS_A(OUTBUS_A), .OUTBUS_Q(OUTBUS_Q),
        .c0(c0), .c0_prime(c0_prime), .c1(c1), .c2(c2), .c2_prime(c2_prime),
        .c3(c3), .c3_prime(c3_prime), .c4(c4), .c5(c5), .c6(c6), .c7(c7), .c8(c8),
        .booth_bits(booth_bits), .A_sign(A_sign), .count_done(count_done)
    );

endmodule

