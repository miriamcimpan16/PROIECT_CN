module control_unit (
    input wire clk,
    input wire reset,
    input wire begin_op,
    input wire [1:0] op_code,
    
    input wire [2:0] booth_bits,
    input wire A_sign,
    input wire count_done,
    
    output reg c0, c0_prime, c1,
    output reg c2, c2_prime, c3, c3_prime,
    output reg c4, c5, c6, c7, c8,
    output reg end_op
);

    // Starile
    localparam IDLE         = 4'd0,
               INIT_M       = 4'd1,
               INIT_Q       = 4'd2,
               BOOTH_EVAL   = 4'd3,
               BOOTH_SHIFT  = 4'd4,
               DIV_SHIFT    = 4'd5,
               DIV_ADD_SUB  = 4'd6,
               DIV_UPDATE_Q = 4'd7,
               DIV_CORRECT  = 4'd8,
               ADD_FIRST    = 4'd9,  // Salveaza primul numar in A
               INIT_M_2     = 4'd10, // Citeste al doilea numar in M
               ADD_SUB_EXEC = 4'd11, // Executa calculul final
               FINISH       = 4'd12;

    reg [3:0] current_state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset) current_state <= IDLE;
        else current_state <= next_state;
    end

    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: if (begin_op) next_state = INIT_M;
            
            INIT_M: begin
                // Daca e MUL sau DIV, mergem normal. Daca e ADD/SUB, facem flow-ul special.
                if (op_code == 2'b10 | op_code == 2'b11) next_state = INIT_Q;
                else next_state = ADD_FIRST; 
            end
            
            INIT_Q: begin
                if (op_code == 2'b10) next_state = BOOTH_EVAL;
                else next_state = DIV_SHIFT;
            end

            // Flow Booth
            BOOTH_EVAL: next_state = BOOTH_SHIFT;
            BOOTH_SHIFT: if (count_done) next_state = FINISH; else next_state = BOOTH_EVAL;

            // Flow Diviziune
            DIV_SHIFT: next_state = DIV_ADD_SUB;
            DIV_ADD_SUB: next_state = DIV_UPDATE_Q;
            DIV_UPDATE_Q: if (count_done) next_state = DIV_CORRECT; else next_state = DIV_SHIFT;
            DIV_CORRECT: next_state = FINISH;

            // Flow Adunare/Scadere (3 pasi clari)
            ADD_FIRST: next_state = INIT_M_2;
            INIT_M_2: next_state = ADD_SUB_EXEC;
            ADD_SUB_EXEC: next_state = FINISH;

            FINISH: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    always @(*) begin
        {c0, c0_prime, c1, c2, c2_prime, c3, c3_prime, c4, c5, c6, c7, c8, end_op} = 13'b0;

        case (current_state)
            INIT_M: begin
                if (op_code == 2'b10) c0_prime = 1'b1; else c0 = 1'b1;                        
            end
            INIT_Q: c1 = 1'b1; 
            
            BOOTH_EVAL: begin
                case (booth_bits)
                    3'b001, 3'b010: begin c2 = 1'b1; c3 = 1'b0; end 
                    3'b011:         begin c2 = 1'b1; c3 = 1'b1; end 
                    3'b100:         begin c2 = 1'b1; c3 = 1'b1; c4 = 1'b1; end 
                    3'b101, 3'b110: begin c2 = 1'b1; c3 = 1'b0; c4 = 1'b1; end 
                    default:        begin c2 = 1'b0; end 
                endcase
            end
            BOOTH_SHIFT: begin c5 = 1'b1; c6 = 1'b1; end
            
            DIV_SHIFT: c2_prime = 1'b1; 
            DIV_ADD_SUB: begin c2 = 1'b1; if (A_sign == 1'b0) c4 = 1'b1; end
            DIV_UPDATE_Q: begin c3_prime = 1'b1; c6 = 1'b1; end
            DIV_CORRECT: if (A_sign == 1'b1) c2 = 1'b1; 

            
            ADD_FIRST: c2 = 1'b1; 
            INIT_M_2:  c0 = 1'b1; 
            ADD_SUB_EXEC: begin
                c2 = 1'b1; // Aduna A cu M
                if (op_code == 2'b01) c4 = 1'b1; // Daca e scadere, pune Carry=1
            end

            FINISH: begin c7 = 1'b1; c8 = 1'b1; end_op = 1'b1; end
        endcase
    end
endmodule
