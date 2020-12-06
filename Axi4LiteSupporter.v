// Axi4Lite Supporter module declaration
module Axi4LiteSupporter #
    (parameter C_S_AXI_ADDR_WIDTH = 6, C_S_AXI_DATA_WIDTH = 32)
    (
        // Simple Bus
        output reg  [C_S_AXI_ADDR_WIDTH-1:0] wrAddr,
        output reg  [C_S_AXI_DATA_WIDTH-1:0] wrData,
        output reg  wr,
        output reg  [C_S_AXI_ADDR_WIDTH-1:0] rdAddr,
        input       [C_S_AXI_DATA_WIDTH-1:0] rdData,
        output reg  rd,
        // Axi4Lite Bus
        input       S_AXI_ACLK,
        input       S_AXI_ARESETN,
        input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
        input       S_AXI_AWVALID,
        output reg  S_AXI_AWREADY,
        input       [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
        input       [3:0] S_AXI_WSTRB,
        input       S_AXI_WVALID,
        output reg  S_AXI_WREADY,
        output reg  [1:0] S_AXI_BRESP,
        output reg  S_AXI_BVALID,
        input       S_AXI_BREADY,
        input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
        input       S_AXI_ARVALID,
        output reg  S_AXI_ARREADY,
        output reg  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
        output reg  [1:0] S_AXI_RRESP,
        output reg  S_AXI_RVALID,
        input       S_AXI_RREADY
    );
   
    //FSM States
    parameter IDLE = 0, RD_INTRANS = 1, WR_INTRANS = 2;
    reg [3:0] nextState, currentState ; 
    reg [C_S_AXI_DATA_WIDTH-1:0] rdDataD, rdDataQ;
	
    //Combinational Block
    always @ * begin 
        //initializing signals
		nextState = currentState ;
		//simple bus signals
		wr = 0 ;
		wrAddr = 0 ;
		wrData = 0 ;
		rd = 0 ;
		rdAddr = 0 ;
		//Axi4bus read transaction signals
		S_AXI_ARREADY = 0 ;
		S_AXI_RDATA = 0 ;
		S_AXI_RRESP = 0 ;
		S_AXI_RVALID = 0 ;
		//Axi4bus write transaction signals
		S_AXI_AWREADY = 0 ;
		S_AXI_WREADY = 0 ;
		S_AXI_BRESP = 2'b00 ;
		S_AXI_BVALID = 0 ;
		rdDataD = rdDataQ ;
        case(currentState) 
            IDLE: begin 
                if ( S_AXI_ARVALID ) begin
                    nextState = RD_INTRANS ;
				    S_AXI_ARREADY = 1 ;
				    rdAddr = S_AXI_ARADDR ;
				    rdDataD = rdData ;
				    rd = 1 ;
                end
                   
                else if ( S_AXI_AWVALID && S_AXI_WVALID ) begin
                    nextState = WR_INTRANS ;
                end 
             end
             
			RD_INTRANS: begin
                S_AXI_RVALID = 1 ;
                S_AXI_RDATA = rdDataQ ;
				S_AXI_RRESP = 2'b00 ;
				if (S_AXI_RREADY) begin
					nextState = IDLE ;
				end
			end

			WR_INTRANS: begin
				S_AXI_AWREADY = 1 ;
				wrAddr = S_AXI_AWADDR;
				S_AXI_WREADY = 1 ;
				wrData = S_AXI_WDATA ;
				wr = 1 ;
                S_AXI_BRESP = 2'b00 ;
                S_AXI_BVALID = 1 ;
				if (S_AXI_BREADY) begin                
					nextState = IDLE;
				end 
			end    
                
                
            default: begin
				nextState = IDLE ;
            end
        endcase
    end 
	
	//Sequential Block
	always @(posedge S_AXI_ACLK) begin
		if ( !S_AXI_ARESETN ) begin
			currentState <= IDLE ;
			rdDataQ <= 0 ;
		end
		else begin
			currentState <= nextState ;
			rdDataQ <= rdDataD ;
		end
	end
endmodule
