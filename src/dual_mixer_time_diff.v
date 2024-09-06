module pwm_generator #(
    
    parameter SYNC_DEPTH = 3
)(
    input wire clk,       // 3.072 mHz Input clock
    input wire rst,       // Reset signal
    input wire async_clk_1,
    input wire async_clk_2,
    output wire dmtd_out
);

    reg [SYNC_DEPTH-1:0] async_reg1;
    reg [SYNC_DEPTH-1:0] async_reg2;

    assign dmtd_out = async_reg1[SYNC_DEPTH-1] ^ async_reg2[SYNC_DEPTH-1];
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            async_reg1 <= 0;
            async_reg2 <= 0;
        end else begin
            async_reg1 <= {async_reg1[SYNC_DEPTH-2:0], async_clk_1};
            async_reg2 <= {async_reg2[SYNC_DEPTH-2:0], async_clk_2};
        end
    end

endmodule
 