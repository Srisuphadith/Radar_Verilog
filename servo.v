module servo(input clk,output servo);

reg [20:0] counter;
reg [19:0] x; //high time
reg [0:1] sel ; //select degree
reg [26:0] loop = 0; // count interval
reg [19:0] set_p = 66000;

initial
    begin
        counter = 0;
        sel = 2'b01; //set degree
    end

///////////////////////////////////////////////////////////////////////////
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

    // 0 to 180 in 4.625 s
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
always @(posedge clk) 
    begin
        case(sel)
            2'b01: x = set_p; // 180 degree 16000 ~0.59 ms
            2'b11: x = 38000; // 90 degree 38000 ~1.406 ms
            2'b10: x = 66000; // 0 degree 66000 ~2.442 ms
            default : x = 0;
        endcase
    end
///////////////////////////////////////////////////////////////////////////
//11200(1ms)->left , 40350(1.5ms)->neutral , 69500(2ms)->right
begin
    //generate PWM signal ~50Hz
    assign servo = (counter<x) ? 1:0;  //จะเป็น 1 ก็ต่อเมื่อ counter<x เเละเมื่อ counter > x จะเป็น 0 จนถึง ประมาณ 20 ms
end
///////////////////////////////////////////////////////////////////////////
endmodule