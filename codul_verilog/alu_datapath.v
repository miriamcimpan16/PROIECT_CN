
// Modul: alu_datapath.v
// Descriere: Calea de date care conecteaza ALU, MUX-ul si Registrele.

module alu_datapath (
    input wire clk,
    input wire reset,
    input wire [1:0] op_code, 
    // Date de la exterior
    input wire [7:0] INBUS,
    output wire [7:0] OUTBUS_A,
    output wire [7:0] OUTBUS_Q,
    
    // Semnale de control primite de la Control Unit
    input wire c0, c0_prime, c1,
    input wire c2, c2_prime, c3, c3_prime,
    input wire c4, c5, c6, c7, c8,
    
    // Semnale de status trimise 
    output wire [2:0] booth_bits,
    output wire A_sign,
    output wire count_done
);

    // Fire interne pentru iesirile registrelor
    wire [8:0] A_out, Q_out, M_out;
    // Fire interne pentru intrarile viitoare ale registrelor 
    wire [8:0] next_A, next_Q;
    // Fire pentru sumator
    wire [8:0] B_mux_out, sum_out;
    wire carry_out;

   //MODULE
    // Multiplexorul 
    mux_b #(.W(9)) mux (
        .in_M(M_out),
        .c2(c2),
        .c3(c3),
        .out_B(B_mux_out)
    );

    // Sumatorul RCA
    adder_rca #(.W(9)) adder (
        .x(A_out),
        .y(B_mux_out),
        .carry_in(c4),      // C4 decide daca adunam (0) sau scadem (1)
        .sum(sum_out),
        .carry_out(carry_out)
    );

    // Contorul (C6 incrementeaza)
   // Fir intern pentru a decide limita contorului
    wire [2:0] current_limit;
    // 10 este inmultire (limita 3), altfel impartire (limita 7)
    assign current_limit = (op_code == 2'b10) ? 3'd3 : 3'd7;

    counter #(.BITS(3)) step_counter (
        .clk(clk),
        .reset(reset),
        .clear(c0 | c0_prime),
        .increment(c6),
        .limit(current_limit), // Trimitem limita calculata
        .done(count_done)
    );
   //LOGICA DE SHIFTARE
    
    assign next_A = (c2)       ? sum_out :                               // Incarcare de la ALU
                    (c5)       ? {A_out[8], A_out[8], A_out[8:2]} :      // ASR cu 2 biti (Booth)
                    (c2_prime) ? {A_out[7:0], Q_out[8]} :                // LSL cu 1 bit (Diviziune)
                    A_out;                                               // Default: pastreaza valoarea
                    
    assign next_Q = (c5)       ? {A_out[1:0], Q_out[8:2]} :              // ASR cu 2 biti (partea lui Q din Booth)
                    (c2_prime) ? {Q_out[7:0], 1'b0} :                    // LSL cu 1 bit (Diviziune)
                    (c3_prime) ? {Q_out[8:1], ~A_out[8]} :               // Corectarea bitului Q[0] din Diviziune
                    (c1)       ? {INBUS, 1'b0} :                         // Incarcare INBUS (Q[-1]=0)
                    Q_out;

   //REGISTRELE
    
    rgst #(.W(9)) reg_A (
        .clk(clk), .reset(reset), .clear((c0 | c0_prime) & (op_code == 2'b10 | op_code == 2'b11)),
        .load(c2 | c5 | c2_prime), // A se scrie daca facem Add, Shift Dreapta sau Shift Stanga
        .d_in(next_A),
        .q_out(A_out)
    );

    rgst #(.W(9)) reg_Q (
        .clk(clk), .reset(reset), .clear(1'b0), 
        .load(c1 | c5 | c2_prime | c3_prime), 
        .d_in(next_Q),
        .q_out(Q_out)
    );

    rgst #(.W(9)) reg_M (
        .clk(clk), .reset(reset), .clear(1'b0),
        .load(c0 | c0_prime), 
        .d_in({INBUS[7], INBUS}), // Extensie de semn de la 8 la 9 biti
        .q_out(M_out)
    );

    //CONECTAREA IESIRILOR
    
    // Trimitem statusul inapoi catre Control Unit
    assign booth_bits = Q_out[2:0]; // Q[1], Q[0], Q[-1]
    assign A_sign = A_out[8];
   // OUTBUS
    
    assign OUTBUS_A = A_out[7:0]; 
    assign OUTBUS_Q = (op_code == 2'b11)? Q_out[7:0] : Q_out[8:1]; // Q_out[0] este bitul Q[-1] pentru Booth, deci îl taiem

endmodule

