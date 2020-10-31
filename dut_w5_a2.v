//practice02

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

module buzz(       o_buzz,
                   i_buzz_en,
                   clk,
                   rst_n           );

output             o_buzz           ;

input              i_buzz_en        ;
input              clk              ;
input              rst_n            ;

parameter          C = 191113       ;
parameter          D = 170262       ;
parameter          E = 151686       ;
parameter          F = 143173       ;
parameter          G = 63776        ;
parameter          A = 56818        ;
parameter          B = 50619        ;

wire               clk_bit          ;
nco   u_nco_bit(   .clk_gen         ( clk_bit  ),
                   .num             ( 25000000 ),
                   .clk             ( clk      ),
                   .rst_n           ( rst_n    ));

reg   [4:0]        cnt              ;
always @(posedge clk_bit or negedge rst_n) begin
       if(rst_n == 1'b0) begin
                cnt <= 5'd0;
       end else begin
                if(cnt >= 5'd19) begin
                       cnt <= 5'd0;
                end else begin
                       cnt <= cnt + 1'd1;
                end
       end
end

reg   [31:0]         nco_num        ;
always @(*) begin
            case(cnt)
                5'd00 : nco_num = C ;
                5'd01 : nco_num = E ;
                5'd02 : nco_num = G ;
                5'd03 : nco_num = C ;
                5'd04 : nco_num = E ;
                5'd05 : nco_num = G ;
                5'd06 : nco_num = A ;
                5'd07 : nco_num = A ;
                5'd08 : nco_num = A ;
                5'd09 : nco_num = G ;
                5'd10 : nco_num = F ;
                5'd11 : nco_num = F ;
                5'd12 : nco_num = F ;
                5'd13 : nco_num = E ;
                5'd14 : nco_num = E ;
                5'd15 : nco_num = E ;
                5'd16 : nco_num = D ;
                5'd17 : nco_num = D ;
                5'd18 : nco_num = D ;
                5'd19 : nco_num = C ;
            endcase
end

wire                 buzz           ;
nco   u_nco_buzz(    .clk_gen     ( buzz    ),
                     .num         ( nco_num ),
                     .clk         ( clk     ),
                     .rst_n       ( rst_n   ));

assign               o_buzz = buzz & i_buzz_en;

endmodule
