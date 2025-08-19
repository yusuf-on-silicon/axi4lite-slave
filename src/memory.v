module moduleName #(
    parameter addrWidth = 5  ,
    parameter dataWidth = 32 ,
    parameter dataDepth = 64 ,
    parameter strbWidth = (dataWidth/8) - 1,
) (
    input  wire               clk    ,
    input  wire               reset  ,

    input  wire               WEN    ,
    input  wire[addrWidth:0]  AWADDR ,
    input  wire[strbWidth:0]  WSTRB  ,
    input  wire[dataDepth:0]  WDATA  ,

    input  wire               REN    ,
    input  wire[addrWidth:0]  ARADDR ,
    output wire[dataDepth:0]  RDATA 
);
    
reg [dataDepth:0] memory[dataWidth:0];
reg []

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        RDATA <= 32'b0;
    end else if (WEN) begin
        RDATA <= memory[RADDR];
    end
end
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        RDATA <= 32'b0;
    end else if (WEN) begin
        RDATA <= memory[RADDR];
    end
end

endmodule