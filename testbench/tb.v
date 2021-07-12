`timescale 10ns/1ns
module tb();
  reg clk, rst, enter, genrand;
  reg [9:0] DIP;
  wire done, outrange, eq, lt, gt;
  wire [7:0] LL, HL, out, datain;
  wire [1:0] ns, ps;
  wire [2:0] cv;
  
  numberguess dut(.DIP(DIP), .clk(clk), .rst(rst), .enter(enter), .genrand(genrand), .done(done), .outrange(outrange), .eq(eq), .lt(lt), .gt(gt), .LL(LL), .HL(HL), .out(out), .datain(datain), .ns(ns), .ps(ps), .cv(cv));
  
  initial begin
    $monitor($time, "DIP=%b, rst=%b, enter=%b, genrand=%b, done=%b, outrange=%b,  GT=%b, LT=%b, EQ=%b, out=%d, datain=%d, LL=%d, HL=%d, ps=%b, ns=%b, cv=%b", DIP, rst, enter, genrand, done, outrange, gt, lt, eq, out, datain, LL, HL, ps, ns, cv);
  $dumpvars(1);
  end
  
  initial begin
    clk=0;
    forever #5 clk=~clk;
  end
  
  initial begin
    #50 rst=1;
    #50 rst=0;
    #50 genrand=1;
    #50 genrand=0;
    #50 DIP=0;
    #50 DIP=10'b0000100000;//5
    #50 DIP=0;
    #50 DIP=10'b0000000001;//0
    #50 DIP=0; 
    #50 enter=1; //50
    #50 enter=0; //01-50
    #50 DIP=10'b0100000000; //2
    #50 DIP=0;
    #50 DIP=10'b0000000001; //0
    #50 DIP=0;
    #50 enter=1; //20
    #50 enter=0; //20-50
    #50 DIP=10'b0000001000; //7
    #50 DIP=0;
    #50 DIP=10'b0000000001; //0
    #50 DIP=0;
    #50 enter=1; //70
    #50 enter=0; //20-50
    #50 DIP=10'b0000010000; //6
    #50 DIP=0;
    #50 DIP=10'b1000000000; //1
    #50 DIP=0;
    #50 enter=1; //61
    #50 enter=0; //61=61
    #50 rst=1; //2ndround
    #50 rst=0;
    #50 genrand=1;
    #50 genrand=0;
    #50 genrand=1;
    #50 genrand=0;
    #50 DIP=0;
    #50 DIP=10'b0000000100;//8
    #50 DIP=0;
    #50 DIP=10'b0000000001;//0
    #50 DIP=0; 
    #50 enter=1; //80
    #50 enter=0; //80-99
    #50 DIP=10'b0000000100; //8
    #50 DIP=0;
    #50 DIP=10'b0010000000; //3
    #50 DIP=0;
    #50 enter=1; //83
    #50 enter=0; //83=83
    #50 rst=1;
    #50 rst=0;
    #50 $finish;
  end
endmodule