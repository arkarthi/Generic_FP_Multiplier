////////////////////////////////////////////////////////////////////////////////////////
// Project Code      : S_1006
// Project Name      : Floating Point IP Core
// Module Name       : Stage-4 Pipeline Floating point Multiplication
// Author            : Sruthi
// Function          : Multiply the two floating point operands
////////////////////////////////////////////////////////////////////////////////////////

module stage_4

#( parameter    DW       = 16,    
   parameter    EXP      = 4 ,    
   parameter    MANT     = 10,    
   parameter    CG_EN    = 0     
 )
 
(

        clk                   ,//System Clock  
        en                    ,//Enable signal  
        sign_reg3             ,//Sign bit register
        mant_out_reg3         ,//Mantissa Booth multiplier output 
        exp_reg3              ,//Exponent register value
        over_flow_reg3        ,//Overflow output     
        spe_case_a_reg3       ,//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
        spe_case_b_reg3       ,//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN    
        mant_shift_type_reg3  ,//Shift type right or left shift
        mant_shift_value_reg3 ,//right or left shift value to shifting   

        sign_reg4             ,//Sign bit register
        mant_out_reg4         ,//Mantissa output after shifting opration 
        exp_reg4              ,//Exponent output after shifting opration  
        over_flow_reg4        ,//Overflow for assignation  
        over_flow1_reg4       ,//Overflow output  
        spe_case_a_reg4       ,//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
        spe_case_b_reg4       ,//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN     
        discard_bit_reg4       //Discard bits for rounding calculation
);


/////////////////////////////////////////////////////////////////////////
//-------------Local Parameters--------------------------------------////
/////////////////////////////////////////////////////////////////////////  
  localparam MANT_IMP = MANT+1             ;
  localparam MANT_MUL = MANT_IMP+MANT_IMP  ;
  localparam MANT_MUL1 = MANT_MUL-1        ;
  
  function integer clog2;
    input integer MANT_MUL1;
      begin
        clog2 = 0;
        while (MANT_MUL1 > 0)
          begin
            MANT_MUL1    = MANT_MUL1 >> 1  ;
            clog2       = clog2 +1         ;
          end
       end
   endfunction//clog2
    localparam L_SHIFT      = clog2(MANT_MUL1-1)                ;
    localparam SHIFT        = ((DW==16)? 5 : (DW==32)? 6 : 7)   ;
   
  //////////////////////////////////////////////////
  //              Input Ports                     //       
  //////////////////////////////////////////////////
  input wire                          clk                   ;//System Clock  
  input wire                          en                    ;//Enable signal  
  input wire                          sign_reg3             ;//Sign bit register
  input wire   [MANT_MUL-1  :0]       mant_out_reg3         ;//Mantissa Booth multiplier output 
  input wire   [EXP-1       :0]       exp_reg3              ;//Exponent register value
  input wire                          over_flow_reg3        ;//Overflow output     
  input wire   [2           :0]       spe_case_a_reg3       ;//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
  input wire   [2           :0]       spe_case_b_reg3       ;//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN    
  input wire   [1           :0]       mant_shift_type_reg3  ;//Shift type right or left shift
  input wire   [SHIFT-1     :0]       mant_shift_value_reg3 ;//right or left shift value to shifting   

  //////////////////////////////////////////////////
  //             Output Ports                     //       
  //////////////////////////////////////////////////
  output reg                          sign_reg4             ;//Sign bit register
  output reg   [MANT        :0]       mant_out_reg4         ;//Mantissa output after shifting opration 
  output reg   [EXP-1       :0]       exp_reg4              ;//Exponent output after shifting opration  
  output reg                          over_flow_reg4        ;//Overflow for assignation  
  output reg                          over_flow1_reg4       ;//Overflow output  
  output reg   [2           :0]       spe_case_a_reg4       ;//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
  output reg   [2           :0]       spe_case_b_reg4       ;//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN     
  output reg   [MANT        :0]       discard_bit_reg4      ;//Discard bits for rounding calculation
   

  ///////////////////////////////////////////////////
  //       Stage-4 Internal wires                  //
  ///////////////////////////////////////////////////
  wire   [MANT_MUL-1 :0]  mant_shift_out       ; 
  wire                    w_exp_out1           ; 
  wire                    ove_flow_bit2        ;     
  wire   [MANT_MUL-1 :0]  left_shift_out       ; 
  wire   [MANT_MUL-1 :0]  right_shift_out      ;    
  
  //-----------------------------------------------------------------------------------
  //---------------Pipeline Stage-4 function ------------------------------------------
  //-----------------------------------------------------------------------------------           
 //----------------------Mantissa left shift ------------------------                       
      left_shift
      
      #(
        .MANT_MUL (MANT_MUL), 
		.DW       (DW)
      )
      uut_left_shift
      (
        .shift_time(mant_shift_value_reg3),
        .shift_in  (mant_out_reg3        ),
        .shift_out (left_shift_out       )
      );     

 //----------------------Mantissa right shift ----------------------       
      right_shift
      
      #(
        .MANT_MUL (MANT_MUL) ,
        .DW (DW) 
      )
      uut_right_shift
      (
        .shift_time(mant_shift_value_reg3) ,
        .shift_in  (mant_out_reg3        ) ,
        .shift_out (right_shift_out      )
      );

 //Mantissa left shift & right shift output
 
  assign mant_shift_out =  ((mant_shift_type_reg3==2'b00)?right_shift_out:
                           ((mant_shift_type_reg3==2'b01)?left_shift_out:mant_out_reg3));
                                                            
  assign w_exp_out1        = &(exp_reg3);     
    
  assign ove_flow_bit2     = ( w_exp_out1 | over_flow_reg3 );                             

  //stage-3 output register
generate
  if(CG_EN)
    begin    
      always @(posedge clk )     
        begin                 
          sign_reg4        <= sign_reg3                                    ;
          mant_out_reg4    <= mant_shift_out[MANT_MUL-1     : MANT + 1 ]    ;
          exp_reg4         <= exp_reg3                                     ;
          discard_bit_reg4 <= mant_shift_out[MANT:0 ]                      ;
          over_flow_reg4   <= ove_flow_bit2                                ;
          over_flow1_reg4  <= over_flow_reg3                               ;       
          spe_case_a_reg4  <= spe_case_a_reg3                              ;
          spe_case_b_reg4  <= spe_case_b_reg3                              ;                
        end
    end
  else
    begin    
      always @(posedge clk )  
        if(en)
          begin                 
            sign_reg4        <= sign_reg3                                  ;
            mant_out_reg4    <= mant_shift_out[MANT_MUL-1     : MANT + 1]   ;
            exp_reg4         <= exp_reg3                                   ;
            discard_bit_reg4 <= mant_shift_out[MANT:0 ]                    ;
            over_flow_reg4   <= ove_flow_bit2                              ;
            over_flow1_reg4  <= over_flow_reg3                             ;       
            spe_case_a_reg4  <= spe_case_a_reg3                            ;
            spe_case_b_reg4  <= spe_case_b_reg3                            ;                
          end
    end
endgenerate
    
endmodule