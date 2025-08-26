module W #(
parameter DATA_WIDTH = 32 ,
parameter STRB_WIDTH = 4  
)(
    input  wire                 clk       ,         //clock
    input  wire                 resetn    ,         //reset - logic activated when low - active low 
    
    input  wire                 WVALID    ,         //flag   - tells input ready to come      |
    input  wire[DATA_WIDTH-1:0] WDATA     ,         //input  - data from master to slave      |---> handshake
    input  wire[STRB_WIDTH-1:0] WSTRB     ,         //input  - srobe from master to slave     |
    output wire                 WREADY    ,         //flag   - tells input ready to receive   | 
     
    input  wire                 BRESPREADY,         //flag   - tells when feedback comes      
    input  wire[1:0]            BRESP     ,         //input  - data write feedback from memory
     
    input  wire                 ADDRREADY ,         //flag   - tells address to write on is ready
    output wire                 DATAREADY ,         //flag   - tells data to write is ready

    output wire[DATA_WIDTH-1:0] WDATAOUT  ,         //output - actual data to memory
    output wire[DATA_WIDTH-1:0] WSTRBOUT            //output - actual data strobe to memory
);

//FINITE STATE MACHINE - FSM
parameter IDLE  = 2'b00 ;
parameter WRITE = 2'b01 ;
parameter DONE  = 2'b10 ;
reg[1:0] currentState,nextState ;

//INTERNAL SIGNALS AND FLAGS
reg                 dataReady = 0 ;         //flag  - indicate address is ready to begin write 
reg                 wreadyReg = 0 ;         //drive - wire connectivity from inside always (drive WREADY)
reg[DATA_WIDTH-1:0] wdataReg  = 0 ;         //reg   - stores data from master then assign to output
reg[STRB_WIDTH-1:0] wstrbReg  = 0 ;         //reg   - stores strb from master then assign to output

// CURRENT STATE UPDATE                     //updates actual state at clock
always @(posedge clk) begin                 
    if(!resetn) begin
        currentState <= IDLE ;
        wdataReg     <= 0    ;
        wstrbReg     <= 0    ;
        dataReady    <= 0    ;
        wreadyReg    <= 0    ;
    end else begin
        currentState <= nextState ;
    end
end

// NEXT STATE LOGIC                         //updates the next state when ever situation 
always @(*) begin                           //allows and handling of errors
    nextState = currentState ;
    wreadyReg = 0            ;
    case (currentState)
        IDLE: begin
            wreadyReg = 1;
            if (WVALID && wreadyReg) begin
                nextState = WRITE  ;
            end
        end
        WRITE: begin
            if (dataReady && ADDRREADY) begin
                nextState = DONE   ;                                   
            end
        end
        DONE: begin 
            if (BRESPREADY) begin
                case (BRESP) 
                      2'b00: nextState = IDLE          ;    //OKAY   - successful
                      2'b01: nextState = WRITE         ;    //SLVERR - internal issue, re-attempt
                      2'b10: nextState = IDLE          ;    //EXOKAY - used for axi4-full, irrelevant here
                      2'b11: nextState = currentState  ;    //DECERR - wrong address receieved, re-collect address
                    default: nextState = IDLE          ;    //default fallback
                endcase
            end else begin
                nextState = currentState ;      //stay here if feedback not received
            end
        end
        default: nextState = IDLE ;             //default fallback
    endcase
end

//CURRENT STATE LOGIC                           //sequential logic to take place at clock
always @(posedge clk) begin                     //intervals driven by current state.
    dataReady <= 0 ;                                                 
    case (currentState)
        WRITE: begin
            wdataReg  <= WDATA ;
            wstrbReg  <= WSTRB ;
            dataReady <= 1     ;
        end
    endcase
end

assign WREADY    = wreadyReg ;                  //drive - used for Handshake with master  
assign WDATAOUT  = wdataReg  ;                  //drive - send out address to memory
assign WSTRBOUT  = wstrbReg  ;                  //drive - send out strobe to memory
assign DATAREADY = dataReady ;                  //drive - indicate address is ready to write

endmodule

/*
---------------FEATURES---------------------------------

*/