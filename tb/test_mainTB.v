`timescale 1ns/1ps

module test_mainTB#(
    parameter DATA_WIDTH = 32 ,
    parameter DATA_DEPTH = 64 ,
    parameter ADDR_WIDTH = 5  ,
    parameter STRB_WIDTH = 4    
)();

//============================================================
//      Parameters - 
//============================================================
parameter CLK_PERIOD   = 10 ;
parameter RESET_CYCLES = 5  ;
integer SEED         = 5 ;
integer WRITE_COUNT  = 0 ; 
integer READ_COUNT   = 0 ;

//============================================================
//      Signals
//============================================================

//Signal Task Write
integer              writeCounter = 0 ;
integer              writeDelay   = 0 ;
reg [ADDR_WIDTH-1:0] writeAddr        ;
reg [DATA_WIDTH-1:0] writeData        ;
reg [STRB_WIDTH-1:0] writeStrobe      ;
reg                  aw_done      = 0 ;
reg                  w_done       = 0 ;

//Signal Task Read
integer              readCounter = 0 ;
integer              readDelay   = 0 ;
reg [ADDR_WIDTH-1:0] readAddr        ;      
reg [DATA_WIDTH-1:0] readData        ; 
reg                  ar_done     = 0 ;

//Signals DUT
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

//============================================================
//      DUT
//============================================================
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

//============================================================
//      Tasks
//============================================================
//Task Write
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

//Task Read
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
            @(posedge clk)
            rready = 0      ;
        end
    join
endtask


//============================================================
//      Logic
//============================================================
//Logic Clock
initial clk = 0                   ;
always #(CLK_PERIOD/2) clk = ~clk ;

//Logic Reset 
initial begin
    resetn = 0 ;
    repeat (RESET_CYCLES) @(posedge clk) ;
    resetn = 1 ;
    $display("[%0t] resetn deasserted", $time) ;
end

//Logic Behaviour
initial begin
awvalid = 0 ;       //Asign starting values at start
awaddr  = 0 ;
wvalid  = 0 ; 
wdata   = 0 ; 
wstrb   = 0 ;
bready  = 0 ; 
aw_done = 0 ;
w_done  = 0 ;

arvalid = 0 ; 
araddr  = 0 ; 
rready  = 0 ; 
ar_done = 0 ;

WRITE_COUNT = 150 ;
READ_COUNT  = 150 ;

@(posedge resetn)   //waiting for reset
@(posedge clk)

fork
    begin //test sequence
        for (writeCounter = 15 ; writeCounter <= WRITE_COUNT+15 ; writeCounter = writeCounter + 1) begin
            axi_write(writeCounter, (32'b00010010010010000001001101101100+writeCounter), 4'b1111) ;
        end
    end
    begin
        for (readCounter = 15 ; readCounter <= READ_COUNT+15 ; readCounter = readCounter + 1) begin
        axi_read(readCounter, readData) ;
        $display("VALUE READ DATA = %0h, ADDRESS = %oh", readData, readCounter);
        end
    end
join
//$display("COUNT MONITOR WRITE ADDRESS: %0d", monitor_waddr_count);
//$display("COUNT MONITOR WRITE DATA: %0d", monitor_wdata_count);
//$display("COUNT MONITOR WRITE FEEDBACK: %0d", monitor_wresp_count);
//$display("WRITE PASS: %0d", monitor_write_pass);
//$display("WRITE FAIL: %0d", monitor_write_fail);
//end simulation
#100 ;
$stop(0);
$finish;
end
endmodule