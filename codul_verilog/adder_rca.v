module adder_rca #(
    parameter W = 9
)(
    input [W - 1 : 0] x,
    input [W - 1 : 0] y,
    input carry_in, // 0 pentru adunare, 1 pentru scadere
    output [W - 1 : 0] sum,
    output carry_out
);

    // wire intern pentru a transporta carry-ul intre celule
    wire [W:0] c; 
    
    // Alocam carry_in initial in primul bit al vectorului de carry
    assign c[0] = carry_in;
    
    // Vector pentru y modificat (pentru operatia de scadere)
    wire [W - 1 : 0] y_mod;
    assign y_mod = y ^ {W{carry_in}};

    // Generam celulele Full Adder folosind o bucla generate
    genvar i;
    generate
        for (i = 0; i < W; i = i + 1) begin : gen_bit
            // Daca carry_in e 1, y_mod devine ~y (complement de 1)
            fac cell_fac(
                .x(x[i]),
                .y(y_mod[i]),
                .c_in(c[i]),
                .z(sum[i]),
                .c_out(c[i+1])
            );
        end
    endgenerate

    // Ultimul carry_out
    assign carry_out = c[W];

endmodule

