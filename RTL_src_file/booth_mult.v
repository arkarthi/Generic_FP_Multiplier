////////////////////////////////////////////////////////////////////////////////////////
// Project Code      : S_1006
// Project Name      : Floating Point IP Core
// Module Name       : Generic Booth multiplier
// Function          : Multiply the two floating point operands
////////////////////////////////////////////////////////////////////////////////////////

module booth_mult
#(
  parameter A_SIGNED = 0,
  parameter B_SIGNED = 0,    
  parameter A_DW     = 11,  //input1 datawidth
  parameter B_DW     = 11,  //input2 datawidth
  parameter PP_REG   = 0 ,
  parameter ADD_REG  = 0
)
(
  input  wire                 clk     ,
  input  wire [A_DW-1:0]      mult_in1,
  input  wire [B_DW-1:0]      mult_in2,
  output wire [A_DW+B_DW-1:0] mult_out       
);  

////////////////////////////////////////////////////////////////////////////////
//-----------------Local parameter Declaration--------------------------------//
////////////////////////////////////////////////////////////////////////////////

  localparam MIN_W   = ( A_DW < B_DW ) ? A_DW    : B_DW   ;   // minimum input datawidth
  localparam MAX_W   = ( A_DW >=B_DW ) ? A_DW    : B_DW   ;   // maximum input datawidth 
  localparam MIN_EW  = ( (MIN_W+1)%2 ) ?(MIN_W+2):MIN_W+1 ;   // changing multiplier size to even bitwidth for radix_4 booth                                   
  localparam NUM_PP  = ( MIN_EW/2 ) + 1                   ;   // number of partial products
  localparam NUM_CSA = ( NUM_PP-2 )                       ;   // number of CSA blocks
  localparam CSA_OUT = ( 3*NUM_PP ) - 5                   ;   // number of CSA outputs
  
////////////////////////////////////////////////////////////////////////////////
//-----------------Internal Signal Declaration--------------------------------//
//////////////////////////////////////////////////////////////////////////////// 
 
 wire [MAX_W-1     :0] in_1                       ;
 wire [MIN_W-1     :0] in_2                       ;
 wire [MAX_W      :0] multicnd                    ;         // multiplicand - input with max DW 
 wire [MIN_W      :0] multiplier                  ;         // multiplier   - input with min DW 
 wire [MIN_EW+2   :0] multiplier_adj              ;         // adjusting multiplier to even DW 
 wire [MAX_W+2    :0] multicnd_x_1                ;         // ( multiplicand  )
 wire [MAX_W+2    :0] multicnd_x_2                ;         // (2*multiplicand )
 wire [MAX_W+2    :0] multicnd_x_minus1           ;         // 1's comp of multicnd_x_1
 wire [MAX_W+2    :0] multicnd_x_minus2           ;         // 1's comp of multicnd_x_2
 reg  [MAX_W+2    :0] ppg_out    [0:(MIN_EW/2)  ] ;         // partial products without sign extension
 reg  [A_DW+B_DW-1:0] ppg_out_se [0:(MIN_EW/2)  ] ;         // partial products with sign extension
 wire [A_DW+B_DW-1:0] csa_in     [0:CSA_OUT     ] ;         // left shifted partial products for CSA inputs
 reg                  flag_bit   [0:(MIN_EW/2)+1] ;         // flag bit  

 
 reg [A_DW+B_DW-1:0] csa_final_s                  ;  
 reg [A_DW+B_DW-1:0] csa_final_c                  ;  
 //reg [A_DW+B_DW-1:0] csa_reg                      ;  
 

