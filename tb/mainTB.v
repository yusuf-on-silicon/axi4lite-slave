`timescale 1ns/1ps

module mainTB#(
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
integer SEED         = 1 ;
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
            //@(posedge clk)
            rready = 0      ;
        end
    join
endtask

//============================================================
//      Monitor & Scoreboard
//============================================================
reg [DATA_WIDTH-1:0] monitor_memory [DATA_DEPTH-1:0] ;
reg [DATA_WIDTH-1:0] monitor_wdata ;
reg [ADDR_WIDTH-1:0] monitor_waddr ;
reg [1:0]            monitor_wresp ;
integer monitor_waddr_count = 0 ;
integer monitor_wdata_count = 0 ;
integer monitor_wresp_count = 0 ;
integer monitor_write_pass  = 0 ;
integer monitor_write_fail  = 0 ;
integer monitor_write_feedback_error  = 0 ;

reg monitor_waddr_done = 0 ;
reg monitor_wdata_done = 0 ;
reg monitor_wresp_done = 0 ;

always @(posedge clk) begin 
    if (awready && awvalid) begin
        monitor_waddr <= awaddr ;
        monitor_waddr_count <= monitor_waddr_count + 1 ;
        monitor_waddr_done = 1 ;
    end
    if (wready && wvalid) begin
        monitor_wdata <= wdata ;
        monitor_wdata_count <= monitor_wdata_count + 1 ;
        monitor_wdata_done = 1 ;
    end
    
    if (monitor_waddr_done && monitor_wdata_done) begin
        monitor_memory[monitor_waddr] <= monitor_wdata ;
        monitor_waddr_done = 0 ;
        monitor_wdata_done = 0 ;
    end    
end    
always @(posedge clk) begin 
    monitor_wresp_done <= 0 ;
    if (bready && bvalid) begin
        monitor_wresp <= bresp ;
        monitor_wresp_count <= monitor_wresp_count + 1 ;
        monitor_wresp_done <= 1 ;
    end
end
//scoreboard
always @(posedge clk) begin
    if (monitor_wresp_done) begin
        if (monitor_wresp === 2'b00) begin
            if (mainTB.DUT.memory.memory[monitor_waddr] === monitor_wdata) begin
                $display("[DIRECT-CHECK PASS] Addr:%h successfully stored %h", monitor_waddr, monitor_wdata);
                monitor_write_pass  = monitor_write_pass + 1 ;
            end else begin
                $error("[DIRECT-CHECK FAIL] Feedback:%b Addr:%h! RTL Mem:%h | TB Sent:%h", 
                        monitor_wresp, monitor_waddr, mainTB.DUT.memory.memory[monitor_waddr], monitor_wdata);
                monitor_write_fail  = monitor_write_fail + 1 ;
            end
        end
        else begin
                $display("[DIRECT-CHECK PASS DETECTED ERROR] Addr:%h recognized feedback error:%b", monitor_waddr, monitor_wresp);
                monitor_write_feedback_error <= monitor_write_feedback_error + 1 ;
        end
    end 
end
// read monitor and scoreboard

reg manual_read_valid = 0 ;
reg manual_read_ready = 0 ;
reg read_done = 0 ;
integer read_done_count = 0 ;

initial begin
    forever begin
        @(posedge clk) 
        manual_read_ready = 0 ;
        read_done = 0 ;
        if (monitor_wresp_done && (monitor_wresp === 2'b00)) begin
            axi_read(monitor_waddr,readData) ;
            read_done = 1 ;
            read_done_count = read_done_count + 1 ;
        end
         if (manual_read_valid) begin
            manual_read_ready = 1 ;
            axi_read(readAddr,readData) ;
            read_done = 1 ;
            read_done_count = read_done_count + 1 ;
        end
    end
end

reg [ADDR_WIDTH-1:0] monitor_raddr = 0 ;
reg             monitor_raddr_done = 0 ;
integer        monitor_raddr_count = 0 ;

reg [DATA_WIDTH-1:0] monitor_rdata = 0 ;
reg             monitor_rdata_done = 0 ;
integer        monitor_rdata_count = 0 ;

integer monitor_read_pass = 0 ;
integer manual_read_pass  = 0 ;
integer monitor_read_fail = 0 ;

always @(posedge clk) begin 
    monitor_raddr_done <= 0 ;
    if (arready && arvalid) begin
        monitor_raddr <= araddr ;
        monitor_raddr_count <= monitor_raddr_count + 1 ;
        monitor_raddr_done <= 1 ;
    end
end    
always @(posedge clk) begin 
    monitor_rdata_done <= 0 ;
    if (rready && rvalid) begin
        monitor_rdata <= rdata ;
        monitor_rdata_count <= monitor_rdata_count + 1 ;
        monitor_rdata_done <= 1 ;
    end
end

initial begin
    forever begin
        @(posedge monitor_rdata_done); 
        if (monitor_rdata === DUT.memory.memory[monitor_raddr]) begin
            $display("[READ-BACK PASS] Addr:%h! RTL Mem:%h | TB Received:%h", monitor_raddr, DUT.memory.memory[monitor_raddr], monitor_rdata);
            monitor_read_pass = (manual_read_ready) ? monitor_read_pass : monitor_read_pass + 1 ;
            manual_read_pass = (manual_read_ready) ? manual_read_pass + 1 : manual_read_pass ;
        end else begin
            $error("[READ-BACK FAIL] Addr:%h! RTL Mem:%h | TB Received:%h", monitor_raddr, DUT.memory.memory[monitor_raddr], monitor_rdata);
            monitor_read_fail = monitor_read_fail + 1 ;
        end
    end
end


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

WRITE_COUNT = 300 ;
READ_COUNT  = 0 ;
//WRITE_COUNT = ({$random} * {$random(SEED)})%500 ;
//READ_COUNT  = ({$random} * {$random(SEED)})%500 ;

@(posedge resetn)   //waiting for reset
@(posedge clk)

fork
    begin //test sequence
        for (writeCounter = 0 ; writeCounter < WRITE_COUNT ; writeCounter = writeCounter + 1) begin
            writeAddr   = (({$random})%54) + 10 ;
            writeData   = {$random} ;  
            writeStrobe = 4'b1111  ;
            writeDelay  = {$random}%500 ;
            axi_write(writeAddr,writeData,writeStrobe) ;
            #(writeDelay) ;
        end
//        axi_write(5'b01011, 32'b00010010010010000001001101101100, 4'b1111) ;
    end
    begin
        for (readCounter = 0 ; readCounter < READ_COUNT ; readCounter = readCounter + 1) begin
            readAddr   = $unsigned(({$random} * {$random(SEED)})%64 ) ;
            readDelay  = $unsigned(({$random} * {$random(SEED)})%500) ;
            manual_read_valid = 1 ;
            @ (posedge manual_read_ready);
            manual_read_valid = 0 ;
            #(readDelay) ;
        end
//        axi_read(5'b01011, readData) ;
    end
join
$display("COUNT MONITOR WRITE ADDRESS: %0d", monitor_waddr_count);
$display("COUNT MONITOR WRITE DATA: %0d", monitor_wdata_count);
$display("COUNT MONITOR WRITE FEEDBACK: %0d", monitor_wresp_count);
$display("COUNT MONITOR READ ADRESS: %0d", monitor_raddr_count);
$display("COUNT MONITOR READ DATA: %0d", monitor_rdata_count);
$display("==============================================================");
$display("==============================================================");
$display("READ UVM PASS: %0d",monitor_read_pass);
$display("READ MANUAL PASS: %0d",manual_read_pass);
$display("READ FAIL: %0d",monitor_read_fail);
$display("TOTAL READ PASS: %0d",manual_read_pass + monitor_read_pass);
$display("TOTAL READ DONE COUNT: %0d",read_done_count);
$display("==============================================================");
$display("WRITE ERROR RECOGNIZED: %0d", monitor_write_feedback_error);
$display("WRITE PASS: %0d", monitor_write_pass);
$display("WRITE FAIL: %0d", monitor_write_fail);
$display("TOTAL WRITE PASS: %0d", monitor_write_pass + monitor_write_feedback_error);
//end simulation
#1000    ;
$stop(0);
$finish;
end
endmodule