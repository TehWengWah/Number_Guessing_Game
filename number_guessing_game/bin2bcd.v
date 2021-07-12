module bin2bcd (
	input[7:0] bin,
	output reg [3:0] bcdones, bcdtens
);

integer k;
  // convert binary data into BCD
  always@(bin)
  begin
    bcdtens = 4'b0;
    bcdones = 4'b0;
    for (k = 7;k >= 0;k = k-1)
      begin
        if (bcdtens >= 5)
          bcdtens = bcdtens + 3;
        if (bcdones >= 5)
          bcdones = bcdones + 3;
        
        bcdtens = bcdtens<<1;
        bcdtens[0] = bcdones[3];
        bcdones = bcdones<<1;
        bcdones[0] = bin[k];
      end
  end
  
endmodule