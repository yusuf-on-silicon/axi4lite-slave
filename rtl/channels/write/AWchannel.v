module AW #(
parameter ADDR_WIDTH = 5  
)(
    input  wire                 clk       ,         //clock
    input  wire                 resetn    ,         //reset  - logic activated when low - active low 
    
    input  wire                 AWVALID   ,         //input  - flag input ready               |
    input  wire[ADDR_WIDTH-1:0] AWADDR    ,         //input  - data from master to slave      |---> handshake
    output wire                 AWREADY   ,         //output - flag master, ready to receive  | 
     
    input  wire                 BRESPREADY,         //input  - flag tells when feedback valid      
    input  wire[1:0]            BRESP     ,         //input  - feedback from Bchannel
     
    input  wire                 DATAREADY ,         //input  - flag Wchannel is ready
    output wire                 ADDRREADY ,         //output - flag Slave, AWchannel is ready 

    output wire[ADDR_WIDTH-1:0] AWADDROUT               //output - send address to memory
);

//FINITE STATE MACHINE - FSM
parameter IDLE  = 2'b00 ;
parameter WRITE = 2'b01 ;
parameter DONE  = 2'b10 ;
reg[1:0] currentState,nextState ; 

//INTERNAL SIGNALS AND FLAGS
reg[ADDR_WIDTH-1:0] awaddrReg  = 0 ;        //drive - AWADDROUT     (temp storage of address   )
reg                 addrReady  = 0 ;        //drive - ADDRREADY (indicates AW channel ready)
reg                 awreadyReg = 0 ;        //drive - AWREADY   (indicate ready for write  )

//Sequential - State Register
always @(posedge clk or negedge resetn) begin                 
    if(!resetn) begin
        currentState <= IDLE ;
        awaddrReg    <= 0    ;
        addrReady    <= 0    ;
    end else begin
        currentState <= nextState ;
    end
end

//Combinational - Next State Logic
always @(*) begin                          
    nextState = currentState ;
    awreadyReg = 0           ;
    case (currentState)
        IDLE: begin
            awreadyReg = 1;
            if (AWVALID) begin
                nextState = WRITE  ;
            end
        end
        WRITE: begin
            if (addrReady && DATAREADY) begin
                nextState = DONE   ;                                   
            end
        end
        DONE: begin 
            if (BRESPREADY) begin
                case (BRESP) 
                      2'b00: nextState = IDLE  ;    //OKAY   - successful
                      2'b01: nextState = WRITE ;    //SLVERR - internal issue, re-attempt
                      2'b10: nextState = IDLE  ;    //EXOKAY - used for axi4-full, irrelevant here
                      2'b11: nextState = IDLE  ;    //DECERR - wrong address receieved, re-collect address
                    default: nextState = IDLE  ;    //default fallback
                endcase
            end else begin
                nextState = currentState ;          //stay here if feedback not received
            end
        end
        default: nextState = IDLE ;                 //default fallback
    endcase
end

//Sequential - Output Logic
always @(posedge clk) begin
    case (currentState)
        WRITE: begin
            if (!addrReady) begin
                awaddrReg <= AWADDR ;
                addrReady <= 1      ;
            end
        end
        DONE: begin
            addrReady <= 0 ;
        end
    endcase
end

//Output Drivers
assign AWREADY   = awreadyReg ;                     //drive - used for Handshake with master  
assign AWADDROUT     = awaddrReg  ;                     //drive - send out address to memory
assign ADDRREADY = addrReady  ;                     //drive - indicate address is ready to write

endmodule
