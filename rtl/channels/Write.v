module write #(
parameter DATA_WIDTH = 32 ,
parameter DATA_DEPTH = 64 ,
parameter ADDR_WIDTH = 5  ,
parameter STRB_WIDTH = 4  ,
parameter RESP_WIDTH = 2  
)
(
  input  wire                 clk        ,     //Global 
  input  wire                 reset      , 
     
  input  wire                 AWVALID    ,     //1 AW channel - capture write address
  input  wire[ADDR_WIDTH-1:0] AWADDR     ,   
  output wire                 AWREADY    ,   
       
  input  wire                 WVALID     ,     //1 W channel  - capture write data  
  input  wire[DATA_WIDTH-1:0] WDATA      ,   
  input  wire[STRB_WIDTH-1:0] WSTRB      ,   
  output wire                 WREADY     ,   
       
  output wire                 WEN        ,     //2. Write     - send write data and address from slave to memory 
  output wire[DATA_WIDTH-1:0] WDATAOUT   ,   
  output wire[STRB_WIDTH-1:0] WSTRBOUT   ,   
  output wire[ADDR_WIDTH-1:0] AWADDROUT  ,   
         
  input  wire[RESP_WIDTH-1:0] WRESP      ,     //3. feedback IN  - receive feedback from memory 
  input  wire                 WRESPREADY , 
  
  output wire                 BVALID     ,   
  output wire[RESP_WIDTH-1:0] BRESP      ,     //4. feedback OUT - send feedback to all modules of write and master
  input  wire                 BREADY      
);

wire dataReady;
wire addrReady;

AWchannel AWentity (
    .clk(clk),                      // IN  : From   Global             |  <-------   Glo 
    .reset(reset),                  // IN  : From   Global             |  <-------   Glo
    .AWVALID(AWVALID),              // IN  : From   Master             |  <-------   Mas
    .AWADDR(AWADDR),                // IN  : From   Master             |  <-------   Mas
    .AWREADY(AWREADY),              // OUT : To     Master             |    -------> Mas
    .BRESPREADY(BRESPREADY),        // IN  : From   Slave    Bchannel  |  <-------   SB
    .BRESP(BRESP),                  // IN  : From   Slave    Bchannel  |  <-------   SB
    .DATAREADY(dataReady),          // IN  : From   Slave    Wchannel  |  <-------   SW
    .ADDRREADY(addrReady),          // OUT : To     Slave    Wchannel  |    -------> SW
    .AWADDROUT(AWADDROUT)           // OUT : To     Memory             |    -------> Mem
);

Wchannel Wentity (
    .clk(clk),                      // IN  : From   Global             |  <-------   Glo
    .reset(reset),                  // IN  : From   Global             |  <-------   Glo
    .WVALID(WVALID),                // IN  : From   Master             |  <-------   Mas
    .WDATA(WDATA),                  // IN  : From   Master             |  <-------   Mas
    .WSTRB(WSTRB),                  // IN  : From   Master             |  <-------   Mas
    .WREADY(WREADY),                // OUT : To     Master             |    -------> Mas
    .BRESPREADY(BRESPREADY),        // IN  : From   Slave    Bchannel  |  <-------   SB
    .BRESP(BRESP),                  // IN  : From   Slave    Bchannel  |  <-------   SB
    .DATAREADY(dataReady),          // OUT : To     Slave    AWchannel |    -------> SAW
    .ADDRREADY(addrReady),          // IN  : From   Slave    AWchannel |  <-------   SAW
    .WDATAOUT(WDATAOUT),            // OUT : To     Memory             |    -------> Mem
    .WSTRBOUT(WSTRBOUT)             // OUT : To     Memory             |    -------> Mem
);

Bchannel Bentity (
    .clk(clk),                      // IN  : From   Global             |  <-------   Glo
    .reset(reset),                  // IN  : From   Global             |  <-------   Glo
    .BVALID(BVALID),                // OUT : To     Master             |  <-------   Mas
    .BRESP(BRESP),                  // OUT : To     Many               |  <-------   Mas,SAW,SW
    .BREADY(BREADY),                // IN  : From   Master             |  <-------   Mas
    .BRESPREADY(BRESPREADY),        // OUT : To     Slave    AW,W      |    -------> SAW,SW
    .WRESP(WRESP),                  // IN  : From   Memory             |  <-------   Mem
    .WRESPREADY(WRESPREADY)         // IN  : From   Memory             |  <-------   Mem
);

assign WEN = (addrReady && dataReady) ? 1 : 0;  // Memory Write enable - High when AW & W Ready

endmodule