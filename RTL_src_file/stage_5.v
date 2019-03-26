////////////////////////////////////////////////////////////////////////////////////////
// Project Code      : S_1006
// Project Name      : Floating Point IP Core
// Module Name       : Stage-5 Pipeline Floating point Multiplication
// Author            : Sruthi
// Function          : Multiply the two floating point operands
////////////////////////////////////////////////////////////////////////////////////////

module stage_5

#( parameter    DW         = 16,    
   parameter    EXP        = 5 ,    
   parameter    MANT       = 10,    
   parameter    CG_EN      = 0 ,
   parameter    ROUND_TYP  = 1   
 )
 
(
  //////////////////////////////////////////////////
  //              Input Ports                     //       
  //////////////////////////////////////////////////
  input wire                    clk                   ,//System Clock  
  input wire                    en                    ,//Enable signal  
  input wire                    sign_reg4             ,//Sign bit register
  input wire   [MANT   :0]      mant_out_reg4         ,//Mantissa output after shifting opration 
  input wire   [EXP-1  :0]      exp_reg4              ,//Exponent output after shifting opration  
  input wire                    over_flow_reg4        ,//Overflow for assignation  
  input wire                    over_flow1_reg4       ,//Overflow output  
  input wire   [2      :0]      spe_case_a_reg4       ,//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
  input wire   [2      :0]      spe_case_b_reg4       ,//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN       
  input wire   [MANT   :0]      discard_bit_reg4      ,//Discard bits for rounding calculation

  //////////////////////////////////////////////////
  //             Output Ports                     //       
  //////////////////////////////////////////////////
 
  output reg  [DW-1    :0]     out_result       , //Final 16-bit single precision floating point multiplication output
  output reg  [2       :0]     num_value        , //identification flag value for Nromalized,De-Normalized,Infinity,Zero or NAN
  output reg                   over_flow        , //Overflow bit
  output reg                   under_flow         //underflow bit
  
);

  
  ///////////////////////////////////////////////////
  //       Stage-4 Internal Wires                  //
  /////////////////////////////////////////////////// 
  wire                round_bit       ; 
  wire                sticky_bit      ;
  wire  [MANT+1    :0]  round_mant_bit  ;
  wire  [MANT+1    :0]  norm_mat_bit    ;
  wire  [EXP-1     :0]  exp_out3        ;
  
  wire                w_nan_1         ;
  wire                w_nan_2         ;
  wire                w_nan_3         ;
  wire                w_infinity      ;
  wire                w_zero          ;
  wire                w_exp_reg4      ;
                      
  wire                w_exp_reg3      ;
  wire                w1_exp_reg3     ;
  wire                w_mant_out_reg3 ;  
  
  ///////////////////////////////////////////////////
  //     Stage-4 Internal Registers                //
  ///////////////////////////////////////////////////  
 
  wire [DW-1  :0]     out_result_tmp ;
  wire [2     :0]     num_value_tmp  ;
  wire                w_und_fl       ;
  
  //-----------------------------------------------------------------------------------
  //---------------Pipeline Stage-5 function ------------------------------------------
  //-----------------------------------------------------------------------------------    
  
  //Round bit assignation
  assign round_bit=discard_bit_reg4[MANT];
  
  //sticky bit calculation
  assign sticky_bit=|discard_bit_reg4[MANT-1:0];
 
