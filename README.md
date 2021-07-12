# Number_Guessing_Game
## 0.0 Group 7: CAD Nobody
### 0.1 Group Members:
1. Teh Weng Wah A18KE0285
2. Teng Choon Yang A18KE0286
3. Teo Ting Khang A18KE0287

### 0.2 Lecturer:

Prof. Madya Muhammad Mun’im Ahmad Zabidi

## 1.0 Introduction
The purpose of this project is to design and develop a number guessing game. The overall Verilog code of the project will be attached.

In the number guessing game, the player is going to guess a random generated number between the range of 1 and 99. The random number is generated by Linear Feedback Shift Register. The higher limit and lower limit of the random number will keep changing and displayed when the player guesses each time. If the player guesses out of range, a red LED will light up. The higher limit and lower limit of the random number remain unchanged. Finally, when the player successfully guesses the random number, a green LED will light up. The range of higher limit and lower limit will display the guessed number.


Eg. <br>Random number = 71
<br>
LL = 01, HL = 99, input = 50,<br>
LL = 50, HL = 99, input = 80,<br>
LL = 50, HL = 80, input = 20,<br>
LL = 50, HL = 80 (red LED light up)<br>
LL = 50, HL = 80, input = 70,<br>
LL = 70, HL = 80, input = 71,<br>
LL = 71, HL = 71 (green LED light up)<br>

## 2.0 Prerequisites
### 2.1 Software list
- Altera Quartus II 14.1
 
### 2.2 Hardware list
- EPM240T100C5 CPLD board ×1
- USB blaster ×1
- Common cathode 7-segment display ×4
- 10-pin DIP switch ×1
- Push button ×3
- Yellow LED ×3
- Red LED ×1
- Green LED ×1
- 330Ω Resistor × 15
- Jumper wires
- Breadboard

The EPM240 CPLD board is used for low budget digital hardware experimentation. The board has 100 general purpose input/output (GPIO) pins and 240 logic elements accessible. It can be easily programmed using the USB Blaster.

However, due to insufficient logic elements available in the EPM240 CPLD board, the 4x4 matrix membrane keypad is unable to be used. Instead, we use a 10-pin DIP switch to key-in the input value of the guessed number.

