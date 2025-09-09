module AWmonitor ();
reg                  clk       ,
reg                  resetn    ,
reg                  AWVALID   ,
reg[ADDR_WIDTH-1:0]  AWADDR    ,
wire                 AWREADY   ,
reg                  BRESPREADY,
reg[1:0]             BRESP     ,
reg                  DATAREADY ,
wire                 ADDRREADY ,
wire[ADDR_WIDTH-1:0] AWOUT              

AW AW_UUT(
    .clk(clk),
    .resetn(resetn),
    .AWVALID(AWVALID),
    .AWADDR(AWADDR),
    .AWREADY(AWREADY),
    .BRESPREADY(BRESPREADY),
    .BRESP(BRESP),
    .DATAREADY(DATAREADY),
    .ADDRREADY(ADDRREADY),
    .AWOUT(AWOUT)
);

task AWchannelMonitor;
input wire clk;
input wire resetn;
reg [4:0] awaddr;
begin
    if ()
end
endtask

AWchannelMonitor(x,y,z)

endmodule