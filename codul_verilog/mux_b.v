
// Modul: mux_b.v
// Descriere: Multiplexor care selecteaza ce valoare intra in portul B al sumatorului.

module mux_b #(
    parameter W = 9 // Setam parametru pe 9 biti
)(
    input wire [W-1:0] in_M,    // Valoarea din registrul M
    input wire c2,              // C2: 1 = facem o operatie, 0 = nu adunam nimic
    input wire c3,              // C3: 1 = alegem 2M, 0 = alegem M
    output wire [W-1:0] out_B   // Valoarea care pleaca spre sumator
);

    // 2M ->M deplasat cu o pozitie la stanga.
    // Concatenam primii 8 biti ai lui M cu un 0 la final.
    wire [W-1:0] in_2M = {in_M[W-2:0], 1'b0};

    // Logica de selectie
    assign out_B = (c2 == 1'b0) ? {W{1'b0}} :  // Daca C2 e 0, trimitem 0 (nu modificam A)
                   (c3 == 1'b1) ? in_2M :      // Daca C3 e 1, trimitem 2M
                                  in_M;        // Altfel, trimitem M simplu

endmodule