generate

 if (MAX_W == A_DW)
   begin   
	 assign in_1 = mult_in1;
	 assign in_2 = mult_in2; 
   end
 else
   begin  
	 assign in_1 = mult_in2;
	 assign in_2 = mult_in1; 
   end
	 
 if(A_SIGNED == 0 && B_SIGNED == 0)
   begin
     assign multicnd     = {1'd0,in_1};
     assign multiplier   = {1'd0,in_2};
   end
  else if (A_SIGNED == 0 && B_SIGNED == 1)
   begin
     assign multicnd     = {1'd0,in_1};
     assign multiplier   = {in_2[B_DW-1],in_2}; 
   end
  else if (A_SIGNED == 1 && B_SIGNED == 0)
   begin
     assign multicnd     = {in_1[A_DW-1],in_1};
     assign multiplier   = {1'd0,in_2};    
   end
  else
   begin
     assign multicnd     = {in_1[A_DW-1],in_1};
     assign multiplier   = {in_2[B_DW-1],in_2}; 
   end		  		  

 endgenerate             

  assign multicnd_x_1      = {{2{multicnd[MAX_W]}},multicnd};
  assign multicnd_x_2      = {multicnd_x_1[MAX_W+1:0],1'b0} ;
  assign multicnd_x_minus1 = (~multicnd_x_1)                ;
  assign multicnd_x_minus2 = (~multicnd_x_2)                ;

////////////////////////////////////////////////////////////////////////////////
//------------------Multiplier adjustment to even bitwidth--------------------//
////////////////////////////////////////////////////////////////////////////////
 
generate
    if (MIN_EW == MIN_W+1) 
      begin
  	   assign multiplier_adj = {{2{multiplier[MIN_W]}},multiplier,1'b0};
      end
    else 
      begin 
  	   assign multiplier_adj = {{3{multiplier[MIN_W]}},multiplier,1'b0};
      end
endgenerate
	  
////////////////////////////////////////////////////////////////////////////////
//------------partial product generation using radix_4 recoding---------------//
////////////////////////////////////////////////////////////////////////////////

genvar i;
  generate 
    for (i=0; i<=((MIN_EW+2)/2)-1; i=i+1)
    begin : loop1
	 always @ (*)
	   begin
	     flag_bit[0] = 1'b0;
           case(multiplier_adj[(i*2) +: 3])
		         3'b001  : begin ppg_out[i] = multicnd_x_1      ; flag_bit[i+1] = 1'b0 ; end
			     3'b010  : begin ppg_out[i] = multicnd_x_1      ; flag_bit[i+1] = 1'b0 ; end
                 3'b011  : begin ppg_out[i] = multicnd_x_2      ; flag_bit[i+1] = 1'b0 ; end 
			     3'b100  : begin ppg_out[i] = multicnd_x_minus2 ; flag_bit[i+1] = 1'b1 ; end
			     3'b101  : begin ppg_out[i] = multicnd_x_minus1 ; flag_bit[i+1] = 1'b1 ; end
			     3'b110  : begin ppg_out[i] = multicnd_x_minus1 ; flag_bit[i+1] = 1'b1 ; end
		       default : begin ppg_out[i] = {MAX_W+3{1'd0}}   ; flag_bit[i+1] = 1'b0 ; end
          endcase
	   end  
     
	 if(PP_REG)
	   begin
	     always @ (posedge clk)
           ppg_out_se[i] <= {{MIN_W-3{ppg_out[i][MAX_W+2]}},ppg_out[i]} ;
       end
	 else
	   begin
	     always @(*)
	       ppg_out_se[i] = {{MIN_W-3{ppg_out[i][MAX_W+2]}},ppg_out[i]}  ;
       end 

     if(i==0)
       assign csa_in[i] = {ppg_out_se[i][A_DW+B_DW-1:0]};
     else
	   assign csa_in[i] = {ppg_out_se[i][A_DW+B_DW-1-(2*i):0],{{1'b0,flag_bit[i],{(2*(i-1)){1'b0}}}}};	

	 end
endgenerate     
 
////////////////////////////////////////////////////////////////////////////////
//----------------------------carry save adder--------------------------------//
////////////////////////////////////////////////////////////////////////////////
 
 genvar k;
 generate
   for (k=0; k<=(NUM_CSA-1)*3; k=k+3)
     begin : loop2
	   generic_csa 
	         #(
               .DW_A (A_DW),                  
               .DW_B (B_DW),
               .REG  (0   )			   
              )   
		 fa (
              .clk  ( clk                         ),     
		      .in_1 ( csa_in[k]                   ), 
	          .in_2 ( csa_in[k+1]                 ), 
			  .in_3 ( csa_in[k+2]                 ),
			  .csa_s( csa_in[(k/3)+(k/3)+NUM_PP]  ),
			  .csa_c( csa_in[(k/3)+(k/3)+NUM_PP+1])
 			  );
     end
 endgenerate  

////////////////////////////////////////////////////////////////////////////////
//------------------------multiplier output-----------------------------------//
////////////////////////////////////////////////////////////////////////////////
 generate 
  if(ADD_REG)
	 begin
	   always @ (posedge clk)
	   begin
         csa_final_s <= csa_in[CSA_OUT-1];
		     csa_final_c <= csa_in[CSA_OUT];
	   end
     end
  else
	 begin
	   always @(*)
	    begin
         csa_final_s = csa_in[CSA_OUT-1];
		     csa_final_c = csa_in[CSA_OUT];
	   end 
     end 
 endgenerate	 
	 
	   assign mult_out = csa_final_s + csa_final_c; 
	   
endmodule 