module B #(
)(
    input  wire                 clk        ,         //clock
    input  wire                 resetn     ,         //resetn - logic activated when low - active low 
     
    output wire                 BVALID     ,         //output - flag master, ready to send |
    output wire[1:0]            BRESP      ,         //output - send Feedback              |---> handshake
    output wire                 BRESPREADY ,         //output - flag sending feedback      |---> handshake
    input  wire                 BREADY     ,         //input  - flag ready to receive      | 
      
    input  wire                 WRESPREADY ,         //input  - flags when feedback comes      
    input  wire[1:0]            WRESP                //input  - receive feedback
);

//FINITE STATE MACHINE - FSM
parameter IDLE = 2'b00 ;
parameter SEND = 2'b01 ;
parameter DONE = 2'b10 ;
reg[1:0] currentState,nextState ;

//OUTPUT SIGNALS AND FLAGS
reg[1:0] brespReg      = 0 ;                    //drive - BRESP      (temp storage feedback     )
reg      bvalidReg     = 0 ;                    //drive - BVALID     (flags master ready to send)
reg      brespreadyReg = 0 ;                    //drive - BRESPREADY (flags slave ready to send )

//INTERNAL STORAGE AND SIGNALS  
reg[1:0] wrespReg      = 0 ;                    //input - WRESP      (temp storage of feedback from memory )
reg      wrespreadyReg = 0 ;                    //input - WRESPREADY (flags when feedback comes from memory)

//Sequential - State Register
always @(posedge clk or negedge resetn) begin                 
    if(!resetn) begin
        currentState <= IDLE ;
    end else begin
        currentState <= nextState ;
    end
end

//Combinational - Next State Logic
always @(*) begin
    nextState = currentState ;
    bvalidReg = 0            ;
    case (currentState)
        IDLE: begin
            if (wrespreadyReg) begin
                nextState = SEND ;
            end
        end
        SEND: begin
            bvalidReg = 1 ;
            if (brespreadyReg) begin
                nextState = IDLE ;                                   
            end
        end
        default: nextState = IDLE ;
    endcase
end

//Sequential - Output Logic
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        bvalidReg     <= 0 ;
        brespReg      <= 0 ;
        brespreadyReg <= 0 ;
        wrespreadyReg <= 0 ;
        wrespReg      <= 0 ;
    end else begin
        brespreadyReg <= 0 ;
        brespReg      <= 0 ;
        wrespreadyReg <= 0 ;
        case (currentState)
            IDLE: begin
                if (WRESPREADY) begin
                    wrespreadyReg <= 1 ;
                    wrespReg  <= WRESP ;
                end
            end
            SEND: begin
                if (BREADY && bvalidReg) begin
                    brespreadyReg <= 1   ;
                    brespReg <= wrespReg ;
                end
            end
            default: nextState <= IDLE;
        endcase
    end
end

//Output Drivers
assign BRESP      = brespReg       ;                  //drive - used for Handshake with master  
assign BRESPREADY = brespreadyReg  ;                  //drive - send out address to memory
assign BVALID     = bvalidReg      ;                  //drive - send out strobe to memory

endmodule
