module main (
    //output [6:0] row,
    output [4:0] col,
    output tk,
    input clk,
    input ech
);
    wire [50:0] count_ech;
    wire [6:0] distance_cm;
    //assign row = 7'b0000000;
    //assign col = 5'b10101;

    trigger_cnt cv(clk,tk);
    echo_cnt count_t(ech,count_ech,clk);
    distance_cal dis(count_ech,ech,distance_cm);
    display dot(distance_cm,col);

endmodule
module display(
    input [6:0] distance_cm,
    output reg  [4:0] col
);
    reg [3:0] divide;
    always @ (*)
        begin
            divide  =  distance_cm/10;
            case(divide)
                4'b0000 : col = 5'b00000;
                4'b0001 : col = 5'b00001;
                4'b0010 : col = 5'b00011;
                4'b0011 : col = 5'b00111;
                4'b0100 : col = 5'b01111;
                4'b0101 : col = 5'b11111;
                default : col = 5'b00000;
            endcase
        end




endmodule
module trigger_cnt(clk,tk);
input clk;
output reg tk;
  reg [9:0]cnt1;
  reg [25:0]cnt2;
  reg b;
  initial 
    begin
    tk = 0;
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
                  tk <= ~tk;
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
                  tk <= ~tk;
                end
            end
    end
endmodule

module echo_cnt(ech,count_ech,clk);
  input  ech;
  input  clk;
  reg b,c;
  output reg [50:0] count_ech;
  reg [17:0] count;

  initial
    begin
      b = 0;
      c = 0;
      count = 0;
      count_ech = 0;
    end
  always @ (posedge clk)
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

module distance_cal(count_ech,ech,distance_cm);
  
  input  [50:0] count_ech;
  input  ech;
  output reg [6:0] distance_cm; 
  initial
    begin
        distance_cm = 0;
    end
  
  always @ (negedge ech)
    begin
      //#1;
      //distance unit centimeter
      distance_cm = (6401*count_ech)/10000000;
    end
endmodule