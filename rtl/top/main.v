module moduleName #(
<<<<<<< HEAD
parameter dataWidth = 32 ,
parameter addrWidth = 5  ,
parameter strbWidth = (dataWidth/8) - 1 

)(
input  wir                clk     ,
input  wir                reset   ,

input  wir                AWVALID ,
input  wire[addrWidth:0]  AWADDR  ,
output wire               AWREADY ,

input  wire               WVALID  ,
input  wire[dataWidth:0]  WDATA   ,
input  wire[strbWidth:0]  WSTRB   ,
=======
parameter DATA_WIDTH = 32 ,
parameter ADDR_WIDTH = 5  ,
parameter STRB_WIDTH = (DATA_WIDTH/8) - 1 

)(
input  wire               clk     ,
input  wire               reset   ,

input  wire               AWVALID ,
input  wire[ADDR_WIDTH:0]  AWADDR  ,
output wire               AWREADY ,

input  wire               WVALID  ,
input  wire[DATA_WIDTH:0]  WDATA   ,
input  wire[STRB_WIDTH:0]  WSTRB   ,
>>>>>>> dev
output wire               WREADY  ,

input  wire               BREADY  ,
output wire[1:0]          BRESP   ,
output wire               BVALID  ,

input  wire               ARVALID ,
<<<<<<< HEAD
input  wire[addrWidth:0]  ARADDR  ,
output wire               ARREADY ,

input  wire               RREADY  ,
output wire[dataWidth:0]  RDATA   ,
=======
input  wire[ADDR_WIDTH:0]  ARADDR  ,
output wire               ARREADY ,

input  wire               RREADY  ,
output wire[DATA_WIDTH:0]  RDATA   ,
>>>>>>> dev
output wire[1:0]          RRESP   ,
output wire               RVALID  
);

<<<<<<< HEAD
//MEMORY INITIALISATION

wire WEN,REN = 0;
=======
//INTERNAL SIGNALS
reg WEN,REN = 0;

//FSM STATES
reg[1:0] AWSTATE, AWnextState ;
reg[1:0] WSTATE , WnextState  ;
reg[1:0] BSTATE , BnextState  ;
reg[1:0] ARSTATE, ARnextState ;
reg[1:0] RSTATE , RnextState  ;

//MEMORY INITIALISATION
memory memory(
    .clk(clk)           ,
    .reset(reset)       ,

    .WEN(WEN)           ,
    .AWADDR(AWADDR)     ,
    .WSTRB(WSTRB)       ,
    .WDATA(WDATA)       ,

    .REN(REN)           ,
    .ARADDR(ARADDR)     ,
    .RDATA(RDATA) 
);


>>>>>>> dev
endmodule