//CPE 222 final project
//group 347 radar sensor
//Member
//Nine1052 Fifa1071 Fluke1007 Nut1019
//20/11/2024 most complete version

//top module
module main (
    output [4:0] col,
    output [6:0] row,
    output tk,
    input clk,
    input ech,
    output servo,
    output sound
);
    wire [50:0] count_ech;
    wire [6:0] distance_cm;
    wire toggle;
    wire [3:0] row_control ;
    wire clk_dis;
    trigger_cnt cv(clk,tk);
    echo_cnt count_t(ech,count_ech,clk);
    distance_cal dis(count_ech,ech,distance_cm);
    display dot(distance_cm,col,row,toggle,row_control,clk_dis);
    servo ser(clk,servo,toggle,row_control);
    speaker sp(clk,sound,distance_cm);
    displayClk(clk,clk_dis);
endmodule


module speaker(
    input clk,
    output sound,
    input [6:0]distance
);
    reg [16:0] cnt = 0;
    reg [29:0] stop = 0;
    reg toggle = 0;
    always @ (posedge clk)
        begin 
            //generate signal 440 Hz
            if(cnt < 37500) cnt <= cnt+1;
            else
            cnt <= 0;

            //duration of play sound dependt on distance represented by toggle
            if(stop < (distance*200000)) stop <= stop+1;
            else
            begin
                stop <= 0;
                toggle <= ~toggle;
            end
        end
begin
    //use toggle to enable sound
    assign sound = ((cnt<30702) ? 1:0)&toggle;  
end

endmodule
//display dotmatrix 5x7
module displayClk(
    input clk,
    output reg clkOut
);
    reg [25:0] cnt = 0;  // 26-bit counter
    reg toggle = 0;

    always @(posedge clk) begin
        if (cnt == 9375) begin
            cnt <= 0;
            toggle <= ~toggle;  // Toggle the clock output
        end else begin
            cnt <= cnt + 1;
        end
    end

    // Generate PWM signal ~50Hz
    always @(posedge clk) begin
        clkOut <= toggle;
    end
endmodule
module display(
    input [6:0] distance_cm,
    output reg  [4:0] col,
    output reg [6:0] row = 7'b0000000,
    input reverse,
    input [3:0] row_pos,
    input [6:0] displayClk
);
    reg [3:0] col_pos;
    reg[3:0] cnt;
    reg[4:0] store_col_pos_with_row [0:6];
    reg  [4:0] tmpcol;
      always @ (posedge displayClk) begin
        col_pos <=  distance_cm/10; //every 10 cm display 1 col on dotmatri
        case(col_pos)
            4'b0000 : tmpcol <= 5'b00000;
            4'b0001 : tmpcol <= 5'b00001;
            4'b0010 : tmpcol <= 5'b00011;
            4'b0011 : tmpcol <= 5'b00111;
            4'b0100 : tmpcol <= 5'b01111;
            4'b0101 : tmpcol <= 5'b11111;
            default : tmpcol <= 5'b00000;
        endcase
        case(row_pos)
            5'd0 : store_col_pos_with_row[0] <= tmpcol;
            5'd1 : store_col_pos_with_row[1] <= tmpcol;
            5'd2 : store_col_pos_with_row[2] <= tmpcol;
            5'd3 : store_col_pos_with_row[3] <= tmpcol;
            5'd4 : store_col_pos_with_row[4] <= tmpcol;
            5'd5 : store_col_pos_with_row[5] <= tmpcol;
            5'd6 : store_col_pos_with_row[6] <= tmpcol;
        endcase
        if(cnt >= 6) cnt <= 0;
        case(cnt)
            4'd0 : row <= 7'b0111111;
            4'd1 : row <= 7'b1011111;
            4'd2 : row <= 7'b1101111;
            4'd3 : row <= 7'b1110111;
            4'd4 : row <= 7'b1111011;
            4'd5 : row <= 7'b1111101;
            4'd6 : row <= 7'b1111110;
            default : row <= 7'b1111111;
        endcase
        //row <= ~row;
        col <= store_col_pos_with_row[cnt];
        cnt <= cnt + 1;
      end
endmodule

//pluse generator for trigger pin at ultrasonic sensor (HC-SR04)
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
//count high duration of echo from ultrasonic sensor(HC-SR04) represent distance
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
//calculate distance with physic equation v = 331+0.6t estimate t = 25(easy to calculate) combination with v = 2s/t to s = (173*(period of clock = 37ns))/unit change to cm
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

//servo controller forward-revrese iteration 4.625 s per half circle | and sent output state of direction and position
module servo(input clk,output servo,output reg toggle = 0,output [3:0] row);

reg [20:0] counter = 0;
reg [26:0] loop = 0; // count interval
reg [19:0] set_p = 66000; //initial at 0 degree
always @(posedge clk) 
    begin
    //generate PWM signal ~50Hz
    if (counter < 500000) //~20 ms | actual calculate 18.5 ms but workk!!!
        begin
            counter <= counter + 1; 
        end
    else 
        begin
            counter <=0;
    end


    if(toggle == 0)
        begin
            if(loop < 2500) 
                begin
                loop <= loop +1;
                end
            else
                begin
                    if(set_p > 16000)
                        begin
                            set_p = set_p-1;
                        end
                    else toggle = ~toggle;
                    loop = 0;
                end
        end
    else
        begin
            if(loop < 2500) 
                begin
                    loop <= loop +1;
                end
            else
                begin
                    if(set_p < 66000)
                        begin
                            set_p = set_p+1;
                        end
                    else toggle = ~toggle;
                    loop = 0;
                end
        end
    end

//11200(1ms)->left , 40350(1.5ms)->neutral , 69500(2ms)->right
begin
    //generate PWM signal ~50Hz
    assign servo = (counter<set_p) ? 1:0;  
    assign row = ((set_p-16000)/7000);
end

endmodule