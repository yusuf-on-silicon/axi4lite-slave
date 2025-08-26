module AW #(
parameter ADDR_WIDTH = 5  
)(
    input  wire                 clk       ,         //clock
    input  wire                 resetn    ,         //reset - logic activated when low - active low 
    
    input  wire                 AWVALID   ,         //flag   - tells input ready to come      |
    input  wire[ADDR_WIDTH-1:0] AWADDR    ,         //input  - data from master to slave      |---> handshake
    output wire                 AWREADY   ,         //flag   - tells input ready to receive   | 
     
    input  wire                 BRESPREADY,         //flag   - tells when feedback comes      
    input  wire[1:0]            BRESP     ,         //input  - data write feedback from memory
     
    input  wire                 DATAREADY ,         //flag   - tells data to write is ready
    output wire                 ADDRREADY ,         //flag   - tells address to write on is ready

    output wire[ADDR_WIDTH-1:0] AWOUT               //output - actual address to memory
);

//FINITE STATE MACHINE - FSM
parameter IDLE  = 2'b00 ;
parameter WRITE = 2'b01 ;
parameter DONE  = 2'b10 ;
reg[1:0] currentState,nextState ; 

//INTERNAL SIGNALS AND FLAGS
reg                 addrReady  = 0 ;        //flag  - indicate address is ready to begin write 
reg                 awreadyReg = 0 ;        //drive - wire connectivity from inside always (drive AWREADY)
reg[ADDR_WIDTH-1:0] awaddrReg  = 0 ;        //reg   - stores address from master then assign to output

// CURRENT STATE UPDATE                     //updates actual state at clock
always @(posedge clk) begin                 
    if(!resetn) begin
        awaddrReg    <= 0    ;
        currentState <= IDLE ;
        addrReady    <= 0    ;
    end else begin
        currentState <= nextState ;
    end
end

// NEXT STATE LOGIC                         //updates the next state when ever situation 
always @(*) begin                           //allows and handling of errors
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

//CURRENT STATE LOGIC                               //sequential logic to take place at clock
always @(posedge clk) begin                         //intervals driven by current state.
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

assign AWREADY   = awreadyReg ;                     //drive - used for Handshake with master  
assign AWOUT     = awaddrReg  ;                     //drive - send out address to memory
assign ADDRREADY = addrReady  ;                     //drive - indicate address is ready to write

endmodule

/*
---------------FEATURES---------------------------------
    - directly connected with memory and master
    - uses 2 sequential blocks and 1 combinatinoal block
    - 

IMPLEMENTED USING  3 SEPARATE LOGIC BLOCKS  TO KEEP THINGS 
CLEAN, MANAGEABLE AND STRICTLY DISTINGUISH BLOCK FUNCTIONS
The blocks  being 2  sequential and 1  combinational,  the 
sequential blocks update according to the clocks and performs
the actual logic at approprtiate times like when writing
*/