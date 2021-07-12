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
    if (rst) datain = 8'bz;
    else if (enter) begin datain = dataA; dataA = 0; end
    else if (datapressed == 4'b1111) dataA = dataA;    	 
    else if ((dataA != 0)) dataA = (dataA*10) + datapressed;
    else dataA = datapressed; end

endmodule
