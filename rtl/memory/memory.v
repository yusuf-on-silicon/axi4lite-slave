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
        for (i = 0; i < strbWidth; i++) begin
            if (WSTRB[i] == 1) begin
                memory[AWADDR][i*8+7:i*8] <= WDATA[i*8+7:i*8];
            end
        end
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