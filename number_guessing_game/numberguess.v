 module numberguess(
	 input clk, rst, enter, genrand,
	 input [9:0] DIP,
	 output done, outrange,
	 output [6:0] sslltens, ssllones, sshltens, sshlones
); 
	 wire [7:0] datain, hl, ll;
	 wire [3:0] bcdllones, bcdlltens, bcdhlones, bcdhltens;
	 wire [2:0] cv;
	 wire eq;
	 
	 keyin U1 (.DIP(DIP), .enter(enter), .datain(datain), .rst(rst));
	 DU U2 (.datain(datain), .LL(ll),.HL(hl), .CV(cv),.clk(clk),.rst(rst),.genrand(genrand),.EQ(eq));
	 CU U3 (.clk(clk),.rst(rst),.EQ(eq),.LL(ll),.HL(hl),.datain(datain),.CV(cv),.outrange(outrange),.done(done));
	 bin2bcd U4 (.bin(ll), .bcdones(bcdllones) ,.bcdtens(bcdlltens));
	 bcd7seg U5 (.bcd(bcdlltens), .sevenseg(sslltens));
	 bcd7seg U6 (.bcd(bcdllones), .sevenseg(ssllones));
	 bin2bcd U7 (.bin(hl), .bcdones(bcdhlones) ,.bcdtens(bcdhltens));
	 bcd7seg U8 (.bcd(bcdhltens), .sevenseg(sshltens));
	 bcd7seg U9 (.bcd(bcdhlones), .sevenseg(sshlones));
	
endmodule
