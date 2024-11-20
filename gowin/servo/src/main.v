//`timescale 1ns / 1ps
//rotates servo to left or right according to the pressing of push buttons
module top(
input clk,
output servo);

//create a simple counter
reg [20:0] counter=0;
reg y=0;
reg [19:0] x;
reg [0:1] sel ;
reg [26:0] loop = 0;
reg [19:0] set_p = 66000;

initial
begin
sel = 2'b01;
end

///////////////////////////////////////////////////////////////////////////
always @(posedge clk) begin
if (counter < 500000) counter <= counter + 1; //count till 100
else 
counter <=0; //reset to 0



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
       loop = 0;
   end
end
///////////////////////////////////////////////////////////////////////////
always @(posedge clk) begin
    case(sel)
        2'b01: x = set_p; // 180 degree 16000
        2'b11: x = 38000; // 90 degree 38000
        2'b10: x = 66000; // 0 degree 66000
        default : x = 0;
    endcase
end
///////////////////////////////////////////////////////////////////////////
//11200(1ms)->left , 40350(1.5ms)->neutral , 69500(2ms)->right -- rotate servo by manually putting any of these values between the extremes
begin
assign servo = (counter<x) ? 1:0;  //assign servo to 1 only if counter less than x
end
///////////////////////////////////////////////////////////////////////////
endmodule