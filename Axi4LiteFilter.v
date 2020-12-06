module Axi4LiteFilter #
    (parameter C_S_AXI_ADDR_WIDTH = 14, C_S_AXI_DATA_WIDTH = 32, FIR_DATA_WIDTH =16, FIR_ADDR_WIDTH = 6, RAM_SIZE = 512)
    (
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
        input       S_AXI_RREADY
    );
    wire signed [FIR_DATA_WIDTH-1:0] do_impulse;
    wire signed [FIR_DATA_WIDTH-1:0] do_input;
    
    parameter IDLE = 0, WR_INPUT = 1, WR_IMPULSE = 2, CONVO = 3, RD_RES = 4 ;
    reg [3:0] nextState, currentState ; 
    reg [FIR_DATA_WIDTH-1:0] di_impulse = 0, di_input = 0;
	reg we_input;
    reg we_impulse;
	reg [C_S_AXI_DATA_WIDTH-1:0] doneD, doneQ, ramSizeD, ramSizeQ;
	reg signed [C_S_AXI_DATA_WIDTH-1:0] sumD, sumQ, resD, resQ, product ;
	reg [FIR_ADDR_WIDTH-1:0] a_input, a_impulse, input_itrD, input_itrQ;
	reg en_counter;
	reg [FIR_ADDR_WIDTH:0] itr;    //7bit iterator
	
	wire [C_S_AXI_ADDR_WIDTH-1:0]wrAddrS;
	wire [C_S_AXI_DATA_WIDTH-1:0]wrDataS;
	wire wrS;
	wire [C_S_AXI_ADDR_WIDTH-1:0] rdAddrS;
	reg [C_S_AXI_DATA_WIDTH-1:0] rdDataS = 0;
	wire rdS;
	
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

SinglePortRAM #(.RAM_ADDR_WIDTH(FIR_ADDR_WIDTH),.RAM_DATA_WIDTH(FIR_DATA_WIDTH),.RAM_SIZE(RAM_SIZE)) FilterRAM1 (
        .clk(S_AXI_ACLK),
        .we(we_input),
        .a(a_input),
        .di(di_input),
        .do(do_input)
    );
    
SinglePortRAM #(.RAM_ADDR_WIDTH(FIR_ADDR_WIDTH),.RAM_DATA_WIDTH(FIR_DATA_WIDTH),.RAM_SIZE(RAM_SIZE)) ImpulseRAM1 (
        .clk(S_AXI_ACLK),
        .we(we_impulse),
        .a(a_impulse),
        .di(di_impulse),
        .do(do_impulse)
    );
	
	//Initialization
//	initial begin
//	   currentState = IDLE ;
//	   nextState = IDLE ;
//	   itr = 0 ;
//	   doneQ = 0 ;
//	   resQ = 0 ;
//	   sumQ = 0 ;
//	   product = 0 ;
//	   ramSizeQ = 0 ;
//	end
	
    //sequential block
    always @(posedge S_AXI_ACLK) begin
		if ( !S_AXI_ARESETN ) begin
			currentState <= IDLE ;
			input_itrQ <= 0;
			sumQ <= 0 ;
			resQ <= 0;
			ramSizeQ <= 0;
			itr <= 0 ;
			doneQ <= 0 ;
		end
		else begin
			currentState <= nextState ;
			input_itrQ <= input_itrD ;
			sumQ <= sumD ;
			resQ <= resD;
			ramSizeQ <= ramSizeD ;
			doneQ <= doneD ;
			if (en_counter) begin
			    itr <= itr + 1 ;
			    if (itr >= ramSizeQ)
			        itr <= 0 ;
			end
		end
	end
	
	//combinational block
	always @ * begin
	   //Initialization
	   nextState = currentState ;
	   input_itrD = input_itrQ ;
	   resD = resQ ;
	   ramSizeD = ramSizeQ ;
	   doneD = doneQ ;
	   sumD = 0 ;
	   we_input = 0 ;
	   we_impulse = 0 ;
	   rdDataS = 0 ;
	   a_impulse = 0 ;
	   a_input = 0 ;
	   di_input = 0 ;
	   di_impulse = 0 ;
	   en_counter = 0 ;
	   if (rdS && rdAddrS == 14'b01000000000100) begin   //done flag starts at 0b01000000100
	       rdDataS = doneQ ;
	       if(doneQ == 1)begin
	           doneD = 0 ;
	       end
	   end
	   
	   if (wrS && wrAddrS == 14'b01000000001000) begin   //ram size starts at 0b010000001000
	       ramSizeD = wrDataS ;
	   end
	   
	   case(currentState)
	   IDLE:begin
	           //Wait for a new data from either input or impulse
               if (wrS) begin
                   if (wrAddrS[C_S_AXI_ADDR_WIDTH-1:11] == 0) begin  //Input RAM starts from 0b00000000000
                       nextState = WR_INPUT;
                       a_input = wrAddrS[7:2];
                       input_itrD = wrAddrS[7:2];
                       we_input = 1;
                       di_input = wrDataS;
                   end
                   if (wrAddrS[C_S_AXI_ADDR_WIDTH-1:11] == 1) begin  //Impulse RAM starts from 0b00100000000
                       nextState = WR_IMPULSE;
                       a_impulse = wrAddrS[7:2];
                       we_impulse = 1 ;
	                   di_impulse = wrDataS ;
	                   a_input = wrAddrS[7:2];
	                   we_input = 1 ;
	                   di_input = 0 ;
                   end
               end
               if (rdS && rdAddrS == 14'b01000000000000) begin  //output reg starts at 0b01000000000
	               rdDataS = resQ;
                   nextState = RD_RES;
               end
	       end
	   
	   WR_INPUT:begin
	           //Write a new input to ram and go to convolution loop
               nextState = CONVO;
	       end
	       
	   WR_IMPULSE:begin
	           //Write a new impulse response and go back to IDLE
	           nextState = IDLE;
	       end
	   
	   CONVO:begin
	       //Perform the convolution loop by reading from both rams, back to IDLE once done    
	           en_counter = 1;
	           a_impulse = itr;
	           if (itr > input_itrQ) begin
	               a_input = input_itrQ - itr + ramSizeQ ; 
	           end else if (itr <= input_itrQ) begin
	               a_input = input_itrQ - itr ;
	           end
	           product = do_impulse * do_input;
	           sumD = sumQ + product;
	           if (itr >= ramSizeQ) begin
	               resD = sumD;
	               resD = (resD + 16384) >> 15 ;
	               resD = { {16{resD[15]}}, resD[15:0] };
	               nextState = IDLE;
	               doneD = 1 ;
	           end
	       end
	   
	   RD_RES:begin
	           nextState = IDLE ;
	       end
	   
	   default:begin
	           nextState = IDLE;
	       end
	   endcase
	end
    
endmodule
