`timescale 1ns/1ps

module mainTB#(
    parameter DATA_WIDTH = 32 ,
    parameter ADDR_WIDTH = 5  ,
    parameter STRB_WIDTH = 4    
)();

//Parameters
parameter CLK_PERIOD   = 10   ;
parameter RESET_CYCLES = 5    ;

reg                  clk      ;
reg                  resetn   ;

reg                  awvalid  ;
reg[ADDR_WIDTH-1:0]  awaddr   ;
wire                 awready  ;

reg                  wvalid   ;
reg[DATA_WIDTH-1:0]  wdata    ;
reg[STRB_WIDTH-1:0]  wstrb    ;
wire                 wready   ;

reg                  bready   ;
wire[1:0]            bresp    ;
wire                 bvalid   ;

reg                  arvalid  ;
reg[ADDR_WIDTH-1:0]  araddr   ;
wire                 arready  ;

reg                  rready   ;
wire[DATA_WIDTH-1:0] rdata    ;
wire[1:0]            rresp    ;
wire                 rvalid   ;

reg [DATA_WIDTH-1:0] readData ; //internal to testbench
reg aw_done = 0               ;
reg w_done  = 0               ;
reg ar_done = 0               ;

main DUT(
    .clk     (clk)      ,       //input     
    .resetn  (resetn)   ,       //input     

    .AWVALID (awvalid)  ,       //input     
    .AWADDR  (awaddr)   ,       //input     
    .AWREADY (awready)  ,       //output    

    .WVALID  (wvalid)   ,       //input     
    .WDATA   (wdata)    ,       //input     
    .WSTRB   (wstrb)    ,       //input     
    .WREADY  (wready)   ,       //output    

    .BREADY  (bready)   ,       //input     
    .BRESP   (bresp)    ,       //output    
    .BVALID  (bvalid)   ,       //output    

    .ARVALID (arvalid)  ,       //input     
    .ARADDR  (araddr)   ,       //input     
    .ARREADY (arready)  ,       //output    

    .RREADY  (rready)   ,       //input     
    .RDATA   (rdata)    ,       //output    
    .RRESP   (rresp)    ,       //output    
    .RVALID  (rvalid)           //output   
);

//Clock generation (parametrization)
initial clk = 0                   ;
always #(CLK_PERIOD/2) clk = ~clk ;

//Reset (Sycnhronised)
initial begin
    resetn = 0 ;
    repeat (RESET_CYCLES) @(posedge clk) ;
    resetn = 1 ;
    $display("[%0t] resetn deasserted", $time) ;
end

//Tasks (modular stimulus)
task axi_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data, input [STRB_WIDTH-1:0] strb);    
    begin
    fork
        begin //address
            @(posedge clk) ;
            awaddr  = addr ;
            awvalid = 1    ;
            @(posedge clk) ; //checker - remove
            while (!awready) @(posedge clk);
            awvalid = 0    ;
            aw_done = 1    ;
        end
        begin //data
            @(posedge clk) ;
            wdata  = data  ;
            wstrb  = strb  ;
            wvalid = 1     ;
            @(posedge clk) ; //checker - remove
            while (!wready) @(posedge clk) ;
            wvalid = 0     ;
            w_done = 1     ;
        end
        begin //feedback
            repeat (2) @(posedge clk) ;                         //remove - added to check if aw/w_done remains high
            while (!(aw_done && w_done)) @(posedge clk) ;
            aw_done = 0 ;
            w_done  = 0 ;
            bready  = 1 ;
            while (!bvalid) @(posedge clk) ;
            bready  = 0 ;
        end
    join
    end
endtask

task axi_read(input [ADDR_WIDTH-1:0] addr, output [DATA_WIDTH-1:0] dataOut);
    fork
        begin //address
            repeat (2) @(posedge clk) ;
            araddr  = addr ;
            arvalid = 1    ;
            @(posedge clk) ;
            while (!arready) @(posedge clk) ;
            arvalid = 0    ;
            ar_done = 1    ;
        end
        begin //result & feedback
            repeat (2) @(posedge clk) ;
            ar_done = 0     ;
            rready = 1      ;
            @(posedge clk)  ;
            while (!rvalid) @(posedge clk) ;
            dataOut = rdata ;
            rready = 0      ;
        end
    join
endtask


initial begin
//initials
awvalid = 0 ; awaddr = 0 ;
wvalid  = 0 ; wdata  = 0 ; wstrb = 0 ;
bready  = 0 ; 
arvalid = 0 ; araddr = 0 ; 
rready  = 0 ; 

//waiting for reset

@(posedge resetn)
@(posedge clk)

//test sequence
axi_write(5'b01011, 32'b00010010010010000001001101101100, 4'b1111) ;
axi_write(5'b01100, 32'b00000000111111110000000011111111, 4'b1001) ;
axi_write(5'b01101, 32'b01010101010101010101010101010101, 4'b1001) ;
axi_write(5'b01110, 32'b00000000000000001111111111111111, 4'b1001) ;
axi_write(5'b01111, 32'b11111111111111111111111111111111, 4'b1001) ;
axi_write(5'b10000, 32'b10111111111111111111111111111101, 4'b1001) ;
axi_write(5'b10001, 32'b00010010010010000001001101101100, 4'b1111) ;
axi_write(5'b10010, 32'b00000000111111110000000011111111, 4'b1001) ;
axi_write(5'b10011, 32'b01010101010101010101010101010101, 4'b1001) ;
axi_write(5'b10100, 32'b00000000000000001111111111111111, 4'b1001) ;
axi_write(5'b10101, 32'b11111111111111111111111111111111, 4'b1001) ;
axi_write(5'b10110, 32'b10111111111111111111111111111101, 4'b1001) ;

#20 ;
axi_read(5'b01011, readData) ;
axi_read(5'b01100, readData) ;
axi_read(5'b01101, readData) ;

//end simulation
#100 ;
$stop;
$finish;
end
endmodule