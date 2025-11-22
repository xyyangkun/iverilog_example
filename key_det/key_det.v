// 按键消除抖动，按下检测
module key_det(
input clk, // 50m
input reset,
input key,
output reg key_state,    // 按键按下，输出1
output reg key_flag    
);
reg tmp_reg1, tmp_reg2;
wire neg, pos;
reg[4:0] state;
reg cnt_full;
reg count_en;
reg[20:0] count; // 50M, 每个周期0.02us 20ms ,计数到50000 49999
localparam IDLE    = 4'b0001,
           FILTER0 = 4'b0010,
           DOWN    = 4'b0100,
           FILTER1  = 4'b1000;

localparam MAX_COUNT    = 1_000_000-1;
// IDLE    -> FILTER0  检测到下降沿
// FILTER0 -> IDLE     计数过程中检测到上升沿
// FILTER0 -> DOWN     计数器超过20ms,并且为低电平
// DOWN    -> FILTER1  检测到上升沿
// FILTER1 -> IDLE     计数过程中检测到下降沿
// FILTER1 -> DOWN     计数器超过2ms,并且为低电平

// key_flag && !key_state 为1按下完整的一次
always@(posedge clk or negedge reset) begin
        if(!reset) begin
            tmp_reg1 <= 0;    
            tmp_reg2 <= 0;    
        end    
        else begin
            tmp_reg1 <= key;
            tmp_reg2 <= tmp_reg1;
        end
end

assign neg = !tmp_reg1 & tmp_reg2; // 检测到下降沿
assign pos = tmp_reg1 & !tmp_reg2; // 检测到上升沿

// count
always@(posedge clk or negedge reset) begin
        if(!reset ) begin
            count<= 0;
        end    
        else if(count_en)
            count <= count + 1;
        else
			count <= 0;
end
always@(posedge clk or negedge reset) begin
        if(!reset ) begin
            cnt_full <= 0;
        end    
        else if(count == MAX_COUNT)
            cnt_full <= 1;
		else
			cnt_full <= 0;
end

// 状态机
always@(posedge clk or negedge reset) begin
        if(!reset) begin
            state <= IDLE;
            count_en <= 0;
            key_state <= 1;
            key_flag <= 0;
        end    
        else begin
            case(state)
                IDLE: begin
					key_flag <= 0;
                    if(neg) begin
                        state <= FILTER0;
                        count_en <= 1;
                    end
                end 
                FILTER0: begin
                    if(cnt_full) begin
                        state <= DOWN;
                        count_en <= 0;
                        key_flag <= 1;
                        key_state <= 0;
                    end
                    else if(pos) begin
                        state <= IDLE;
                        count_en <= 0;
                    end
                    
                end 
                DOWN: begin
                    key_flag <= 0;
                    if(pos) begin
                        state <= FILTER1;
                        count_en <= 1;
                    end
                end 
                FILTER1: begin
                    if(cnt_full) begin
                        state <= IDLE;
                        count_en <= 0;
                        key_flag <= 1;
                        key_state <= 1;
                    end
                    else if(neg) begin
                        state <= DOWN;
                        count_en <= 0;
                    end

                end 
                default: begin
                    state <= IDLE;
                    count_en <= 0;
                    key_state <= 0;
                    key_flag <= 0;
                end

            endcase
        end
end



endmodule
