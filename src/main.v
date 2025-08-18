module moduleName #(
parameter dataWidth = 32;
parameter addrWidth = 6 ;
)(
input  wire                 clk     ;
input  wire                 reset   ;

input  wire                 AWVALID ;
input  wire [addrWidth:0]   AWADDR  ;
output wire                 AWREADY ;

input  wire                 WVALID  ;
input  wire [dataWidth:0]   WDATA   ;
input  wire [3:0]           WSTRB   ;
output wire                 WREADY  ;

input  wire                 BREADY  ;
output wire [1:0]           BRESP   ;
output wire                 BVALID  ;

input  wire                 ARVALID ;
input  wire [addrWidth:0]   ARADDR  ;
output wire                 ARREADY ;

input  wire                 RREADY  ;
output wire [dataWidth:0]   RDATA   ;
output wire [1:0]           RRESP   ;
output wire                 RVALID  ;
);


endmodule