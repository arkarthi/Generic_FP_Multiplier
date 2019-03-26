///////////////////////////////////////////////////////////////////////////////////////////////
// Project Code      : S_1006
// Project Name      : Floating Point IP Core
// Module Name       : Stage-I Pipeline Floating point Multiplication
// Author            : Sruthi
// Function          : Divide the Mantissa,Exponent and Sign bit from 16-bit half precision 
//                     floating point input
//////////////////////////////////////////////////////////////////////////////////////////////

module stage_1

#(
   parameter    DW       = 16 ,
   parameter    EXP      = 5  ,
   parameter    MANT     = 10 ,
   parameter    CG_EN    = 0    
 )
(
  //////////////////////////////////////////////////
  //              Input Ports                     //       
  //////////////////////////////////////////////////
  
  input wire                        clk              , //System input clock
  input wire  [DW-1       :0]       opa_a            , //16-bit half precision floating point input-A
  input wire  [DW-1       :0]       opa_b            , //16-bit half precision floating point input-B
  input wire                        en               , //Enable signal 
  //////////////////////////////////////////////////
  //             Output Ports                     //       
  //////////////////////////////////////////////////
  output reg                         sign_reg         , //Sign output
  output reg   [MANT      :0]        mant_opa_a_reg   , //Mantissa bit of input-A
  output reg   [MANT      :0]        mant_opa_b_reg   , //Mantissa bit of input-B
  output reg   [EXP-1     :0]        exp_opa_a_reg    , //Exponent bit of input-A
  output reg   [EXP-1     :0]        exp_opa_b_reg    , //Exponent bit of input-B
  output reg   [2         :0]        spe_case_a_reg   , //Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
  output reg   [2         :0]        spe_case_b_reg   , //Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
  output reg                         exp_eq_inf_reg     //To identify exponent value equal to 255 or not 
);                            

//-------------------------------------------------------------------------------
//----------STAGE-I(Sign,Exponent and Mantissa bit segmentation)-----------------
//-------------------------------------------------------------------------------

  ///////////////////////////////////////////////////
  //       Stage-1 Internal Wires                  //
  ///////////////////////////////////////////////////  
  wire                    sign_opa_a            ;
  wire  [MANT     :0]     mant_opa_a            ;
  wire  [EXP-1    :0]     exp_opa_a             ;
  wire                    opa_a_not_eq_0        ;  
  wire                    sign_opa_b            ;
  wire  [MANT     :0]     mant_opa_b            ;
  wire  [EXP-1    :0]     exp_opa_b             ;
  wire                    opa_b_not_eq_0        ;    
  wire                    opa_a_exp_eq_inf      ;
  wire                    opa_a_mant_not_eq_0   ;  
  wire                    opa_b_exp_eq_inf      ;
  wire                    opa_b_mant_not_eq_0   ;     
  wire  [2        :0]     spe_case_a            ;
  wire  [2        :0]     spe_case_b            ;
  wire                    sign_out              ;
  wire                    exp_eq_inf            ;
                         
  //-----------------------------------------------------------------------------------
  //---------------Pipeline Stage-1 function ------------------------------------------
  //-----------------------------------------------------------------------------------
  
  //input oprand 'A' in floating point representation  
  assign sign_opa_a             =  opa_a[DW-1]                                                ;
  assign opa_a_not_eq_0         =  |(opa_a[(MANT+EXP)-1:MANT])                                ;
  assign mant_opa_a             =  {opa_a_not_eq_0,opa_a[MANT-1:0]}                           ;
  assign exp_opa_a              =  opa_a[(MANT+EXP)-1:MANT]+{{EXP-1{1'd0}},(~opa_a_not_eq_0)} ;
                               
  //input oprand 'B' in floating point representation  
  assign sign_opa_b             =  opa_b[DW-1]                                                ;
  assign opa_b_not_eq_0         =  |(opa_b[(MANT+EXP)-1:MANT])                                ;  
  assign mant_opa_b             =  {opa_b_not_eq_0,opa_b[MANT-1:0]}                           ;
  assign exp_opa_b              =  opa_b[(MANT+EXP)-1:MANT]+{{EXP-1{1'd0}},(~opa_b_not_eq_0)} ;
  
  //Special case in operand "A"
  assign opa_a_exp_eq_inf       =  &(opa_a[(MANT+EXP)-1:MANT])   ;    
  assign opa_a_mant_not_eq_0    =  |(opa_a[MANT-1:0])            ;  
  assign spe_case_a             =  ((!opa_a_not_eq_0) && opa_a_mant_not_eq_0     ) ?3'd1:   //special case De-Normalized form for operand 'A'
                                   ((!opa_a_not_eq_0) && (!opa_a_mant_not_eq_0)  ) ?3'd2:   //special case Zero for operand 'A'
                                   (opa_a_exp_eq_inf  && (!opa_a_mant_not_eq_0)  ) ?3'd3:   //special case Infinity for operand 'A'
                                   (opa_a_exp_eq_inf  &&  opa_a_mant_not_eq_0    ) ?3'd4:  //special case NAN for operand 'A'
                                                                                    3'd0;   //special case Normalized form for operand 'A'                                                                     
  //Special case in operand "B"
  assign opa_b_exp_eq_inf      =   &(opa_b[(MANT+EXP)-1:MANT]) ;    
  assign opa_b_mant_not_eq_0   =   |(opa_b[MANT-1:0]);    
  assign spe_case_b            =   ((!opa_b_not_eq_0) &&  opa_b_mant_not_eq_0    ) ?3'd1:   //special case De-Normalized form for operand 'B'
                                   ((!opa_b_not_eq_0) && (!opa_b_mant_not_eq_0)  ) ?3'd2:   //special case Zero for operand 'B'
                                   (opa_b_exp_eq_inf  && (!opa_b_mant_not_eq_0)  ) ?3'd3:   //special case Infinity for operand 'B'
                                   (opa_b_exp_eq_inf  &&  opa_b_mant_not_eq_0    ) ?3'd4:   //special case NAN for operand 'B'
                                                                                    3'd0;   //special case Normalized form for operand 'A'                                                                        
  //Sign bit calculation
  assign sign_out              =   sign_opa_a ^ sign_opa_b ;
  
  //exp_eq_inf     
  assign exp_eq_inf            =   ~(opa_a_exp_eq_inf | opa_b_exp_eq_inf);           //if both exponents are not equal to infinity exp_eq_inf is set
   
generate
  if(CG_EN)
    begin  
      always @(posedge clk)                   
          begin             
            sign_reg         <= sign_out         ;
            exp_opa_a_reg    <= exp_opa_a        ;
            exp_opa_b_reg    <= exp_opa_b        ; 
            spe_case_a_reg   <= spe_case_a       ;   
            spe_case_b_reg   <= spe_case_b       ;
            exp_eq_inf_reg   <= exp_eq_inf       ;
            mant_opa_a_reg   <= mant_opa_a       ;
            mant_opa_b_reg   <= mant_opa_b       ;
          end 
    end
  else
    begin
      always @(posedge clk) 
        if(en)
          begin             
            sign_reg         <= sign_out         ;
            exp_opa_a_reg    <= exp_opa_a        ;
            exp_opa_b_reg    <= exp_opa_b        ; 
            spe_case_a_reg   <= spe_case_a       ;   
            spe_case_b_reg   <= spe_case_b       ;
            exp_eq_inf_reg   <= exp_eq_inf       ;
            mant_opa_a_reg   <= mant_opa_a       ;
            mant_opa_b_reg   <= mant_opa_b       ;
          end     
    end
endgenerate      

endmodule