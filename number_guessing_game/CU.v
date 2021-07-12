module CU (
  input clk, rst, EQ,
  input [7:0] LL, HL, datain,
  output reg [2:0] CV,
  output reg outrange, done
);
  reg [1:0] ns, ps;

  parameter S0 = 0, S1 = 1, S2 = 2;
  
  always @ (negedge clk, posedge rst)
    if (rst) ps = S0;
  else ps = ns;
    
  always @ (*) begin
    CV = 0;
    case(ps)
      S0: begin
       ns = S1; CV = 3'b110; done = 0; outrange = 0; end
        
      S1: begin
        if (EQ) begin ns = S2; CV = 3'b111; done = 0; outrange = 0; end
        else
          if (datain < LL | datain > HL) begin ns = S1; CV = 3'b000; done = 0; outrange = 1;end
          else begin  ns = S1; CV = 3'b111; done = 0; outrange = 0; end
      end
        
      S2: begin 
        ns = S2; CV = 3'b000; done = 1; outrange = 0;
        if (rst) 
        ns = S0;
      end
     endcase
  end
endmodule
