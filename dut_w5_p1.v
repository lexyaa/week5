// Practice01_LED Display
module led_disp( o_seg,
                 o_seg_dp,
                 o_seg_enb,
                 i_six_dp,
                 clk,
                 rst_n      );

output [5:0]     o_seg_enb           ;
output           o_seg_dp            ;
output [6:0]     o_seg               ;

input  [41:0]    i_six_digit_seg     ;
input  [5:0]     i_six_dp            ;
input            clk                 ;
input            rst_n               ;

wire             gen_clk             ;
nco              u_nco(
                 .o_gen_clk( gen_clk ),
                 .i_nco_num( xxxxxxx ), //? ???
                 .clk      ( clk     ),
                 .rst_n    ( rst_n   ));

reg    [3:0]     cnt_common_node     ;
always @(posedge gen_clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
                 cnt_common_node <= 32'd0;
        end else begin
                 if(cnt_common_node >= 4'd5) begin
                        cnt_common_node <= 4'd0;
                 end else begin
                        cnt_common_node <= cnt_common_node + 1'b1;
                 end
        end
end

reg     [5:0]    o_seg_enb           ;
always @(cnt_common_node) begin
         case(cnt_common_node)
                 4'd0 : o_seg_enb = 6'b111110;
                 4'd1 : o_seg_enb = 6'b111101;
                 4'd2 : o_seg_enb = 6'b111011;
                 4'd3 : o_seg_enb = 6'b110111;
                 4'd4 : o_seg_enb = 6'b101111;
                 4'd5 : o_seg_enb = 6'b011111;
         endcase
end

reg              o_seg_dp            ;
always @(cnt_common_node) begin
         case(cnt_common_node)
                 4'd0 : o_seg_dp = i_six_dp[0];
                 4'd1 : o_seg_dp = i_six_dp[1];
                 4'd2 : o_seg_dp = i_six_dp[2];
                 4'd3 : o_seg_dp = i_six_dp[3];
                 4'd4 : o_seg_dp = i_six_dp[4];
                 4'd5 : o_seg_dp = i_six_dp[5];
         endcase
end

reg      [6:0]   o_seg               ;
always @(cnt_common_node) begin
         case(cnt_common_node)
                 4'd0 : o_seg = i_six_digit_seg[6:0];
                 4'd1 : o_seg = i_six_digit_seg[13:7];
                 4'd2 : o_seg = i_six_digit_seg[20:14];
                 4'd3 : o_seg = i_six_digit_seg[27:21];
                 4'd4 : o_seg = i_six_digit_seg[34:28];
                 4'd5 : o_seg = i_six_digit_seg[41:35];
         endcase
end

endmodule
