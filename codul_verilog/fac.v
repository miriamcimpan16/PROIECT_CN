module fac(
    input x, 
    input y, 
    input c_in, 
    output z, 
    output c_out
);
    // Logica pentru Suma (z) si Carry Out (c_out)
    assign z = x ^ y ^ c_in; 
    assign c_out = (x & y) | (c_in & (x ^ y));
endmodule


