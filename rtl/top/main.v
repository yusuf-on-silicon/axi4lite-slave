module moduleName #(
parameter DATA_WIDTH = 32 ,
parameter ADDR_WIDTH = 5  ,
parameter STRB_WIDTH = (DATA_WIDTH/8) - 1 

)(
input  wire               clk     ,
input  wire               reset   ,

input  wire               AWVALID ,
input  wire[ADDR_WIDTH:0] AWADDR  ,
output wire               AWREADY ,

input  wire               WVALID  ,
input  wire[DATA_WIDTH:0] WDATA   ,
input  wire[STRB_WIDTH:0] WSTRB   ,
output wire               WREADY  ,

input  wire               BREADY  ,
output wire[1:0]          BRESP   ,
output wire               BVALID  ,

input  wire               ARVALID ,
input  wire[ADDR_WIDTH:0] ARADDR  ,
output wire               ARREADY ,

input  wire               RREADY  ,
output wire[DATA_WIDTH:0] RDATA   ,
output wire[1:0]          RRESP   ,
output wire               RVALID  
);

//INTERNAL SIGNALS
reg WEN,REN = 0;

//WRITE MODULE
Write WriteEntity (
    .clk(clk)               ,   //Global 
    .reset(reset)           ,

    .AWVALID(AWVALID)       ,   //1 AW channel - capture write address
    .AWADDR(AWADDR)         ,   
    .AWREADY(AWREADY)       ,    

    .WVALID(WVALID)         ,   //1 W channel  - capture write data  
    .WDATA(WDATA)           ,  
    .WSTRB(WSTRB)           ,  
    .WREADY(WREADY)         ,   

    .WEN(WEN)               ,   //2. Write     - send write data and address from slave to memory 
    .WDATAOUT(WDATAOUT)     ,     
    .WSTRBOUT(WSTRBOUT)     ,     
    .AWADDROUT(AWADDROUT)   ,  

    .WRESP(WRESP)           ,   //3. feedback IN  - receive feedback from memory 
    .WRESPREADY(WRESPREADY) ,     

    .BVALID(BVALID)         ,   
    .BRESP(BRESP)           ,   //4. feedback OUT - send feedback to all modules of write and master
    .BREADY(BREADY)  
);

Read ReadEntity (
    .clk(clk)             ,     //Basic Inputs
    .reset(reset)         ,     
       
    .ARVALID(ARVALID)     ,     //1. AR channel - capture Read address        
    .ARADDR(ARADDR)       ,         
    .ARREADY(ARREADY)     ,           

    .REN(REN)             ,     //2. AR channel - Send data to memory     
    .ARADDROUT(ARADDROUT) ,     
  
    .MREADY(MREADY)       ,     //3. R channel  - Get Data from memory        
    .MDATA(MDATA)         ,    
    .MRESP(MRESP)         ,             

    .RVALID(RVALID)       ,     //4. R channel  - send data to master
    .RDATA(RDATA)         ,    
    .RRESP(RRESP)         ,    
    .RREADY(RREADY)            
);

//MEMORY INITIALISATION
memory memory(
    .clk(clk)          ,
    .resetn(resetn)    ,

    .WEN(WEN)          ,
    .AWADDR(AWADDROUT) ,
    .WSTRB(WSTRBOUT)   ,
    .WDATA(WDATAOUT)   ,
    .WRESP(WRESP)      , 
    .WDONE(WRESPREADY) , 

    .REN(REN)          ,
    .ARADDR(ARADDROUT) ,
    .RDATA(MDATA)      ,
    .RRESP(MRESP)      ,
    .RDONE(MREADY)   
);


endmodule