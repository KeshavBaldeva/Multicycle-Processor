`timescale 1ns / 1ps


module Jump_Address(PCout,Instr,PCJump);

input [31:0]PCout,Instr;
output reg [31:0]PCJump;

always@(*)
begin
  PCJump = {PCout[31:28],Instr[25:0],2'b00};
end

endmodule
