// Numerical Controlled Oscillator
module nco(     clk_gen,
                num,
                clk,
                rst_n    );

output          clk_gen   ;
input  [31:0]   num       ;
input           clk       ;
input           rst_n     ;

reg    [31:0]   cnt       ;
reg             clk_gen   ;
always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
                 cnt      <= 32'd0;
                 clk_gen  <= 1'd0;
        end else begin
                 if(cnt >= num/2-1) begin
                           cnt      <= 32'd0;
                           clk_gen  <= ~clk_gen;
                 end else begin
                           cnt <= cnt + 1'b1;
                 end
        end
end

endmodule

// Counter
module cnt60(  out,
               clk,
               rst_n );

output [5:0]   out          ;
input          clk          ;
input          rst_n        ;

reg    [5:0]   out          ;
always @(posedge clk or negedge rst_n) begin
       if(rst_n == 1'b0) begin
                out <= 6'd0;
       end else begin
                if(out >= 6'd59) begin
                       out <= 6'd0;
                end else begin
                       out <= out + 1'b1;
                end
       end

end

endmodule

// NCO Counter
module top_cnt(  out,
                 num,
                 clk,
                 rst_n  );

output [5:0]     out     ;
input  [31:0]    num     ;
input            clk     ;
input            rst_n   ;

wire             clk_gen ;

nco     nco_u0(  .clk_gen  ( clk_gen ),
                 .num      ( num     ),
                 .clk      ( clk     ),
                 .rst_n    ( rst_n   ));

cnt60   cnt_u0(  .out      ( out     ),
                 .clk      ( clk_gen ),
                 .rst_n    ( rst_n   ));

endmodule

//Double figure separate
module double_fig_sep(
              o_left,
              o_right,
              i_double_fig);

output [3:0]  o_left       ;
output [3:0]  o_right      ;

input  [5:0]  i_double_fig ;

assign o_left   = i_double_fig / 10;
assign o_right  = i_double_fig % 10;

endmodule

//FND Decoder
module fnd_dec( o_seg,
                i_num );

output [6:0]    o_seg  ;
input  [3:0]    i_num  ;

reg    [6:0]    o_seg  ;
always @(*) begin
       case(i_num)
            4'd0  : o_seg = 7'b1111_110;
            4'd1  : o_seg = 7'b0110_000;
            4'd2  : o_seg = 7'b1101_101;
            4'd3  : o_seg = 7'b1111_001;
            4'd4  : o_seg = 7'b0110_011;
            4'd5  : o_seg = 7'b1011_011;
            4'd6  : o_seg = 7'b1011_111;
            4'd7  : o_seg = 7'b1110_000;
            4'd8  : o_seg = 7'b1111_111;
            4'd9  : o_seg = 7'b1110_011;
            default o_seg = 7'b0000_000;
        endcase
end

endmodule

// LED Display
module led_disp( o_seg,
                 o_seg_dp,
                 o_seg_enb,
                 i_six_digit_seg,
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
                 .clk_gen  ( gen_clk  ),
                 .num      ( 32'd5000 ),
                 .clk      ( clk      ),
                 .rst_n    ( rst_n    ));

reg    [3:0]     cnt_common_node     ;
always @(posedge gen_clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
                 cnt_common_node <= 4'd0;
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

//Top NCO Counter Display
module top_nco_cnt_disp(
              o_seg,
              o_seg_dp,
              o_seg_enb,
              clk,
              rst_n         );

output [6:0]  o_seg          ;
output        o_seg_dp       ;
output [5:0]  o_seg_enb      ;

input         clk            ;
input         rst_n          ;

wire   [5:0]  o_nco_cnt      ;

top_cnt  u_nco_cnt( .out   ( o_nco_cnt    ),
                    .num   ( 32'd50000000 ),
                    .clk   ( clk          ),
                    .rst_n ( rst_n        ));

wire   [3:0]  o_left         ;
wire   [3:0]  o_right        ;

double_fig_sep      u_double_fig_sep(
                    .o_left       (    o_left       ),
                    .o_right      (    o_right      ),
                    .i_double_fig (    o_nco_cnt    ));

wire   [6:0]  seg_left       ;
wire   [6:0]  seg_right      ;

fnd_dec u0_fnd_dec( .o_seg ( seg_left  ),
                    .i_num ( o_left    ));

fnd_dec u1_fnd_dec( .o_seg ( seg_right ),
                    .i_num ( o_right   ));

wire   [41:0] i_six_digit_seg;

assign        i_six_digit_seg = { {4{7'b0000000}}, seg_left, seg_right};
//assign        i_six_digit_seg = { {4{7'b1110111}}, seg_left, seg_right};                             //Q1
//assign        i_six_digit_seg = { seg_left, seg_right, seg_left, seg_right, seg_left, seg_right};    //Q2

led_disp      u_led_disp(
                    .o_seg             ( o_seg           ),
                    .o_seg_dp          ( o_seg_dp        ),
                    .o_seg_enb         ( o_seg_enb       ),
                    .i_six_digit_seg   ( i_six_digit_seg ),
                    .i_six_dp          ( 6'd0            ),
                    .clk               ( clk             ),
                    .rst_n             ( rst_n           ));

endmodule