## 3.0 Modular approach
### 3.1 ASM chart
![image](https://user-images.githubusercontent.com/48057545/125210115-41350200-e2d0-11eb-96f4-da11f4fa5bc5.png)

### 3.2 RTL table
![image](https://user-images.githubusercontent.com/48057545/125243019-11ade600-e320-11eb-9ba3-8a599f08bec8.png)

### 3.3 fbd of CU
![image](https://user-images.githubusercontent.com/48057545/125210242-0f706b00-e2d1-11eb-906f-b4a0e672766e.png)

### 3.4 fbd of DU
![image](https://user-images.githubusercontent.com/48057545/125210245-139c8880-e2d1-11eb-8f3f-e8e39e3b8ba4.png)

### 3.5 Top level block diagram
Complete numberguess top-level module with 10-pin DIP switch to load datain and 7-segment display LEDs to show LL and HL
![image](https://user-images.githubusercontent.com/48057545/125239164-d78e1580-e31a-11eb-8842-fd9d547d170f.png)

## 4.0 Verilog Coding
### 4.1 `numberguess` module
```verilog
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
   
   keyin U1( .DIP(DIP), .enter(enter), .datain(datain), .rst(rst));
   DU U2( .datain(datain), .LL(ll),.HL(hl), .CV(cv),.clk(clk),.rst(rst),.genrand(genrand),.EQ(eq));
   CU U3( .clk(clk),.rst(rst),.EQ(eq),.LL(ll),.HL(hl),.datain(datain),.CV(cv),.outrange(outrange),.done(done));
   bin2bcd U4 (.bin(ll), .bcdones(bcdllones) ,.bcdtens(bcdlltens));
   bcd7seg U5 (.bcd(bcdlltens), .sevenseg(sslltens));
   bcd7seg U6 (.bcd(bcdllones), .sevenseg(ssllones));
   bin2bcd U7 (.bin(hl), .bcdones(bcdhlones) ,.bcdtens(bcdhltens));
   bcd7seg U8 (.bcd(bcdhltens), .sevenseg(sshltens));
   bcd7seg U9 (.bcd(bcdhlones), .sevenseg(sshlones));
	
endmodule 
```

### 4.2 `keyin` module
For example, to key-in the value of “40”. First, switch on the pin 4, then switch off. Next, switch on the pin 10, then switch off again. Once the enter push-up button is pressed, the value of “40” in decimal is loaded to datain.
```verilog
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
```

### 4.3 `CU` module
```verilog
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
          else begin ns = S1; CV = 3'b111; done = 0; outrange = 0; end
      end
        
      S2: begin 
        ns = S2; CV = 3'b000; done = 1; outrange = 0;
        if (rst) 
        ns = S0;
      end
     endcase
  end
endmodule
```

### 4.4 `DU` module
```verilog
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
        if (ranno > 99) begin ranno = ~{long[6:0]}; out= {1'b0, ranno}; end
        else out= {1'b0, ranno};
      end
    else out=out;
  end
      
   //comparator
  always@(rst, rangedone, datain) begin
    if (rst) begin
      LT = 0; GT = 0; EQ = 0;end
    else if (rangedone) begin
           LT = 0; GT = 0; EQ = 0;
          if (datain < out) begin LT <= 1; GT <= 0; EQ <= 0; end
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
```

### 4.5 `bin2bcd` module
```verilog
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
          bcdtens = bcdtens+3;
        if (bcdones >= 5)
          bcdones = bcdones+3;
        
        bcdtens = bcdtens<<1;
        bcdtens[0] = bcdones[3];
        bcdones = bcdones<<1;
        bcdones[0] = bin[k];
      end
  end
  
endmodule
```

### 4.6 `bcd7seg` module
```verilog
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
```

### 4.7 Compilation Report
![image](https://user-images.githubusercontent.com/48057545/125210308-8e65a380-e2d1-11eb-9a31-76b4730fd7a8.png)

## 5.0 Simulation
### 5.1 Testbench
```verilog
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
```

### 5.3 Waveform
![image](https://user-images.githubusercontent.com/48057545/125210297-80b01e00-e2d1-11eb-9b73-434ff6c5b460.png)
```
                   0DIP=xxxxxxxxxx, rst=x, enter=x, genrand=x, done=x, outrange=x,  GT=x, LT=x, EQ=x, out=  x, datain=  x, LL=  x, HL=  x, ps=xx, ns=xx, cv=xxx
                  50DIP=xxxxxxxxxx, rst=1, enter=x, genrand=x, done=0, outrange=0,  GT=0, LT=0, EQ=0, out=  0, datain=  z, LL=  1, HL= 99, ps=00, ns=01, cv=110
                 100DIP=xxxxxxxxxx, rst=0, enter=x, genrand=x, done=0, outrange=0,  GT=0, LT=0, EQ=0, out=  0, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                 150DIP=xxxxxxxxxx, rst=0, enter=x, genrand=1, done=0, outrange=0,  GT=0, LT=0, EQ=0, out=  1, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                 155DIP=xxxxxxxxxx, rst=0, enter=x, genrand=1, done=0, outrange=0,  GT=0, LT=0, EQ=0, out=  3, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                 165DIP=xxxxxxxxxx, rst=0, enter=x, genrand=1, done=0, outrange=0,  GT=0, LT=0, EQ=0, out=  7, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                 175DIP=xxxxxxxxxx, rst=0, enter=x, genrand=1, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 15, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                 185DIP=xxxxxxxxxx, rst=0, enter=x, genrand=1, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 30, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                 195DIP=xxxxxxxxxx, rst=0, enter=x, genrand=1, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 61, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                 200DIP=xxxxxxxxxx, rst=0, enter=x, genrand=0, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 61, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                 250DIP=0000000000, rst=0, enter=x, genrand=0, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 61, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                 300DIP=0000100000, rst=0, enter=x, genrand=0, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 61, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                 350DIP=0000000000, rst=0, enter=x, genrand=0, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 61, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                 400DIP=0000000001, rst=0, enter=x, genrand=0, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 61, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                 450DIP=0000000000, rst=0, enter=x, genrand=0, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 61, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                 500DIP=0000000000, rst=0, enter=1, genrand=0, done=0, outrange=0,  GT=0, LT=1, EQ=0, out= 61, datain= 50, LL= 50, HL= 99, ps=01, ns=01, cv=111
                 550DIP=0000000000, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=1, EQ=0, out= 61, datain= 50, LL= 50, HL= 99, ps=01, ns=01, cv=111
                 600DIP=0100000000, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=1, EQ=0, out= 61, datain= 50, LL= 50, HL= 99, ps=01, ns=01, cv=111
                 650DIP=0000000000, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=1, EQ=0, out= 61, datain= 50, LL= 50, HL= 99, ps=01, ns=01, cv=111
                 700DIP=0000000001, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=1, EQ=0, out= 61, datain= 50, LL= 50, HL= 99, ps=01, ns=01, cv=111
                 750DIP=0000000000, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=1, EQ=0, out= 61, datain= 50, LL= 50, HL= 99, ps=01, ns=01, cv=111
                 800DIP=0000000000, rst=0, enter=1, genrand=0, done=0, outrange=1,  GT=0, LT=1, EQ=0, out= 61, datain= 20, LL= 50, HL= 99, ps=01, ns=01, cv=000
                 850DIP=0000000000, rst=0, enter=0, genrand=0, done=0, outrange=1,  GT=0, LT=1, EQ=0, out= 61, datain= 20, LL= 50, HL= 99, ps=01, ns=01, cv=000
                 900DIP=0000001000, rst=0, enter=0, genrand=0, done=0, outrange=1,  GT=0, LT=1, EQ=0, out= 61, datain= 20, LL= 50, HL= 99, ps=01, ns=01, cv=000
                 950DIP=0000000000, rst=0, enter=0, genrand=0, done=0, outrange=1,  GT=0, LT=1, EQ=0, out= 61, datain= 20, LL= 50, HL= 99, ps=01, ns=01, cv=000
                1000DIP=0000000001, rst=0, enter=0, genrand=0, done=0, outrange=1,  GT=0, LT=1, EQ=0, out= 61, datain= 20, LL= 50, HL= 99, ps=01, ns=01, cv=000
                1050DIP=0000000000, rst=0, enter=0, genrand=0, done=0, outrange=1,  GT=0, LT=1, EQ=0, out= 61, datain= 20, LL= 50, HL= 99, ps=01, ns=01, cv=000
                1100DIP=0000000000, rst=0, enter=1, genrand=0, done=0, outrange=0,  GT=1, LT=0, EQ=0, out= 61, datain= 70, LL= 50, HL= 70, ps=01, ns=01, cv=111
                1150DIP=0000000000, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=1, LT=0, EQ=0, out= 61, datain= 70, LL= 50, HL= 70, ps=01, ns=01, cv=111
                1200DIP=0000010000, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=1, LT=0, EQ=0, out= 61, datain= 70, LL= 50, HL= 70, ps=01, ns=01, cv=111
                1250DIP=0000000000, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=1, LT=0, EQ=0, out= 61, datain= 70, LL= 50, HL= 70, ps=01, ns=01, cv=111
                1300DIP=1000000000, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=1, LT=0, EQ=0, out= 61, datain= 70, LL= 50, HL= 70, ps=01, ns=01, cv=111
                1350DIP=0000000000, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=1, LT=0, EQ=0, out= 61, datain= 70, LL= 50, HL= 70, ps=01, ns=01, cv=111
                1400DIP=0000000000, rst=0, enter=1, genrand=0, done=0, outrange=0,  GT=0, LT=0, EQ=1, out= 61, datain= 61, LL= 61, HL= 61, ps=01, ns=10, cv=111
                1410DIP=0000000000, rst=0, enter=1, genrand=0, done=1, outrange=0,  GT=0, LT=0, EQ=1, out= 61, datain= 61, LL= 61, HL= 61, ps=10, ns=10, cv=000
                1450DIP=0000000000, rst=0, enter=0, genrand=0, done=1, outrange=0,  GT=0, LT=0, EQ=1, out= 61, datain= 61, LL= 61, HL= 61, ps=10, ns=10, cv=000
                1500DIP=0000000000, rst=1, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=0, EQ=0, out=  0, datain=  z, LL=  1, HL= 99, ps=00, ns=01, cv=110
                1550DIP=0000000000, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=0, EQ=0, out=  0, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                1600DIP=0000000000, rst=0, enter=0, genrand=1, done=0, outrange=0,  GT=0, LT=0, EQ=0, out=  1, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                1605DIP=0000000000, rst=0, enter=0, genrand=1, done=0, outrange=0,  GT=0, LT=0, EQ=0, out=  3, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                1615DIP=0000000000, rst=0, enter=0, genrand=1, done=0, outrange=0,  GT=0, LT=0, EQ=0, out=  7, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                1625DIP=0000000000, rst=0, enter=0, genrand=1, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 15, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                1635DIP=0000000000, rst=0, enter=0, genrand=1, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 30, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                1645DIP=0000000000, rst=0, enter=0, genrand=1, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 61, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                1650DIP=0000000000, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 61, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                1700DIP=0000000000, rst=0, enter=0, genrand=1, done=0, outrange=0,  GT=0, LT=0, EQ=0, out=  5, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                1705DIP=0000000000, rst=0, enter=0, genrand=1, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 10, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                1715DIP=0000000000, rst=0, enter=0, genrand=1, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 21, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                1725DIP=0000000000, rst=0, enter=0, genrand=1, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 84, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                1735DIP=0000000000, rst=0, enter=0, genrand=1, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 41, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                1745DIP=0000000000, rst=0, enter=0, genrand=1, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 83, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                1750DIP=0000000000, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 83, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                1850DIP=0000000100, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 83, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                1900DIP=0000000000, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 83, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                1950DIP=0000000001, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 83, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                2000DIP=0000000000, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=0, EQ=0, out= 83, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
                2050DIP=0000000000, rst=0, enter=1, genrand=0, done=0, outrange=0,  GT=0, LT=1, EQ=0, out= 83, datain= 80, LL= 80, HL= 99, ps=01, ns=01, cv=111
                2100DIP=0000000000, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=1, EQ=0, out= 83, datain= 80, LL= 80, HL= 99, ps=01, ns=01, cv=111
                2150DIP=0000000100, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=1, EQ=0, out= 83, datain= 80, LL= 80, HL= 99, ps=01, ns=01, cv=111
                2200DIP=0000000000, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=1, EQ=0, out= 83, datain= 80, LL= 80, HL= 99, ps=01, ns=01, cv=111
                2250DIP=0010000000, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=1, EQ=0, out= 83, datain= 80, LL= 80, HL= 99, ps=01, ns=01, cv=111
                2300DIP=0000000000, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=1, EQ=0, out= 83, datain= 80, LL= 80, HL= 99, ps=01, ns=01, cv=111
                2350DIP=0000000000, rst=0, enter=1, genrand=0, done=0, outrange=0,  GT=0, LT=0, EQ=1, out= 83, datain= 83, LL= 83, HL= 83, ps=01, ns=10, cv=111
                2360DIP=0000000000, rst=0, enter=1, genrand=0, done=1, outrange=0,  GT=0, LT=0, EQ=1, out= 83, datain= 83, LL= 83, HL= 83, ps=10, ns=10, cv=000
                2400DIP=0000000000, rst=0, enter=0, genrand=0, done=1, outrange=0,  GT=0, LT=0, EQ=1, out= 83, datain= 83, LL= 83, HL= 83, ps=10, ns=10, cv=000
                2450DIP=0000000000, rst=1, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=0, EQ=0, out=  0, datain=  z, LL=  1, HL= 99, ps=00, ns=01, cv=110
                2500DIP=0000000000, rst=0, enter=0, genrand=0, done=0, outrange=0,  GT=0, LT=0, EQ=0, out=  0, datain=  z, LL=  1, HL= 99, ps=01, ns=01, cv=111
```
Round 1<br>
Random number = 61<br>
rst = 1, genrand = 1,<br>
1st. LL = 01, HL = 99, input = 50,<br>
2nd. LL = 50, HL = 99, input = 20, outrange = 1<br>
3rd. LL = 50, HL = 99, input = 70,<br>
4th. LL = 50, HL = 70, input = 61,<br>
5th. LL = 61, HL = 61, done = 1

Round 2<br>
Random number = 83<br>
rst = 1, genrand = 1,<br>
1st. LL = 01, HL = 99, input = 80,<br>
2nd. LL = 80, HL = 99, input = 83,<br>
3rd. LL = 83, HL = 83, done = 1<br>

## 6.0 Setup
### 6.1 Procedure
#### Installing the USB Blaster Driver
1. Launch **Device Manager >> Other devices**. Select **Update Driver**. Specify the driver location **C:\altera\14.1\quartus\driver\usb-blaster**.
 
#### Project Setting
1. Select **File >> New Project** Wizard menu. Set directory, project name and top-level entity, click **Next**. For the device family, select **MAX II**. In the device list, select **EPM240T100C**. Click **Finish**.
 
#### Project Source Code
1. Create a new document, select **Verilog HDL File**, key in code, save it and set as Top-level entity. Then, click on **Processing >> Start Compilation** menu.
 
#### Pin assignment
1. Click on the **Assignments >> Pin Planner** menu. Then, assign input and output to different pin locations. After setting pin, recompile to generate the FPGA programming file.
 
#### Wiring
1. Connect the pins on EPM240 board. Connect USB Blaster to PC and EPM240 board.
 
#### Programming
1. Select **Tools >> Programmer**.
2. Select **Hardware Setup** to setup USB blaster for programming. Click **Add File** and select POF file in the **output files** directory of the project. Check the **Program/Configure** buttons and click **Start** to program the chip.

### 6.2 Software Setup
Pin Planner
![image](https://user-images.githubusercontent.com/48057545/125210345-dd133d80-e2d1-11eb-822b-6d63cc049d30.png)

### 6.3 Hardware Setup 
![image](https://user-images.githubusercontent.com/48057545/125210415-45fab580-e2d2-11eb-8ac7-20aa41f64d42.png)

## 7.0 Appendix
### Youtube link
Hardware CPLD Demonstration<br>
https://www.youtube.com/watch?v=7cNo8J7qOCw

### EDA Playground link
CU-DU testbench simulation<br>
https://edaplayground.com/x/Rm9U

Top-level module testbench simulation<br>
https://edaplayground.com/x/XLpV