generate
 //Rounding function  
  if(ROUND_TYP == 1) //Round to nearest even
  begin
  assign round_mant_bit = ({round_bit,sticky_bit}==2'b00)?({1'b0,mant_out_reg4}):
                          ({round_bit,sticky_bit}==2'b01)?({1'b0,mant_out_reg4}):
                          ({round_bit,sticky_bit}==2'b10)?((mant_out_reg4[0])?(mant_out_reg4+({MANT+1{1'd0}}+1'd1)):({1'b0,mant_out_reg4})):
                                                          (mant_out_reg4+({MANT+1{1'd0}}+1'd1)) ;
  end
  
  else if(ROUND_TYP == 2) //Round toward zero
  begin
  assign round_mant_bit = ({1'b0,mant_out_reg4}) ;
  end
  
  else if(ROUND_TYP == 3) //Round toward +infinity
  begin
  assign round_mant_bit = (~sign_reg4 && (round_bit||sticky_bit))?(mant_out_reg4+({MANT+1{1'd0}}+1'd1)):({1'b0,mant_out_reg4}) ;
  end
  
  else //Round toward -infinity
  begin
  assign round_mant_bit = (sign_reg4 && (round_bit||sticky_bit))?(mant_out_reg4+({MANT{1'd0}}+1'd1)):({1'b0,mant_out_reg4}) ;
  end
  
endgenerate
 
  //Normalization after rounding
  assign norm_mat_bit    = (round_mant_bit[MANT+1])?{1'b0,round_mant_bit[MANT+1:1]}:round_mant_bit;
                         
  //Exponent bit calculation after roundg and normalization
  assign exp_out3        = (round_mant_bit[MANT+1]) ? exp_reg4+({EXP{1'd0}}+1'd1) : exp_reg4; 
                         
  assign w_nan_1         = (spe_case_a_reg4==3'd4)|(spe_case_b_reg4==3'd4);
  assign w_nan_2         = (spe_case_a_reg4==3'd3)&(spe_case_b_reg4==3'd2);
  assign w_nan_3         = (spe_case_a_reg4==3'd2)&(spe_case_b_reg4==3'd3);
  assign w_infinity      = (spe_case_a_reg4==3'd3)|(spe_case_b_reg4==3'd3);
  assign w_zero          = (spe_case_a_reg4==3'd2)|(spe_case_b_reg4==3'd2);
                         
  assign w_exp_reg4      = &(exp_out3);
  
  assign w_exp_reg3      = &(exp_out3);
                           
  assign w1_exp_reg3     = |(exp_out3);  
                           
  assign w_mant_out_reg3 = |(norm_mat_bit[MANT-1:0 ]);
                           
  assign w_und_fl        = (~w1_exp_reg3)&(~w_mant_out_reg3);
								   
  //Final output result assignation
  assign out_result_tmp    =(w_nan_1 || w_nan_2 || w_nan_3)  ? {sign_reg4,{EXP{1'd1}},{{MANT{1'd0}}+1'd1}}:  //NAN(Not A Number) result  
                            (w_infinity || over_flow_reg4)   ? {sign_reg4,{EXP{1'd1}},{MANT{1'd0}} }:        //Infinity result
                            (w_zero                     )    ? {sign_reg4,{EXP{1'd0}},{MANT{1'd0}} }:        //Zero value result
                                                               {sign_reg4,exp_out3,norm_mat_bit[MANT-1:0]};  //Normalized or denormalized result
  //Final Flag value assignation  
  assign num_value_tmp     =(w_nan_1 || w_nan_2 || w_nan_3)                                   ? 3'd4: //NAN(Not A Number) 
                            (w_infinity || over_flow_reg4 ||(w_exp_reg3 &&(!w_mant_out_reg3)))? 3'd3: //Infinity value
                            (w_zero || w_und_fl)                                              ? 3'd2: //Zero value
                            ((!w1_exp_reg3) && w_mant_out_reg3)                               ? 3'd1: //Denormalized
                                                                                                3'd0; //Normalized or denormalized value				
generate
  if(CG_EN)
    begin    
      always @(posedge clk) 
        begin                 	
          under_flow         <= (~w_zero)& w_und_fl                                  ;	
          over_flow          <= (w_exp_reg4|over_flow1_reg4)&(~w_nan_1)&(~w_infinity);		
          out_result         <= out_result_tmp                                       ;
          num_value          <= num_value_tmp                                        ;		                   
        end                 
    end
  else
    begin    
      always @(posedge clk)
        if(en)
          begin                 	
            under_flow       <= (~w_zero)& w_und_fl                                  ;	
            over_flow        <= (w_exp_reg4|over_flow1_reg4)&(~w_nan_1)&(~w_infinity);		
            out_result       <= out_result_tmp                                       ;
            num_value        <= num_value_tmp                                        ;		                   
          end  
    end  
endgenerate
endmodule  