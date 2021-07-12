module bcd7seg(
	input [3:0] bcd,
   output reg [6:0] sevenseg
);

  //convert BCD into 7 segment code
  always@(*) begin
    case (bcd) //case statement
      0 : sevenseg = 7'b1111110;
      1 : sevenseg = 7'b0110000;
      2 : sevenseg = 7'b1101101;
      3 : sevenseg = 7'b1111001;
      4 : sevenseg = 7'b0110011;
      5 : sevenseg = 7'b1011011;
      6 : sevenseg = 7'b1011111;
      7 : sevenseg = 7'b1110000;
      8 : sevenseg = 7'b1111111;
      9 : sevenseg = 7'b1111011;
      default : sevenseg = 7'b0000000;
    endcase
end

endmodule