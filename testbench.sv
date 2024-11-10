`timescale 1us/1ns
module main;
  wire clk;
  wire clk2;
  wire [17:0] count_ech;
  wire [10:0] distance_cm;
  wire [3:0] distance_m;
  reg ech;
  clk_1us ck(clk);
  trigger_cnt cv(clk,clk2);
  echo_cnt eh(ech,count_ech,clk);
  distance_cal dis(count_ech,ech,distance_cm,distance_m);
  
  initial 
    begin
      $dumpfile("design.vcd");
      $dumpvars(1,main);
      ech = 0;
      #500;
      ech = 1;
      #5900;
      ech = 0;
      #10000
      $finish;
  	end
endmodule