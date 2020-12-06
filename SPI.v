`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2020 01:13:21 PM
// Design Name: 
// Module Name: SPI
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SPI #
    (parameter C_S_AXI_ADDR_WIDTH = 14, C_S_AXI_DATA_WIDTH = 32, SPI_DATA_WIDTH=32)
    (
        // Peripherials
        output reg conv,
        output reg sck,
        output reg sdi,
        input       sdo,
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
        input        S_AXI_RREADY,
        output [255:0] probe
    );
    
    
    wire[C_S_AXI_ADDR_WIDTH-1:0] wrAddrS, rdAddrS;
    wire[C_S_AXI_DATA_WIDTH-1:0] wrDataS;
    reg [C_S_AXI_DATA_WIDTH-1:0] rdDataS;
    wire wrS, rdS;

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

    parameter IDLE = 0, SDI1 = 1, SDI2 = 2, SDI3 = 3, SCK1 = 4, SCK2 = 5, SCK3 = 6, INIT = 7;
    reg [3:0] nextState, currentState ;
//    `define CLOCK_FREQ 30
//    `define TIME_DELAY 600
    reg [C_S_AXI_DATA_WIDTH-1:0] count, clk_per_sample_D, clk_per_sample_Q = 0;
    reg signed [C_S_AXI_DATA_WIDTH-1:0] bit_counterD, bit_counterQ  = 0;
    reg enableD, enableQ, l_or_r;
    reg [SPI_DATA_WIDTH-1:0] sdiStoreQ, sdiStoreD, sdoStoreQ, sdoStoreD, SPI_DATA_WIDTH_D, SPI_DATA_WIDTH_Q, res;


    always @ * begin
        conv = 0;
        sdi = sdiStoreQ[bit_counterQ];
        sck = 0;
        nextState = currentState;
        sdiStoreD = sdiStoreQ;
        sdoStoreD = sdoStoreQ;
        enableD = enableQ; 
        SPI_DATA_WIDTH_D = SPI_DATA_WIDTH_Q;
        bit_counterD  = bit_counterQ;
        clk_per_sample_D = clk_per_sample_Q;
        
        
       // check if write and addr is write address then store data in flip flop else cont
       if(wrS) begin
           if (wrAddrS == 14'b01010000001000) begin   //write data to addr
               sdiStoreD = wrDataS ;
           end 
           if (wrAddrS == 14'b01000010000000) begin   //write data to addr
               SPI_DATA_WIDTH_D = wrDataS;
           end
           if (wrAddrS == 14'b01000000010000) begin   //write data to addr
               clk_per_sample_D = wrDataS;
           end
           if (wrAddrS == 14'b01010100000000) begin
                enableD = wrDataS;
           end
        end
        
        if (rdS) begin
            if (rdAddrS == 14'b01010100110000) begin
                rdDataS = l_or_r;
            end
            if (rdAddrS == 14'b01010101111100) begin
                rdDataS = res;
            end
        end
	  
        case(currentState)
        
            INIT: begin
                if(clk_per_sample_Q != 0) begin
                    if(SPI_DATA_WIDTH_Q != 0) begin
                        if(enableQ != 0) begin
                            nextState = IDLE;
                        end
                    end     
                end
            end
            
            IDLE:begin
             if((count >= clk_per_sample_Q) && (enableQ != 0)) begin
                    conv = 0;
                    nextState = SDI1;
                    bit_counterD = SPI_DATA_WIDTH_Q - 1;
                end else begin
                    conv = 1;
                end
            end
            
            SDI1:begin
            //read the first bit
                nextState = SDI2;
            end
            SDI2:begin
            //do nothing
                
                nextState = SDI3;
            end
            SDI3:begin
                sck  = 'b1;
                nextState = SCK1;
            end
            SCK1:begin
                sck  = 'b1;
                nextState = SCK2;
            end
            SCK2:begin
            //nothing
                sck  = 'b1;
                sdoStoreD[bit_counterQ] = sdo;
                nextState = SCK3;
            end
            SCK3:begin
            //some cond goto idle otherwise sdi1
                bit_counterD = bit_counterQ - 1'b1;
                if(bit_counterQ == 0) begin
                    bit_counterD = 0; 
                    nextState = IDLE;
                end else begin 
                    nextState = SDI1;
                end
            end
        endcase
    end
    
    always @(posedge S_AXI_ACLK) begin
 		if ( !S_AXI_ARESETN ) begin
            sdiStoreQ <= 0;
            sdoStoreQ <= 0;
            bit_counterQ <= 0;
            SPI_DATA_WIDTH_Q <= 0;
            clk_per_sample_Q <= 0;
            enableQ <= 0;
            l_or_r <= 0;
            currentState <=  INIT;
            res <= 0; 
        end
        else begin  
            if((currentState == IDLE) && (count >= clk_per_sample_D) || (currentState == INIT)) begin
                count <= 0;
            end else begin
                count <= count + 1'b1;
            end
            if ((l_or_r == 0) && (bit_counterQ ==0)&& (currentState ==SCK3)) begin
                l_or_r <= 1;
                res = sdoStoreQ;
            end 
            else if((l_or_r == 1) && (bit_counterQ ==0)&& (currentState ==SCK3) ) begin
                l_or_r <= 0;
                res = sdoStoreQ;
            end
            else begin
                l_or_r <= l_or_r;
            end
            res <= res; 
            enableQ <= enableD;
            sdiStoreQ <= sdiStoreD;
            sdoStoreQ <= sdoStoreD;
            bit_counterQ <= bit_counterD;
            SPI_DATA_WIDTH_Q <= SPI_DATA_WIDTH_D;
            clk_per_sample_Q <= clk_per_sample_D;
            currentState <= nextState;
       end 
    end
    
    assign probe = {currentState,nextState,l_or_r,res,bit_counterD,sdoStoreD} ;
endmodule
