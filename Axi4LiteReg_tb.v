`timescale 1ns / 1ps

module Axi4LiteRegs_tb();

// Axi4Lite Manager instantiation    
parameter C_S_AXI_ADDR_WIDTH = 14, C_S_AXI_DATA_WIDTH = 32, CLK_PERIOD = 33.33 ;
 
// Axi4Lite signals
reg  S_AXI_ACLK ;
reg  S_AXI_ARESETN ;
wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR ;
wire  S_AXI_AWVALID ;
wire S_AXI_AWREADY ;
wire  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA ;
wire  [3:0] S_AXI_WSTRB ;
wire  S_AXI_WVALID ;
wire S_AXI_WREADY ;
wire [1:0] S_AXI_BRESP ;
wire S_AXI_BVALID ;
wire  S_AXI_BREADY ;
wire  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR ;
wire  S_AXI_ARVALID ;
wire S_AXI_ARREADY ;
wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA ;
wire [1:0] S_AXI_RRESP ;
wire S_AXI_RVALID ;
wire  S_AXI_RREADY ;
// Simple Bus signals
reg     [C_S_AXI_ADDR_WIDTH-1:0]    wrAddr ;
reg     [C_S_AXI_DATA_WIDTH-1:0]    wrData ;
reg                                 wr ;
wire                                wrDone ;
reg     [C_S_AXI_ADDR_WIDTH-1:0]    rdAddr ;
wire    [C_S_AXI_DATA_WIDTH-1:0]    rdData ;
reg                                 rd ;
wire                                rdDone ;

reg     signed [15:0]                      pass_sine[0:999] ;
reg     signed [15:0]                      stop_sine[0:999] ;
reg     signed [15:0]                      impulse[0:60] ;
reg     signed [15:0]               res;

Axi4LiteManager #(.C_M_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_M_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteManager1
        (
            // Simple Bus
            .wrAddr(wrAddr),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
            .wrData(wrData),                    // input    [C_M_AXI_DATA_WIDTH-1:0]
            .wr(wr),                            // input    
            .wrDone(wrDone),                    // output
            .rdAddr(rdAddr),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
            .rdData(rdData),                    // output   [C_M_AXI_DATA_WIDTH-1:0]
            .rd(rd),                            // input
            .rdDone(rdDone),                    // output
            // Axi4Lite Bus
            .M_AXI_ACLK(S_AXI_ACLK),            // input
            .M_AXI_ARESETN(S_AXI_ARESETN),      // input
            .M_AXI_AWADDR(S_AXI_AWADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0] 
            .M_AXI_AWVALID(S_AXI_AWVALID),      // output
            .M_AXI_AWREADY(S_AXI_AWREADY),      // input
            .M_AXI_WDATA(S_AXI_WDATA),          // output   [C_M_AXI_DATA_WIDTH-1:0]
            .M_AXI_WSTRB(S_AXI_WSTRB),          // output   [3:0]
            .M_AXI_WVALID(S_AXI_WVALID),        // output
            .M_AXI_WREADY(S_AXI_WREADY),        // input
            .M_AXI_BRESP(S_AXI_BRESP),          // input    [1:0]
            .M_AXI_BVALID(S_AXI_BVALID),        // input
            .M_AXI_BREADY(S_AXI_BREADY),        // output
            .M_AXI_ARADDR(S_AXI_ARADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0]
            .M_AXI_ARVALID(S_AXI_ARVALID),      // output
            .M_AXI_ARREADY(S_AXI_ARREADY),      // input
            .M_AXI_RDATA(S_AXI_RDATA),          // input    [C_M_AXI_DATA_WIDTH-1:0]
            .M_AXI_RRESP(S_AXI_RRESP),          // input    [1:0]
            .M_AXI_RVALID(S_AXI_RVALID),        // input
            .M_AXI_RREADY(S_AXI_RREADY)         // output
        );
//instantiating the Axi4 reg
Axi4LiteFilter #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteFilter1
        (
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
        
   
    //generating clock 33.3ns/2
	parameter CLK_PERIOD_2 = (CLK_PERIOD/2);
    integer i, j, k = 0, fd;
	always begin 
		#(CLK_PERIOD/2) S_AXI_ACLK <= ~S_AXI_ACLK;
	end
	
	initial begin
	    //initializing signals
        S_AXI_ARESETN = 0;
        S_AXI_ACLK = 0;
        rdAddr = 0;
        rd = 0;
        wrAddr = 0 ;
        wrData = 0 ;
        wr = 0;
        $readmemh("pass.txt", pass_sine);
        $readmemh("stop.txt", stop_sine);
        $readmemh("impulse.txt", impulse);
        

        // Release reset
        #(CLK_PERIOD/2 + 2) S_AXI_ARESETN = 1;

        //Write to ram size register
        wrAddr = 'b01000000001000;    //Write to the size register
        wrData = 61;
        //Write signal
        wr = 1 ;
        #CLK_PERIOD ;
        wr = 0 ;
        //Wait for the done signal
        while (wrDone == 0)begin
            #CLK_PERIOD ;
        end 
        #CLK_PERIOD;


        //Impulse
        for(i = 0; i < 61; i=i+1)
        begin
            //Write to impulse ram
            wrAddr = 'b00100000000000 + i*4;
            wrData = impulse[i];  
            //Write signal
            wr = 1 ;
            #CLK_PERIOD ;
            wr = 0;
            //Wait for the done signal
            while (wrDone == 0)begin
                #CLK_PERIOD ;
            end 
            #CLK_PERIOD;
        end
        //Input
        for(j = 0; j < 1000; j=j+1) begin
            if (k > 60) begin
                k = 0;
            end 
            //Write to input ram
            wrAddr = 'b00000000000000 + k*4;
            wrData = stop_sine[j];  
            //Write signal
            wr = 1 ;
            #CLK_PERIOD ;
            wr = 0 ;
            //Wait for done signal
            while (wrDone == 0)begin
                #CLK_PERIOD ;
            end 
            #CLK_PERIOD ;
            //Read convolution done flag
            rdAddr = 'b01000000000100;
            rd = 1;
            #CLK_PERIOD ;
            rd = 0;
            while (rdDone == 0)begin
                #CLK_PERIOD ;
            end
            #CLK_PERIOD ;
            while (rdData == 0) begin
                #CLK_PERIOD ;
                rd = 1 ;
                #CLK_PERIOD ;
                rd = 0 ;
                while(rdDone == 0)begin
                    #CLK_PERIOD ;
                end
            end
            #CLK_PERIOD ;
            rdAddr = 'b01000000000000 ;    //read result
            rd = 1 ;
            #CLK_PERIOD ;   
            rd = 0 ; 
            while (rdDone == 0) begin
                #CLK_PERIOD ;
            end  
            res = rdData[15:0];
            $display("%d", res) ;
            #CLK_PERIOD ;
            
            
            k = k + 1;
        end

            


//        #(CLK_PERIOD*10)
//        wrAddr = 4 ;
//        wrData = 32'hdeadbeef ;
//        wr = 1 ;
//        #CLK_PERIOD
//        wrAddr = 0 ;
//        wrData = 0 ;
//        wr = 0 ;
//        #(CLK_PERIOD*5) ;
//        rdAddr = 4 ;
//        rd = 1 ;
//        #CLK_PERIOD 
//        rdAddr = 0;
//        rd = 0;
//        #(CLK_PERIOD*10);
        $stop;
		
	end
	
endmodule
