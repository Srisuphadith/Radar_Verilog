
module Main(ech,clk2,clk,seg_out,servoClk);
  input clk;
  output clk2,servoClk;
  output  [6:0] seg_out;
  wire [50:0] count_ech;
  wire [10:0] distance_cm;
  
    wire [3:0] distance_m;
  input ech;

  //clk_1us ck(clk);

  trigger_cnt cv(clk,clk2);
  echo_cnt eh(ech,count_ech,clk);
  distance_cal dis(count_ech,ech,distance_cm,distance_m);
  seg7 seg(distance_m,seg_out);
  clkforServo servo(clk,servoClk);

endmodule

module trigger_cnt(clk,clk2);
input clk;
output reg clk2;
  reg [9:0]cnt1;
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

module distance_cal(count_ech,ech,distance_cm_10,distance_m);
  
  input  [50:0] count_ech;
  input  ech;
  output reg [3:0] distance_cm_10;
  output reg [3:0] distance_m;  
  initial
    begin
      distance_cm_10 = 0;
      distance_m = 0;
    end
  
  always @ (negedge ech)
    begin
      #100;
      //distance unit centimeter
      distance_cm_10 = (6401*count_ech)/10000000;
      distance_m = distance_cm_10;
    end
endmodule
    
module seg7(bin,seg_out);
    input [3:0] bin;
    output reg [6:0] seg_out;

    always @ (*)
    begin
    case(bin)
    
    4'b0000 : seg_out = 7'b1111110;
    4'b0001 : seg_out = 7'b0110000;
    4'b0010 : seg_out = 7'b1101101;
    4'b0011 : seg_out = 7'b1111001;
    4'b0100 : seg_out = 7'b0110011;
    4'b0101 : seg_out = 7'b1011011;
    4'b0110 : seg_out = 7'b1011111;
    4'b0111 : seg_out = 7'b1110000;
    4'b1000 : seg_out = 7'b1111111;
    4'b1001 : seg_out = 7'b1111011;
    4'b1010 : seg_out = 7'b1110111;//A
    4'b1011 : seg_out = 7'b0011111;//B
    4'b1100 : seg_out = 7'b1001110;//C
    4'b1101 : seg_out = 7'b0111101;//D
    4'b1110 : seg_out = 7'b1001111;//E
    4'b1111 : seg_out = 7'b1000111;//F
    default: seg_out = 7'b1111110;
    endcase 
    end


endmodule


module clkforServo(input clk, output reg servoClk);
  reg [22:0] cnt;
  reg [15:0] val;
  reg direction;

  initial begin
    direction = 0;
    servoClk = 0;
    cnt = 0;
    val = 27000;
  end

  always @ (posedge clk) begin
    cnt <= cnt + 1;

    if (cnt < val) begin
      servoClk <= 1;
    end else begin
      servoClk <= 0;
    end

    // When cnt reaches the full cycle of 5400000, reset cnt and adjust val
    if (cnt >= 5400000) begin
      cnt <= 0;
      if (direction == 0) begin
        val <= val + 108;
        if (val >= 54000) begin
          direction <= 1;
        end
      end else begin
        val <= val - 108;
        if (val <= 27000) begin
          direction <= 0;
        end
      end
    end
  end
endmodule
  
