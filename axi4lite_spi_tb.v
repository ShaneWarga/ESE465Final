`timescale 1ns / 1ps

module SPI_Test_bench ();

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

wire conv;
wire sdi;
wire sck;
wire sdo;
reg [31:0] i;



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
  
SPI #
    (.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH), .SPI_DATA_WIDTH(24)) SPI_TEST
    (
    .conv(conv),
    .sdo(sdo),
    .sdi(sdi),
    .sck(sck),
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
);

AdcTester # () adc (.SCK(sck), .SDI(sdi), .CS_(conv), .SDO(sdo));
//DacTester # () dac (.SCK(sck) , .SDI(sdi), .CS_(conv), .SDO(sdo));

reg [15:0] dacWave [0:999];
//reg [15:0] right [0:999];

reg [31:0] oldRead, newRead;

parameter CLK_PERIOD_2 = (CLK_PERIOD/2);
    always begin
        #(CLK_PERIOD_2) S_AXI_ACLK <= ~S_AXI_ACLK ;
    end
    
    initial begin
        S_AXI_ARESETN = 0;
        S_AXI_ACLK = 0;
        rdAddr = 0;
        rd = 0;
        $readmemh("left.mem", dacWave);
        
        // Write initializations
        wrAddr = 0;                         // Added
        wrData = 0;                         // these three
        wr = 0;                             // lines
        
        //release reset
        #(CLK_PERIOD_2 + 2) S_AXI_ARESETN =1;
        #(CLK_PERIOD*10);
        
        //test bench
        
        //adc test data width
        wrAddr = 'b01000010000000;    //Write to the size register
        wrData = 16;
        //Write signal
        wr = 1;
        #CLK_PERIOD ;
        while (wrDone == 0)begin
            #CLK_PERIOD ;
        end 
        #CLK_PERIOD;
        wr = 0;
        
        //DAC test data width
//        wrAddr = 'b01000010000000;    //Write to the size register
//        wrData = 24;
//        //Write signal
//        wr = 1;
//        #CLK_PERIOD ;
//        while (wrDone == 0)begin
//            #CLK_PERIOD ;
//        end 
//        #CLK_PERIOD;
//        wr = 0;
        
        //Init Time Delay
        #CLK_PERIOD ;
        wrAddr = 'b01000000010000;    //Write to the size register
        wrData = 600;
        //Write signal
        wr = 1;
        #CLK_PERIOD ;
        while (wrDone == 0)begin
            #CLK_PERIOD ;
        end 
        wr = 0;
        #(CLK_PERIOD * 10);
        
        //Enable write
        #CLK_PERIOD ;
        wrAddr = 'b01010100000000;    //Write to the size register
        wrData = 1;
        //Write signal
        wr = 1;
        #CLK_PERIOD ;
        while (wrDone == 0)begin
            #CLK_PERIOD ;
        end 
        wr = 0;
        #(CLK_PERIOD * 10);

        rd = 1;
        rdAddr = 'b01010100110000;
        while(rdDone == 0) begin
            #(CLK_PERIOD);
        end
        oldRead = rdData;
        newRead = rdData;
        rd = 0;
        #(CLK_PERIOD);
        //ADC Tester
        for(i = 0; i < 2000; i = i + 1) begin
            
            rdAddr = 'b01010100110000; 
            while (oldRead == newRead) begin
                rd = 1;
                #(CLK_PERIOD);
                while(rdDone == 0) begin
                    #(CLK_PERIOD);
                end
                newRead = rdData;
                rd = 0;
                #(CLK_PERIOD * 3);
            end
            
            #(CLK_PERIOD);
            
            wrAddr = 'b01010000001000;    
            if( i % 2 == 0)begin
                wrData = 'b1000000000000000;
            end else begin
                wrData = 'b1100000000000000;
            end
            
            //Write signal
            wr = 1;            
            while (wrDone == 0)begin
                #CLK_PERIOD ;
            end 
            wr = 0;
           
            #CLK_PERIOD;
            
            rd = 1;
            rdAddr = 'b01010101111100;
            while(rdDone == 0) begin
                #(CLK_PERIOD);
            end
            $display("rdData: %h", rdData);
            rd = 0;
                
            oldRead = newRead;

            //$stop;
        end
        $stop;
      //DAC Tester
      //Fast Mode Write
//        while(conv == 1) begin
//            #(CLK_PERIOD);
//        end
//        wrAddr = 'b01010000000000;   
//        wrData = 'b010100000000000000000000;
//        wr = 1;
//        #CLK_PERIOD ;
//        while (wrDone == 0)begin
//            #CLK_PERIOD ;
//        end 
//        wr = 0;
//        #CLK_PERIOD;
//        while(conv == 0)begin
//            #CLK_PERIOD ;
//        end
        
//      for(i = 0; i < 1000; i = i + 1) begin
//            while(conv == 1) begin
//                #(CLK_PERIOD);
//            end
            
//            wrData[23:0] = {8'b00110000, dacWave[i]};
//            //Write signal
//            wr = 1;
//            #CLK_PERIOD ;
//            while (wrDone == 0)begin
//                #CLK_PERIOD ;
//            end 
//            wr = 0;
//            #CLK_PERIOD;

//            while(conv == 0)begin
//                #CLK_PERIOD ;
//            end
//        end
//        $stop;
    end
endmodule