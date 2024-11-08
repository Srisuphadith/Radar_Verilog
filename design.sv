`timescale 1us/1ns
module clk_1us(clk);
  output reg clk;
  initial
    clk = 0;
  always
    #0.5 clk = ~clk;
endmodule

module trigger_cnt(clk,clk2);
input clk;
output reg clk2;
  reg [3:0]cnt1;
  reg [17:0]cnt2;
  reg b;
  initial 
    begin
    clk2 = 0;
    cnt1 = 0;
    cnt2 = 0;
    b = 0;
    end
  
  always @ (negedge clk)
    begin
      if(cnt2 < 249)
            begin
              cnt2 <= cnt2 + 1;
            end
          else
            begin
              if(b == 0)
                begin
                  clk2 <= ~clk2;
                  b <= 1;
                end
              if(cnt1 < 10)
                begin
                  cnt1 <= cnt1 + 1;
                end
              else
                begin
                  cnt1 <= 0;
                  cnt2 <= 0;
                  b <= 0;
                  clk2 <= ~clk2;
                end
            end
    end
endmodule

module echo_cnt(ech,count_ech,clk);
  input reg ech;
  input reg clk;
  reg b;
  output reg [17:0] count_ech;
  reg [17:0] count;

  initial
    begin
      b = 0;
      count = 0;
    end
  always @ (negedge clk)
    begin
      if(ech == 1)
        begin
          if(b == 1)
            begin
              b <= 0;
            end
          count <= count + 1;
        end
      else
        begin
          if (b == 0)
            begin
          count_ech <= count;
          b <= 1;
            end
          else
            begin
              count = 0;
            end
          
        end
    end
  
  
endmodule

    
  
