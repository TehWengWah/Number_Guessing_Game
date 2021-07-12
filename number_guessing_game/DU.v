//DU
module DU(
  input [7:0] datain,
  input [2:0] CV,
  input clk, rst, genrand,
  output reg EQ, 
  output reg [7:0] LL, HL
  );
  reg [6:0] ranno;
  reg [7:0] out;
  reg GT, LT;
  wire ldLL, ldHL, rangedone;
  assign {ldLL, ldHL, rangedone} = CV;

  //randomnumber
  reg [7:0] long;
  wire feedback;
  assign feedback = ~(((long[6]^long[5])^long[4])^long[3]);
  
  //randomnumbergenerator
  always@(posedge clk, posedge rst, posedge genrand) begin
    if (rst)  begin
      long = 7'b0; out = 8'b0; end 
    else if (genrand) begin
      long = {long[7:0],feedback};
      ranno = {long[6:0]};
        if (ranno > 99) begin ranno = ~{long[6:0]}; out = {1'b0, ranno}; end
        else out = {1'b0, ranno};
      end
    else out = out;
  end
      
   //comparator
  always@(rst, rangedone, datain) begin
    if (rst) begin
      LT = 0; GT = 0; EQ = 0;end
    else if (rangedone) begin
           LT = 0; GT = 0; EQ = 0;
          if (datain < out) begin LT <= 1; GT <= 0; EQ <=0 ; end
          else if (datain > out) begin LT <= 0; GT <= 1; EQ <= 0; end
          else if (datain == out) begin LT <= 0; GT <= 0; EQ <= 1;end
              else begin  LT = 0; GT = 0; EQ = 0; end
        end
  end
  
  //LL
  always@(rst, ldLL, LT, EQ, datain)
    if (rst)
        LL <= 1;
        else if (ldLL)
          if (LT||EQ) begin LL <= datain;end
           else LL <= LL;
      else LL <= LL;
  //HL
  always@(rst,ldHL, GT, EQ, datain)
    if (rst)
        HL <= 99;
        else if (ldHL)
          if (GT||EQ) begin HL <= datain; end
           else HL <= HL;
      else HL <= HL;
    
endmodule