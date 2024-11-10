module Main(ech,clk2,distance_m,clk);
  input clk;
  output clk2;
  wire [17:0] count_ech;
  wire [10:0] distance_cm;
  output  [3:0] distance_m;
  input ech;

  //clk_1us ck(clk);
  trigger_cnt cv(clk,clk2);
  echo_cnt eh(ech,count_ech,clk);
  distance_cal dis(count_ech,ech,distance_cm,distance_m);
endmodule

module trigger_cnt(clk,clk2);
input clk;
output reg clk2;
  reg [17:0]cnt1;
  reg [25:0]cnt2;
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
      if(cnt2 < 6749461)
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
              if(cnt1 < 270)
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
  input  ech;
  input  clk;
  reg b;
  output reg [17:0] count_ech;
  reg [17:0] count;

  initial
    begin
      b = 0;
      count = 0;
      count_ech = 0;
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

module distance_cal(count_ech,ech,distance_cm,distance_m);
  
  input  [17:0] count_ech;
  input  ech;
  output reg [10:0] distance_cm;
  output reg [3:0] distance_m;  
  initial
    begin
      distance_cm = 0;
      distance_m = 0;
    end
  
  always @ (negedge ech)
    begin
      #10000;
      //distance unit centimeter
      distance_cm = (170 * count_ech)/1000000;
      distance_m = distance_cm/100;
    end
endmodule
    
  
