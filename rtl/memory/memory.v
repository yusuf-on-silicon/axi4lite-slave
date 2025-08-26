module memory #(
<<<<<<< HEAD
    parameter dataWidth = 32                 ,
    parameter dataDepth = 64                 ,
    parameter addrWidth = $clog2(dataDepth)  ,
    parameter strbWidth = dataWidth/8
) (
    input  wire                 clk    ,
    input  wire                 reset  ,

    input  wire                 WEN    ,
    input  wire[addrWidth-1:0]  AWADDR ,
    input  wire[strbWidth-1:0]  WSTRB  ,
    input  wire[dataWidth-1:0]  WDATA  ,

    input  wire                 REN    ,
    input  wire[addrWidth-1:0]  ARADDR ,
    output wire[dataWidth-1:0]  RDATA 
);

//Memory initialisation    
reg [dataWidth-1:0] memory[dataDepth-1:0];

//Internel connections/variables
reg [dataWidth-1:0] RDATAREG             ;
integer i=0                              ;


//--------------------------------------------------------------//
//----------------------------LOGIC-----------------------------//
//--------------------------------------------------------------//


//Write
always @(posedge clk) begin
    if (WEN) begin
        if (WSTRB[0]) memory[AWADDR][7:0]    <= WDATA[7:0];
        if (WSTRB[1]) memory[AWADDR][15:8]   <= WDATA[15:8];
        if (WSTRB[2]) memory[AWADDR][23:16]  <= WDATA[23:16];
        if (WSTRB[3]) memory[AWADDR][31:24]  <= WDATA[31:24];
    end
end

//Read
always @(posedge clk) begin
    if (!reset) begin
        RDATAREG <= 32'b0;
    end else if (REN) begin
        RDATAREG <= memory[ARADDR];
    end
end

assign RDATA = RDATAREG;
endmodule
=======
    parameter DATA_WIDTH = 32                 ,
    parameter DATA_DEPTH = 64                 ,
    parameter ADDR_WIDTH = $clog2(DATA_DEPTH)  ,
    parameter STRB_WIDTH = DATA_WIDTH/8
) (
    input  wire                  clk    ,
    input  wire                  resetn  ,

    input  wire                  WEN    ,
    input  wire[ADDR_WIDTH-1:0]  AWADDR ,
    input  wire[STRB_WIDTH-1:0]  WSTRB  ,
    input  wire[DATA_WIDTH-1:0]  WDATA  ,
    output wire[1:0]             WRESP  , 
    output wire                  WDONE  , 

    input  wire                  REN    ,
    input  wire[ADDR_WIDTH-1:0]  ARADDR ,
    output wire[DATA_WIDTH-1:0]  RDATA  ,
    output wire[1:0]             RRESP  ,
    output wire                  RDONE  
);

//Parameter
parameter OKAY   = 00 ;
parameter SLVERR = 01 ;
parameter DECERR = 11 ;

//Memory initialisation    -    read feautres to read description of memory
reg [DATA_WIDTH-1:0] memory[DATA_DEPTH-1:0] ;

//Internel connections & variables
reg [DATA_WIDTH-1:0] rdataReg ;
reg [1:0]            rrespReg ;
reg                  rdoneReg ;

reg [1:0] wrespReg ;
reg       wdoneReg ;

integer i ;

//Memory READ ONLY setup
initial begin
    for (i=0 ; i<10 ; i=(i + 1)) begin
        memory[i] <= 10-i;
    end    
end

//----------------------------LOGIC-------------------------------------------------------//

//------WRITE---------------//
// Output assignment
assign WRESP = wrespReg;
assign WDONE = wdoneReg;

// Response logic
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        wrespReg <= DECERR;
    end else begin
        if (WEN && AWADDR <= 9) begin
            wrespReg <= SLVERR ;
        end else if (WEN && AWADDR >= 10 && AWADDR <= 62) begin
            wrespReg <= OKAY   ;
        end else begin
            wrespReg <= DECERR ;
        end
    end
end

// Write logic
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        wdoneReg <= 0;
    end else begin
        wdoneReg <= 0;
        if (WEN && wrespReg==OKAY) begin
            if (WSTRB[0]) memory[AWADDR][07:00] <= WDATA[07:00];
            if (WSTRB[1]) memory[AWADDR][15:08] <= WDATA[15:08];
            if (WSTRB[2]) memory[AWADDR][23:16] <= WDATA[23:16];
            if (WSTRB[3]) memory[AWADDR][31:24] <= WDATA[31:24];
            wdoneReg <= 1;
        end
    end
end

//------READ----------------//
// Output assignment
assign RDATA = rdataReg ;
assign RRESP = rrespReg ;
assign RDONE = rdoneReg ;

// Response logic
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        rrespReg <= DECERR;
    end else begin
        if (REN && AWADDR <= 62) begin
            rrespReg <= OKAY ;
        end else begin
            rrespReg <= DECERR ;
        end
    end
end

// Read logic
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        rdataReg <= 0 ;
        rdoneReg <= 0 ;
    end else begin
        rdoneReg <= 0 ;
        if (REN && rrespReg == OKAY) begin
            rdataReg <= memory[ARADDR] ;
            rdoneReg <= 1 ;
        end
    end
end

endmodule

/*
11 - address error - outside range
01 - slave error   - writing on read only
00 - OKAY          - successful

memory description -
00 : 10 - read only  (will return SLVERR)
11 : 62 - write/read (will return OKAY  )
63 : 63 - invalid    (will return DECERR)
*/
>>>>>>> dev
