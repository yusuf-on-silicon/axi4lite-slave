module B #(
)(
    input  wire                 clk        ,         //clock
    input  wire                 resetn     ,         //resetn - logic activated when low - active low 
     
    output wire                 BVALID     ,         //flag   - tells master ready to send     |
    output wire[1:0]            BRESP      ,         //output - data from slave to master      |---> handshake
    output wire                 BRESPREADY ,         //output - data from slave to master      |---> handshake
    input  wire                 BREADY     ,         //flag   - tells slave ready to receive   | 
      
    input  wire                 WRESPREADY ,         //flag   - tells when feedback comes      
    input  wire[1:0]            WRESP                //flag   - tells when feedback comes      
);

//FINITE STATE MACHINE - FSM
parameter IDLE = 2'b00 ;
parameter SEND = 2'b01 ;
parameter DONE = 2'b10 ;
reg[1:0] currentState,nextState ;

//OUTPUT SIGNALS AND FLAGS
reg      bvalidReg     = 0 ;                    //drive - indicate slave status to send 
reg[1:0] brespReg      = 0 ;                    //drive - feedback output driver from inside always  (drive BRESP)
reg      brespreadyReg = 0 ;                    //drive - feedback ready output driver from inside always (drive WREADY)

//INTERNAL STORAGE AND SIGNALS  
reg      wrespreadyReg = 0 ;                    //flag - collect feedback response status from memory
reg[1:0] wrespReg      = 0 ;                    //reg  - collect feedback response from memory

//-----------------LOGIC-----------------------------------------------------------------//
// CURRENT STATE UPDATE                         //updates actual state at clock
always @(posedge clk or negedge resetn) begin                 
    if(!resetn) begin
        currentState <= IDLE ;
    end else begin
        currentState <= nextState ;             //clean division into 3 blocks, 1 updates states, the other 
    end                                         //decides states, the third performs functions inside that states
end

// NEXT STATE LOGIC                             //updates the next state when ever situation 
always @(*) begin                               //allows and handling of errors
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
        default: nextState = IDLE ;             //default fallback
    endcase
end

//CURRENT STATE LOGIC                           //sequential logic to take place at clock
always @(posedge clk or negedge resetn) begin                     //intervals driven by current state.
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

assign BRESP      = brespReg       ;                  //drive - used for Handshake with master  
assign BRESPREADY = brespreadyReg  ;                  //drive - send out address to memory
assign BVALID     = bvalidReg      ;                  //drive - send out strobe to memory

endmodule

/*
---------------FEATURES---------------------------------


MEMORY INTEFCE - 
    input  wire                  WEN    ,
    input  wire[ADDR_WIDTH-1:0]  AWADDR ,
    input  wire[STRB_WIDTH-1:0]  WSTRB  ,
    input  wire[DATA_WIDTH-1:0]  WDATA  ,
    output wire[1:0]             WRESP  ,       (used here) 
    output wire                  WDONE  ,       (used here)
*/