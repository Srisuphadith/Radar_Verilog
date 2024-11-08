`timescale 1us/1ns
module main;
  wire clk;
  wire clk2;
  wire [17:0] count_ech;
  reg ech;
  clk_1us ck(clk);
  trigger_cnt cv(clk,clk2);
  echo_cnt eh(ech,count_ech,clk);
  initial 
    begin
      $dumpfile("design.vcd");
      $dumpvars(1,main);
      ech = 0;
      #50;
      ech = 1;
      #200;
      ech = 0;
      #300;
      ech = 1;
      #20;
      ech = 0;
      #50;
      ech = 1;
      #300;
      ech = 0;
      #1000
      $finish;
  	end
endmodule