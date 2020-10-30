`timescale  1ns/1ns

module tb_top;

parameter      tCK = 1000/50;    //50MHz Clock

wire [6:0]  o_seg          ;
wire        o_seg_dp       ;
wire [5:0]  o_seg_enb      ;

reg         clk            ;
reg         rst_n          ;

initial        clk = 1'b0  ;
always         #(tCK/2)
               clk = ~clk  ;

// Instaces
top_nco_cnt_disp uo_top(   .o_seg         ( o_seg        ),
                           .o_seg_dp      ( o_seg_dp     ),
                           .o_seg_enb     ( o_seg_enb    ),
                           .clk           ( clk          ),
                           .rst_n         ( rst_n        ));

initial begin
    #(0*tCK)  rst_n = 1'b0;
    #(1*tCK)  rst_n = 1'b1;
    #(100000000*tCK)
               $finish;
end

endmodule

