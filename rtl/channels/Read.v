module write #(
parameter DATA_WIDTH = 32 ,
parameter DATA_DEPTH = 64 ,
parameter ADDR_WIDTH = 5  ,
parameter STRB_WIDTH = 4  ,
parameter RESP_WIDTH = 2  
)
(
    input  wire                 clk        ,     //Basic Inputs
    input  wire                 reset      , 
       
    input  wire                 ARVALID    ,     //1. AR channel   - capture write address
    input  wire[ADDR_WIDTH-1:0] ARADDR     ,   
    output wire                 ARREADY    ,   

    output wire                 REN        ,     //2. AR channel - Send data to memory     
    output wire[ADDR_WIDTH-1:0] ARADDROUT  , 
  
    input  wire                 MREADY     ,     //3. R channel  - Get Data from memory
    input  wire[DATA_WIDTH-1:0] MDATA      ,
    input  wire[RESP_WIDTH-1:0] MRESP      ,         

    output wire                 RVALID     ,     //4. R channel  - send data to master
    output wire[DATA_WIDTH-1:0] RDATA      ,
    output wire[RESP_WIDTH-1:0] RRESP      ,
    input  wire                 RREADY     
);

ARchannel ARentity (
    .clk(clk),
    .resetn(resetn),    
    .ARVALID(ARVALID),
    .ARADDR(ARADDR),
    .ARREADY(ARREADY),
    .RRESPREADY(RRESPREADY),
    .RRESP(RRESP),     
    .REN(REN),
    .ARADDROUT(ARADDROUT)
);

Rchannel Rentity (
    .clk(clk),
    .resetn(resetn),
    .MREADY(MREADY),
    .MDATA(MDATA),
    .MRESP(MRESP),
    .RVALID(RVALID),
    .RDATA(RDATA),
    .RRESP(RRESP),
    .RRESPREADY(RRESPREADY),
    .RREADY(RREADY)
);
endmodule