`timescale 1ns/1ps

module TBmemory#(
parameter addrWidth = 6     ,
parameter dataWidth = 32    ,
parameter strbWidth = 4     
)();
reg                  clk    ;
reg                  reset  ;

reg                  WEN    ;
reg[addrWidth-1:0]   AWADDR ;
reg[strbWidth-1:0]   WSTRB  ;
reg[dataWidth-1:0]   WDATA  ;

reg                  REN    ;
reg[addrWidth-1:0]   ARADDR ;
wire[dataWidth-1:0]  RDATA  ;

initial begin
    clk = 0;
    forever #5 clk = ~clk ; // 100 MHz write clock
end

memory uut(
    .clk   (clk   ) ,
    .reset (reset ) ,
    
    .WEN   (WEN   ) ,
    .AWADDR(AWADDR) ,
    .WSTRB (WSTRB ) ,
    .WDATA (WDATA ) ,
    
    .REN   (REN   ) ,
    .ARADDR(ARADDR) ,
    .RDATA (RDATA )
);

initial begin
    clk    = 0 ;
    WEN    = 0 ;
    REN     = 0 ;
    AWADDR = 0 ;
    ARADDR = 0 ;
    WSTRB  = 0 ;
    WDATA  = 0 ;
    reset  = 0 ;
    #20
    reset  = 1 ;
end

initial begin
//WRITE REPEAT
WEN    = 1  ;
AWADDR = 12 ;
WDATA  = 32'b10101010000000001100110011000011  ;
WSTRB  = 4'b1011                                ;
# 20        ;
WEN    = 0  ;

//READ REPEAT
REN    = 1  ;
ARADDR = 12 ;
# 20        ;
REN    = 0  ;
# 20        ;
$finish     ;
end
endmodule