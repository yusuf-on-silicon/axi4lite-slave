module memory #(
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