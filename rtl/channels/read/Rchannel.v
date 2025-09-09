module R #(
parameter DATA_WIDTH = 32 
)(
    input  wire                 clk        ,     //clock
    input  wire                 resetn     ,     //reset - logic activated when low - active low 

    input  wire                 MREADY     ,     //flag   - tells when feedback comes      
    input  wire[DATA_WIDTH-1:0] MDATA      ,     //output - actual data from memory to slave
    input  wire[1:0]            MRESP      ,     //input  - data write feedback from memory

    output wire                 RVALID     ,     //flag   - tells input ready to come      |
    output wire[DATA_WIDTH-1:0] RDATA      ,     //input  - data from master to slave      |---> handshake
    output wire[1:0]            RRESP      ,     //input  - data from master to slave      |---> handshake
    output wire                 RRESPREADY ,     //flag   - tells input ready to receive   |     
    input  wire                 RREADY           //flag   - tells input ready to receive   |     
);

//FINITE STATE MACHINE - FSM
parameter IDLE = 2'b00 ;
parameter READ = 2'b01 ;
parameter DONE = 2'b10 ;
reg[1:0] currentState, nextState ;

//INTERNAL SIGNALS AND FLAGS
reg[DATA_WIDTH-1:0] mdataReg   = 0 ;
reg[DATA_WIDTH-1:0] rdataReg   = 0 ;
reg[1:0]            mrespReg   = 0 ;
reg[1:0]            rrespReg   = 0 ;
reg                 readDone   = 0 ;
reg                 rvalidReg  = 0 ;
reg                 rrespready = 0 ;

// CURRENT STATE UPDATE                     //updates actual state at clock
always @(posedge clk or negedge resetn) begin                 
    if(!resetn) begin
        currentState <= IDLE ;
        rvalidReg    <= 0    ;
        mdataReg     <= 0    ;
        mrespReg     <= 0    ;
        rdataReg     <= 0    ;
        rrespReg     <= 0    ;
        readDone     <= 0    ;
    end else begin
        currentState <= nextState ;
    end
end

// NEXT STATE LOGIC                         //updates the next state when ever situation 
always @(*) begin                           //allows and handling of errors
    nextState = currentState ;
    rvalidReg = 0;
    case (currentState)
        IDLE: begin
            if (MREADY) begin
                nextState = READ ;
            end
        end
        READ: begin
            rvalidReg = 1;
            if (readDone && RREADY) begin
                nextState = DONE ;
            end
        end
        DONE: begin 
            if (!readDone) begin
                nextState = IDLE ;
            end
        end
        default: nextState = IDLE ;             //default fallback
    endcase
end

//CURRENT STATE LOGIC                           //sequential logic to take place at clock
always @(posedge clk or negedge resetn) begin   //intervals driven by current state.                                              
    rrespready = 0 ;
    case (currentState)
    READ: begin
        if (!readDone) begin
            mrespReg <= MRESP ;
            mdataReg <= MDATA ;
            readDone <= 1     ;
        end
    end
    DONE: begin
        readDone   <= 0 ;    
        rrespready <= 1 ;
        rrespReg   <= mrespReg ;
        if (mrespReg == 0) begin
            rdataReg <= mdataReg ;
        end
    end
    default: nextState <= IDLE ;
    endcase
end

assign RRESPREADY = rrespready  ;
assign RVALID     = rvalidReg ;
assign RRESP      = rrespReg  ;
assign RDATA      = rdataReg  ;

endmodule