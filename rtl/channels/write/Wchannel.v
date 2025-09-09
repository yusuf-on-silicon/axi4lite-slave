module W #(
parameter DATA_WIDTH = 32 ,
parameter STRB_WIDTH = 4  
)(
    input  wire                 clk       ,         //clock
    input  wire                 resetn    ,         //reset - logic activated when low - active low 
    
    input  wire                 WVALID    ,         //input  - flag input ready              |
    input  wire[DATA_WIDTH-1:0] WDATA     ,         //input  - data from master to slave     |---> handshake
    input  wire[STRB_WIDTH-1:0] WSTRB     ,         //input  - srobe from master to slave    |
    output wire                 WREADY    ,         //output - flag master, ready to receive | 
     
    input  wire                 BRESPREADY,         //input  - flag tells when feedback valid      
    input  wire[1:0]            BRESP     ,         //input  - feedback from Bchannel
     
    input  wire                 ADDRREADY ,         //input  - flag AWchannel is ready
    output wire                 DATAREADY ,         //output - flag Slave, Wchannel is ready

    output wire[DATA_WIDTH-1:0] WDATAOUT  ,         //output - send data to memory
    output wire[DATA_WIDTH-1:0] WSTRBOUT            //output - send data strobe to memory
);

//FINITE STATE MACHINE - FSM
parameter IDLE  = 2'b00 ;
parameter WRITE = 2'b01 ;
parameter DONE  = 2'b10 ;
reg[1:0] currentState,nextState ;

//INTERNAL SIGNALS AND FLAGS
reg[DATA_WIDTH-1:0] wdataReg  = 0 ;         //drive - WDATAOUT  (temp storage of data    )
reg[STRB_WIDTH-1:0] wstrbReg  = 0 ;         //drive - WSTRBOUT  (temp storage of strb    )
reg                 dataReady = 0 ;         //drive - DATAREADY (indicate W channel ready)
reg                 wreadyReg = 0 ;         //drive - WREADY    (indicate ready for write)

//Sequential - State Register
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

//Combinational - Next State Logic
always @(*) begin
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
                      2'b00: nextState = IDLE         ;    //OKAY   - successful
                      2'b01: nextState = WRITE        ;    //SLVERR - internal issue, re-attempt
                      2'b10: nextState = IDLE         ;    //EXOKAY - used for axi4-full, irrelevant here
                      2'b11: nextState = currentState ;    //DECERR - wrong address receieved, re-collect address
                    default: nextState = IDLE         ;    //default fallback
                endcase
            end else begin
                nextState = currentState ;      //stay here if feedback not received
            end
        end
        default: nextState = IDLE ;             //default fallback
    endcase
end

//Sequential - Output Logic
always @(posedge clk) begin
    dataReady <= 0 ;                                                 
    case (currentState)
        WRITE: begin
            wdataReg  <= WDATA ;
            wstrbReg  <= WSTRB ;
            dataReady <= 1     ;
        end
    endcase
end

//Output Drivers
assign WREADY    = wreadyReg ;                  //drive - used for Handshake with master  
assign WDATAOUT  = wdataReg  ;                  //drive - send out address to memory
assign WSTRBOUT  = wstrbReg  ;                  //drive - send out strobe to memory
assign DATAREADY = dataReady ;                  //drive - indicate address is ready to write

endmodule
