module AR #(
parameter ADDR_WIDTH = 5  
)(
    input  wire                 clk       ,         //clock
    input  wire                 resetn    ,         //reset - logic activated when low - active low 
    
    input  wire                 ARVALID   ,         //flag   - indicates master wants to send      |
    input  wire[ADDR_WIDTH-1:0] ARADDR    ,         //input  - data from master to slave           |---> handshake
    output wire                 ARREADY   ,         //flag   - tells master ready to receive       | 
     
    input  wire                 RRESPREADY,         //flag   - feedback status of memory      
    input  wire[1:0]            RRESP     ,         //input  - feedback input from memory
     
    output wire[ADDR_WIDTH-1:0] AROUT               //output - actual address to memory
);

//FINITE STATE MACHINE - FSM
parameter IDLE = 2'b00 ;
parameter READ = 2'b01 ;
parameter DONE = 2'b10 ;
reg[1:0] currentState,nextState ; 

//INTERNAL SIGNALS AND FLAGS
reg                 arreadyReg = 0 ;        //drive - wire connectivity from inside always (drive ARREADY)
reg                 addrReady  = 0 ;        //drive - wire connectivity from inside always (drive ARREADY)
reg[ADDR_WIDTH-1:0] araddrReg  = 0 ;        //reg   - stores address from master then assign to AROUT

// CURRENT STATE UPDATE                     //updates actual state at clock
always @(posedge clk or negedge resetn) begin                 
    if(!resetn) begin
        currentState <= IDLE ;
    end else begin
        currentState <= nextState ;
    end
end

// NEXT STATE LOGIC                         //updates the next state when ever situation 
always @(*) begin                           //allows and handling of errors
    nextState = currentState ;
    arreadyReg = 0           ;
    case (currentState)
        IDLE: begin
            arreadyReg = 1 ;
            if (ARVALID) begin
                nextState = READ ;
            end
        end
        READ: begin
            if (addrReady) begin
                nextState = DONE ;                                   
            end
        end
        DONE: begin 
            if (RRESPREADY) begin
                case (RRESP) 
                      2'b00: nextState = IDLE ;    //OKAY   - successful
                      2'b01: nextState = READ ;    //SLVERR - internal issue, re-attempt
                      2'b10: nextState = IDLE ;    //EXOKAY - used for axi4-full, irrelevant here
                      2'b11: nextState = IDLE ;    //DECERR - wrong address receieved, re-collect address
                    default: nextState = IDLE ;    //default fallback
                endcase
            end else begin
                nextState = currentState ;          //stay here if feedback not received
            end
        end
        default: nextState = IDLE ;                 //default fallback
    endcase
end

//CURRENT STATE LOGIC                               //sequential logic to take place at clock
always @(posedge clk or negedge resetn) begin          //intervals driven by current state.
    if (!resetn) begin
        arreadyReg <= 0 ;                                                 
        araddrReg  <= 0 ;
        addrReady  <= 0 ;
    end else begin
        case (currentState)
            READ: begin
                if (!addrReady) begin
                    araddrReg <= ARADDR ;
                    addrReady <= 1      ;
                end 
            end
            DONE: begin
                addrReady <= 0;
            end
        endcase
    end
end

assign ARREADY   = arreadyReg ;                     //drive - used for Handshake with master  
assign AROUT     = araddrReg  ;                     //drive - send out address to memory

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