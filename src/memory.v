module moduleName #(
    parameter addrWidth = 6 , 
    parameter dataWidth = 32, 
    parameter dataDepth = 64 
) (
    input  wire  clk    ,
    input  wire  reset  ,

    input  wire  AWADDR ,
    input  wire  WDATA  ,

    input  wire  ARADDR ,
    output wire  ARADDR 
);
    
reg [dataDepth:0] memory[dataWidth:0];
always @(posedge clk or negedge reset) begin
    if (!reset) begin

    end else if ()
end

endmodule