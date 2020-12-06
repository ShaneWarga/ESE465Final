
module SinglePortRAM #
    (parameter RAM_ADDR_WIDTH = 6, RAM_DATA_WIDTH = 16, RAM_SIZE = 512)
    (
        input       clk,
        input       we,
        input       [RAM_ADDR_WIDTH-1:0] a,
        input       [RAM_DATA_WIDTH-1:0] di,
        output  reg [RAM_DATA_WIDTH-1:0] do
    );
    
    reg signed [RAM_DATA_WIDTH-1:0] ram [RAM_SIZE-1:0];
    
    //Initialization
    integer i ;
    initial begin
        for (i = 0; i < RAM_SIZE; i = i + 1) begin
            ram[i] = 0 ;
        end
    end
    
    always @ (posedge clk) begin
        if (we)
            ram[a] <= di;
    end
    
    always @ * begin 
        do = ram[a];
    end
endmodule
