////////////////////////////////////////////////////////////////////////////////////////
// Project Code      : S_1006
// Project Name      : Floating Point IP Core
// Module Name       : Generic CSA 
// Author            : Sruthi
// Function          : Multiply the two floating point operands
////////////////////////////////////////////////////////////////////////////////////////

module generic_csa
#(
  parameter DW_A = 10,  
  parameter DW_B = 10,
  parameter REG  = 0  
)
(
  input  wire                 clk,
  input  wire [DW_A+DW_B-1:0] in_1,
  input  wire [DW_A+DW_B-1:0] in_2,
  input  wire [DW_A+DW_B-1:0] in_3,
  output reg  [DW_A+DW_B-1:0] csa_s,
  output reg  [DW_A+DW_B-1:0] csa_c  
);

wire [DW_A+DW_B-1:0] csa_c_shft;  
assign csa_c_shft = ( in_1 & in_2 )|( in_2 & in_3 )|( in_3 & in_1);

generate
  if(REG)
    begin
      always@(posedge clk)
      begin  
        csa_s   <= in_1 ^ in_2 ^ in_3;  
        csa_c   <= {csa_c_shft[DW_A+DW_B-2:0],1'b0}; 
      end
	end
  else
    begin
      always@(*)
      begin  
        csa_s   = in_1 ^ in_2 ^ in_3;  
        csa_c   = {csa_c_shft[DW_A+DW_B-2:0],1'b0}; 
      end
	end
endgenerate
endmodule