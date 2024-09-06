
module dmtf  #( 
    parameter SYNC_DEPTH = 3
)(
    input wire clk,       // 3.072 mHz Input clock
    input wire rst,       // Reset signal
    input wire async_clk_1,
    input wire async_clk_2,
    input wire delay_sign,
    input wire [6:0] delay,
    output wire dmtd_out
);

    reg [SYNC_DEPTH-1:0] async_reg1;    //async to sync
    reg [SYNC_DEPTH-1:0] async_reg2;    //async to sync
    
    reg [127:0] shift_reg;          // 128-bit shift register for delay
    
    wire sync_out1;
    wire sync_out2;
    wire sync_out2_delay;

    //capture async inputs into clk clock domain
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            async_reg1 <= 0;
            async_reg2 <= 0;
        end else begin
            async_reg1 <= {async_reg1[SYNC_DEPTH-2:0], async_clk_1};
            async_reg2 <= {async_reg2[SYNC_DEPTH-2:0], async_clk_2};
        end
    end
    
    //bus exchange  input 1 and 2
    assign sync_out1 = (delay_sign == 0) ? async_reg1[SYNC_DEPTH-1]: async_reg2[SYNC_DEPTH-1];   //swap if delay_sign = 1
    assign sync_out2 = (delay_sign == 0) ? async_reg2[SYNC_DEPTH-1]: async_reg1[SYNC_DEPTH-1];   //swap if delay_sign = 1 
    
    //shift reg delay
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= 128'b0;     // Clear shift register on reset
        end else begin
            // Shift register logic
            shift_reg <= {shift_reg[126:0], sync_out2};  // Shift left and load new sync_out2
        end
    end 
    
    // Select the delayed output based on delay (binary-weighted)
    assign sync_out2_delay = shift_reg[delay]; 
    
    //xor two bitstreams
    assign dmtd_out = sync_out1 ^ sync_out2_delay; 
    
endmodule
