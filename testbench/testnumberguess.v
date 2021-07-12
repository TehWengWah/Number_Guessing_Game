//top module
module testnumberguess(
  input clk, rst, enter, genrand,
  input [9:0] DIP,
  output done, outrange, eq, lt, gt,
  output [7:0] LL, HL, out, datain,
  output [1:0] ns, ps,
  output [2:0] cv
); 
   
  keyin U1( .DIP(DIP), .enter(enter), .datain(datain), .rst(rst));
  DU U2( .datain(datain), .LL(LL), .HL(HL), .CV(cv),.clk(clk), .rst(rst), .genrand(genrand), .EQ(eq), .out(out), .GT(gt), .LT(lt));
  CU U3( .clk(clk), .rst(rst), .EQ(eq), .LL(LL), .HL(HL), .datain(datain), .CV(cv), .outrange(outrange), .done(done), .ps(ps), .ns(ns));
	
endmodule

//keyin
module keyin(
  input enter, rst,
  input [9:0] DIP,
  output reg [7:0] datain
  );

  reg [3:0] datapressed;
  reg [7:0] dataA;

  always@(DIP)
    case (DIP)
        10'b0000000001:datapressed = 4'h0;
        10'b0000000010:datapressed = 4'h9;
        10'b0000000100:datapressed = 4'h8;
        10'b0000001000:datapressed = 4'h7;
        10'b0000010000:datapressed = 4'h6;
        10'b0000100000:datapressed = 4'h5;
        10'b0001000000:datapressed = 4'h4;
        10'b0010000000:datapressed = 4'h3;
        10'b0100000000:datapressed = 4'h2;
        10'b1000000000:datapressed = 4'h1;
          default: datapressed = 4'b1111;
          endcase

  // data arrangement before press "enter"
  always@(rst, enter, datapressed) begin
    if (rst) datain=8'bz;
    else if (enter) begin datain=dataA; dataA=0; end
    else if (datapressed==4'b1111) dataA=dataA;    	 
    else if ((dataA!=0)) dataA=(dataA*10)+datapressed;
    else dataA=datapressed; end

endmodule

//CU
module CU (
  input clk, rst, EQ,
  input [7:0] LL, HL, datain,
  output reg [2:0] CV,
  output reg outrange, done,
  output reg [1:0] ns, ps
);

  parameter S0 = 0, S1 = 1, S2 = 2;
  
  always @ (negedge clk, posedge rst)
    if (rst) ps = S0;
  else ps=ns;
    
  always @ (*) begin
    CV = 0;
    case(ps)
      S0: begin
       ns = S1; CV = 3'b110; done=0; outrange=0; end
        
      S1: begin
        if (EQ) begin ns = S2; CV = 3'b111; done=0; outrange=0; end
        else if (datain < LL | datain > HL) begin ns = S1; CV = 3'b000; done = 0; outrange = 1;end
        else begin  ns = S1; CV = 3'b111; done = 0; outrange=0; end
      end
        
      S2: begin 
          ns = S2; CV = 3'b000; done = 1; outrange = 0;
        if (rst) begin
          ns = S0; end
      end
     endcase
  end
endmodule

//DU
module DU(
  input [7:0] datain,
  input [2:0] CV,
  input clk, rst, genrand,
  output reg EQ, GT, LT,
  output reg [7:0] LL, HL, out
  );
  reg [6:0] ranno;
  wire ldLL, ldHL, rangedone;
  assign {ldLL, ldHL, rangedone} = CV;

  //randomnumber
  reg [7:0] long;
  wire feedback;
  assign feedback = ~(((long[6]^long[5])^long[4])^long[3]);
  
  //randomnumbergenerator
  always@(posedge clk, posedge rst, posedge genrand) begin
    if (rst)  begin
      long=7'b0; out=8'b0; end 
    else if (genrand) begin
      long = {long[7:0],feedback};
      ranno = {long[6:0]};
        if (ranno > 99) begin ranno = ~{long[6:0]}; out= {1'b0, ranno}; end
        //else if (ranno < 2) begin ranno = ranno+3;out= {1'b0, ranno}; end
        else out= {1'b0, ranno};
      end
    else out=out;
  end
      
   //comparator
  always@( rst, rangedone, datain) begin
    if (rst) begin
      LT=0; GT=0; EQ=0;end
    else if (rangedone) begin
           LT = 0; GT=0; EQ=0;
          if (datain < out) begin LT <= 1; GT<=0; EQ<=0; end
          else if (datain > out) begin LT <= 0; GT<=1; EQ<=0; end
          else if (datain == out) begin LT <= 0; GT<=0; EQ<=1;end
              else begin  LT=0; GT=0; EQ=0; end
        end
  end
  
  //LL
  always@(rst, genrand, ldLL, LT, EQ, datain)
    if (rst|genrand)
        LL <= 1;
        else if (ldLL)
          if (LT||EQ) begin LL <= datain;end
           else LL <= LL;
      else LL <= LL;
  
  //HL
  always@(rst, genrand, ldHL, GT, EQ, datain)
    if (rst|genrand)
        HL <= 99;
        else if (ldHL)
          if (GT||EQ) begin HL <= datain; end
           else HL <= HL;
      else HL <= HL;

endmodule
