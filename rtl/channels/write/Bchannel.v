module Bchannel #(
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
parameter IDLE = 1'b0 ;
parameter SEND = 1'b1 ;
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
    case (currentState)
        IDLE: begin
            if (wrespreadyReg) begin
                nextState = SEND ;
            end
        end
        SEND: begin
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
        case (currentState)
            IDLE: begin
                brespReg      <= 0 ;
                brespreadyReg <= 0 ;
                bvalidReg     <= 0 ;
                if (WRESPREADY) begin
                    wrespreadyReg <= 1     ;
                    wrespReg      <= WRESP ;
                end
            end
            SEND: begin
                wrespreadyReg <= 0 ;
                bvalidReg     <= 1 ;
                if (BREADY && bvalidReg) begin
                    brespreadyReg <= 1   ;
                    brespReg <= wrespReg ;
                end
            end
        endcase
    end
end

//Output Drivers
assign BRESP      = brespReg       ;                  //drive - used for Handshake with master  
assign BRESPREADY = brespreadyReg  ;                  //drive - send out address to memory
assign BVALID     = bvalidReg      ;                  //drive - send out strobe to memory

endmodule
