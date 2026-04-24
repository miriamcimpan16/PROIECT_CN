// Modul: rgst.v
// Descriere: Registru cu incarcare paralela

module rgst #(
    parameter W = 9 // A si M au latimea pe 9 biti
)(
    input wire clk,           // Semnalul de ceas
    input wire reset,         // Reset asincron 
    input wire clear,         // Stergere sincrona (C0 pentru A)
    input wire load,          // Semnal de activare a scrierii
    input wire [W-1:0] d_in,  // Datele care intra in registru
    output reg [W-1:0] q_out  // Datele memorate care ies din registru
);

    // Bloc secvential: se executa doar la frontul crescator al ceasului
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            q_out <= {W{1'b0}}; 
        end 
        else if (clear) begin
            q_out <= {W{1'b0}}; // Comanda de clear(C0)
        end 
        else if (load) begin
            q_out <= d_in;      // Daca load e 1, memoreaza datele noi
        end
        // Daca nici clear, nici load nu sunt 1, registrul isi pastreaza valoarea
    end

endmodule

