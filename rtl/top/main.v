module main #(
parameter DATA_WIDTH = 32 ,
parameter ADDR_WIDTH = 6  ,
parameter STRB_WIDTH = 4 

)(
input  wire                 clk     ,
input  wire                 resetn  ,

input  wire                 AWVALID ,
input  wire[ADDR_WIDTH-1:0] AWADDR  ,
output wire                 AWREADY ,

input  wire                 WVALID  ,
input  wire[DATA_WIDTH-1:0] WDATA   ,
input  wire[STRB_WIDTH-1:0] WSTRB   ,
output wire                 WREADY  ,

input  wire                 BREADY  ,
output wire[1:0]            BRESP   ,
output wire                 BVALID  ,

input  wire                 ARVALID ,
input  wire[ADDR_WIDTH-1:0] ARADDR  ,
output wire                 ARREADY ,

input  wire                 RREADY  ,
output wire[DATA_WIDTH-1:0] RDATA   ,
output wire[1:0]            RRESP   ,
output wire                 RVALID  
);

//INTERNAL SIGNALS
wire                  wen        ;
wire [STRB_WIDTH-1:0] wstrbout   ;
wire [DATA_WIDTH-1:0] wdataout   ;
wire [ADDR_WIDTH-1:0] awaddrout  ;
wire [1:0]            wresp      ;
wire                  wrespready ;

wire                  ren        ;
wire [ADDR_WIDTH-1:0] araddrout  ;
wire                  mready     ;
wire [DATA_WIDTH-1:0] mdata      ;
wire [1:0]            mresp      ;

//WRITE MODULE
write WriteEntity (
    .clk        (clk)        ,   //Global
    .resetn     (resetn)     ,

    .AWVALID    (AWVALID)    ,   //1 AW channel - capture write address
    .AWADDR     (AWADDR)     ,
    .AWREADY    (AWREADY)    ,

    .WVALID     (WVALID)     ,   //1 W channel  - capture write data
    .WDATA      (WDATA)      ,
    .WSTRB      (WSTRB)      ,
    .WREADY     (WREADY)     ,

    .WEN        (wen)        ,   //2 Write     - send write data and address from slave to memory
    .WDATAOUT   (wdataout)   ,
    .WSTRBOUT   (wstrbout)   ,
    .AWADDROUT  (awaddrout)  ,

    .WRESP      (wresp)      ,   //3 feedback IN  - receive feedback from memory
    .WRESPREADY (wrespready) ,

    .BVALID     (BVALID)     ,
    .BRESP      (BRESP)      ,   //4 feedback OUT - send feedback to all modules of write and master
    .BREADY     (BREADY)                            
);

read ReadEntity (
    .clk        (clk)        ,     //Basic Inputs
    .resetn     (resetn)     ,
       
    .ARVALID    (ARVALID)    ,     //1 AR channel - capture Read address
    .ARADDR     (ARADDR)     ,
    .ARREADY    (ARREADY)    ,

    .REN        (ren)        ,     //2 AR channel - Send data to memory
    .ARADDROUT  (araddrout)  ,
  
    .MREADY     (mready)     ,     //3 R channel  - Get Data from memory
    .MDATA      (mdata)      ,
    .MRESP      (mresp)      ,

    .RVALID     (RVALID)     ,     //4 R channel  - send data to master
    .RDATA      (RDATA)      ,
    .RRESP      (RRESP)      ,
    .RREADY     (RREADY)                                      
);

//MEMORY INITIALISATION
memory memory(
    .clk        (clk)        ,
    .resetn     (resetn)     ,

    .WEN        (wen)        ,
    .AWADDR     (awaddrout)  ,
    .WSTRB      (wstrbout)   ,
    .WDATA      (wdataout)   ,
    .WRESP      (wresp)      ,
    .WDONE      (wrespready) ,

    .REN        (ren)        ,
    .ARADDR     (araddrout)  ,
    .RDATA      (mdata)      ,
    .RRESP      (mresp)      ,
    .RDONE      (mready)                             
);


endmodule