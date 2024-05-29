`timescale 1ns / 1ps


module Control_Unit(clk,reset,IorD,MemWrite,IRWrite,Opcode,PCWrite,Branch,PCSrc,ALUop,ALUSrcB,ALUSrcA,RegWrite,RegDst,MemtoReg);

// Note that we are not writing Funct input here because function will be in ALU_Control Module.
// We are writing ALUop instead of ALUControl because ALUControl is generated by ALU_Control unit.
input clk,reset;
input [5:0]Opcode;
output reg IorD,MemWrite,IRWrite,PCWrite,Branch,ALUSrcA,RegWrite,RegDst,MemtoReg;
output reg [1:0]ALUSrcB,ALUop,PCSrc;
reg [3:0]state,next_state;

parameter s0=4'b0000;//Fetch
parameter s1=4'b0001;//Decode
parameter s2=4'b0010;//Memory Address
parameter s3=4'b0011;//Memory Read
parameter s4=4'b0100;//Memory Write Back
parameter s5=4'b0101;//Memory write
parameter s6=4'b0110;//Executin
parameter s7=4'b0111;//ALU Writeback
parameter s8=4'b1000;//Branch instruction
parameter s9=4'b1001;//AddI
parameter s10=4'b1010;//ADDI Writeback
parameter s11=4'b1011;//Jump instruction

// Opcodes for different instruction types
parameter LW = 6'b100011;
parameter SW = 6'b101011;
parameter R_TYPE = 6'b000000;
parameter BEQ = 6'b000100;
parameter ADDI = 6'b001000;
parameter J = 6'b000010;

always@(posedge clk)
begin
  if(reset)
  state<=s0;
  else
  state<=next_state;
end

initial
begin
  state=s0;
  next_state=s0;
  IorD = 0;
  MemWrite = 0;
  IRWrite = 1;
  PCWrite = 1;
  Branch = 0;
  ALUSrcA = 0;
  RegWrite = 0;
  RegDst = 1'bx;
  MemtoReg = 1'bx;
  ALUSrcB = 2'b01;
  ALUop = 2'b00;
  PCSrc = 2'b00;
end

//Deciding the next state
always@(posedge clk)
begin
  case(state)
    s0:next_state = s1;
    
    s1:
    begin
     case(Opcode)
      LW: next_state = s2;     
      SW: next_state = s2;     
      R_TYPE: next_state = s6; 
      BEQ: next_state = s8;   
      ADDI: next_state = s9;  
      J: next_state = s11;     
      default: next_state = s0; 
     endcase
    end
    
    s2:
    begin
     if(Opcode == LW)next_state = s3;
     else if(Opcode == SW) next_state = s5;
    end
    
    s3:next_state = s4;
    
    s4,s5,s7,s8,s10,s11:next_state = s0;
    
    s6:next_state = s7;
    
    s9:next_state = s10;
    
    default:next_state = s0;  
  endcase
end

//Assigning values to all outputs in each state
always@(posedge clk)
begin
  case(state)
     s0:
     begin
        RegWrite = 0;
        MemWrite = 0;
        IRWrite = 1;
        PCWrite = 1;
        Branch = 0;
        
        ALUSrcA = 0;
        IorD = 0;
        RegDst = 1'b0;
        MemtoReg = 1'b0;
        ALUSrcB = 2'b01;
        ALUop = 2'b00;
        PCSrc = 2'b00;
     end
     
     s1:
     begin
        RegWrite = 0;
        MemWrite = 0;
        IRWrite = 0;
        PCWrite = 0;
        Branch = 0;
        
        ALUSrcA = 0;
        IorD = 1'b0;
        RegDst = 1'b0;
        MemtoReg = 1'b0;
        ALUSrcB = 2'b11;
        ALUop = 2'b00;
        PCSrc = 2'b00;
     end
     
     s2:
     begin
        RegWrite = 0;
        MemWrite = 0;
        IRWrite = 0;
        PCWrite = 0;
        Branch = 0;
        
        ALUSrcA = 1;
        IorD = 1'b0;
        RegDst = 1'b0;
        MemtoReg = 1'b0;
        ALUSrcB = 2'b10;
        ALUop = 2'b00;
        PCSrc = 2'b00;
     end
     
     s3:
     begin
        RegWrite = 0;
        MemWrite = 0;
        IRWrite = 0;
        PCWrite = 0;
        Branch = 0;
        
        ALUSrcA = 1'b0;
        IorD = 1;
        RegDst = 1'b0;
        MemtoReg = 1'b0;
        ALUSrcB = 2'b00;
        ALUop = 2'b00;
        PCSrc = 2'b00;
     end
     
     s4:
     begin
        RegWrite = 1;
        MemWrite = 0;
        IRWrite = 0;
        PCWrite = 0;
        Branch = 0;
        
        ALUSrcA = 1'b0;
        IorD = 1'b0;
        RegDst = 0;
        MemtoReg = 1;
        ALUSrcB = 2'b11;
        ALUop = 2'b00;
        PCSrc = 2'b00;
     end
     
     s5:
     begin
        RegWrite = 0;
        MemWrite = 1;
        IRWrite = 0;
        PCWrite = 0;
        Branch = 0;
        
        ALUSrcA = 1'b0;
        IorD = 1;
        RegDst = 1'b0;
        MemtoReg = 1'b0;
        ALUSrcB = 2'b00;
        ALUop = 2'b00;
        PCSrc = 2'b00;
     end
     
     s6:
     begin
        RegWrite = 0;
        MemWrite = 0;
        IRWrite = 0;
        PCWrite = 0;
        Branch = 0;
        
        ALUSrcA = 1;
        IorD = 1'b0;
        RegDst = 1'b0;
        MemtoReg = 1'b0;
        ALUSrcB = 2'b00;
        ALUop = 2'b10;
        PCSrc = 2'b00;
     end
     
     s7:
     begin
        RegWrite = 1;
        MemWrite = 0;
        IRWrite = 0;
        PCWrite = 0;
        Branch = 0;
        
        ALUSrcA = 1'b0;
        IorD = 1'b0;
        RegDst = 1;
        MemtoReg = 0;
        ALUSrcB = 2'b00;
        ALUop = 2'b00;
        PCSrc = 2'b00;
     end
     
     s8:
     begin
        RegWrite = 0;
        MemWrite = 0;
        IRWrite = 0;
        PCWrite = 0;
        Branch = 1;
        
        ALUSrcA = 1;
        IorD = 1'b0;
        RegDst = 1'b0;
        MemtoReg = 1'b0;
        ALUSrcB = 2'b00;
        ALUop = 2'b01;
        PCSrc = 2'b01;
     end
     
     s9:
     begin
        RegWrite = 0;
        MemWrite = 0;
        IRWrite = 0;
        PCWrite = 0;
        Branch = 0;
        
        ALUSrcA = 1;
        IorD = 1'b0;
        RegDst = 1'b0;
        MemtoReg = 1'b0;
        ALUSrcB = 2'b10;
        ALUop = 2'b00;
        PCSrc = 2'b00;
     end
     
     s10:
     begin
        RegWrite = 1;
        MemWrite = 0;
        IRWrite = 0;
        PCWrite = 0;
        Branch = 0;
        
        ALUSrcA = 1'b0;
        IorD = 1'b0;
        RegDst = 0;
        MemtoReg = 0;
        ALUSrcB = 2'b00;
        ALUop = 2'b00;
        PCSrc = 2'b00;
     end
     
     s11:
     begin
        RegWrite = 0;
        MemWrite = 0;
        IRWrite = 0;
        PCWrite = 1;
        Branch = 0;
        
        ALUSrcA = 1'b0;
        IorD = 1'b0;
        RegDst = 1'b0;
        MemtoReg = 1'b0;
        ALUSrcB = 2'b00;
        ALUop = 2'b00;
        PCSrc = 2'b10;
     end
     
  endcase
  
end

endmodule