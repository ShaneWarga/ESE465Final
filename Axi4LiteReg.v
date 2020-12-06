`timescale 1ns / 1ps


module Axi4LiteRegs#(parameter C_S_AXI_ADDR_WIDTH = 11, C_S_AXI_DATA_WIDTH = 32, DATA_WIDTH =16, FIR_ADDR_WIDTH = 6)(
        // Axi4Lite Bus
        input       S_AXI_ACLK,
        input       S_AXI_ARESETN,
        input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
        input       S_AXI_AWVALID,
        output wire  S_AXI_AWREADY,
        input       [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
        input       [3:0] S_AXI_WSTRB,
        input       S_AXI_WVALID,
        output wire  S_AXI_WREADY,
        output wire  [1:0] S_AXI_BRESP,
        output wire  S_AXI_BVALID,
        input       S_AXI_BREADY,
        input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
        input       S_AXI_ARVALID,
        output wire  S_AXI_ARREADY,
        output wire  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
        output wire  [1:0] S_AXI_RRESP,
        output wire  S_AXI_RVALID,
        input       S_AXI_RREADY,
        output wire  reg0_0,
        output wire  reg0_1
    );
    
     // read from and write to these 2 registers
	reg [C_S_AXI_DATA_WIDTH-1:0] reg0D = 0, reg0Q = 0;
	reg [C_S_AXI_DATA_WIDTH-1:0] reg1D = 0, reg1Q = 0;
	
	wire [C_S_AXI_ADDR_WIDTH-1:0]wrAddrS;
	wire [C_S_AXI_DATA_WIDTH-1:0]wrDataS;
	wire wrS;
	wire [C_S_AXI_ADDR_WIDTH-1:0] rdAddrS;
	reg [C_S_AXI_DATA_WIDTH-1:0] rdDataS = 0;
	wire rdS;
	wire rdDone = 1, wrDone = 1;
           
    // Axi4Lite Supporter instantiation
Axi4LiteSupporter #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteSupporter1 (
    // Simple Bus
    .wrAddr(wrAddrS),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
    .wrData(wrDataS),                    // output   [C_S_AXI_DATA_WIDTH-1:0]
    .wr(wrS),                            // output
    .rdAddr(rdAddrS),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
    .rdData(rdDataS),                    // input    [C_S_AXI_ADDR_WIDTH-1:0]
    .rd(rdS),                            // output
    // Axi4Lite Bus
    .S_AXI_ACLK(S_AXI_ACLK),            // input
    .S_AXI_ARESETN(S_AXI_ARESETN),      // input
    .S_AXI_AWADDR(S_AXI_AWADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
    .S_AXI_AWVALID(S_AXI_AWVALID),      // input
    .S_AXI_AWREADY(S_AXI_AWREADY),      // output
    .S_AXI_WDATA(S_AXI_WDATA),          // input    [C_S_AXI_DATA_WIDTH-1:0]
    .S_AXI_WSTRB(S_AXI_WSTRB),          // input    [3:0]
    .S_AXI_WVALID(S_AXI_WVALID),        // input
    .S_AXI_WREADY(S_AXI_WREADY),        // output        
    .S_AXI_BRESP(S_AXI_BRESP),          // output   [1:0]
    .S_AXI_BVALID(S_AXI_BVALID),        // output
    .S_AXI_BREADY(S_AXI_BREADY),        // input
    .S_AXI_ARADDR(S_AXI_ARADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
    .S_AXI_ARVALID(S_AXI_ARVALID),      // input
    .S_AXI_ARREADY(S_AXI_ARREADY),      // output
    .S_AXI_RDATA(S_AXI_RDATA),          // output   [C_S_AXI_DATA_WIDTH-1:0]
    .S_AXI_RRESP(S_AXI_RRESP),          // output   [1:0]
    .S_AXI_RVALID(S_AXI_RVALID),        // output    
    .S_AXI_RREADY(S_AXI_RREADY)         // input
    ) ;
    
	always @(posedge S_AXI_ACLK) begin
	    if (!S_AXI_ARESETN) begin
	        reg0Q <= 0 ;
	        reg1Q <= 0 ;
	    end
	    else begin
	        reg0Q <= reg0D ;
	        reg1Q <= reg1D ;
	    end
	end
	
	assign reg0_0 = reg0Q[0] ;
	assign reg0_1 = reg0Q[1] ;
	
	always @* begin
	    reg0D = reg0Q ;
	    reg1D = reg1Q ;
	    rdDataS = 0 ;
		if (wrS) begin
			if (wrAddrS == 0) begin 
				reg0D = wrDataS ;
			end 
			if (wrAddrS == 4) begin 
				reg1D = wrDataS ;
			end
		end
		 
		 if (rdS) begin  
			if (rdAddrS == 0) begin 
				 rdDataS = reg0Q;
			end 
			else if (rdAddrS == 4) begin 
				rdDataS = reg1Q;
			end
		end 
	end
	
endmodule