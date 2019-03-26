////////////////////////////////////////////////////////////////////////////////////////
// Project Code      : S_1006
// Project Name      : Floating Point IP Core
// Module Name       : Stage-2 Pipeline Floating point Multiplication
// Author            : Sruthi
// Function          : Multiply the two floating point operands
////////////////////////////////////////////////////////////////////////////////////////

module stage_2

#(
   parameter    DW       = 16 ,    
   parameter    EXP      = 4  ,    
   parameter    MANT     = 10 ,    
   parameter    CG_EN    = 0   
 )
 
(
  
       clk                ,//System input clock
       en                 ,//Enable signal    
       sign_reg           ,//Mantissa Booth multiplier output
       mant_out_reg       ,//Sign bit register
       exp_opa_a_reg      ,//Exponent bit of input-A 
       exp_opa_b_reg      ,//Exponent bit of input-B     
       spe_case_a_reg     ,//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
       spe_case_b_reg     ,//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN 
       exp_eq_inf_reg     , //To identify exponent value equal to 31 or not  
                          
 
       flag_bit_reg        , //flgbit register for mantissa shift 
       sign_reg2           , //Sign bit register 
       l_shift_time_reg    , //Leading Zero detection for Mantissa Booth multiplier output
       exp_out_reg         , //Exponent register value E=Ea+Eb-15
       exp_out_gt_max_reg  , //To identify exponent value greater to 31 or not     
       add_less_bias_reg   , //To identify exponent addition value Lesser to 15 or not 
       add_gt_bias_reg     , //To identify exponent addition value greater to 15 or not 
       mat_out_bit_inv_reg , //To find shifting concept 
       mant_out_reg_2      , //Mantissa Booth multiplier output
       spe_case_a_reg2     , //Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
       spe_case_b_reg2     , //Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN   
       exp_eq_inf_reg2        //To identify exponent value equal to 31 or not  
);  

/////////////////////////////////////////////////////////////////////////
//-------------Local Parameters--------------------------------------////
/////////////////////////////////////////////////////////////////////////  
  localparam  MANT_IMP   = MANT     + 1         ;
  localparam  MANT_MUL   = MANT_IMP + MANT_IMP  ;
  localparam  MANT_MUL1  = MANT_MUL - 1         ;
  
  function integer clog2;
    input integer MANT_MUL1;
      begin
        clog2 = 0;
        while (MANT_MUL1 > 0)
          begin
            MANT_MUL1    = MANT_MUL1 >> 1  ;
            clog2        = clog2 +1        ;
          end
       end
   endfunction//clog2
   
  localparam  L_SHIFT     = clog2(MANT_MUL1-1)  ;
  
  //---------------------------------------------------//
  //-------------------Input Ports --------------------//       
  //---------------------------------------------------//
  
  input wire                        clk                 ; //System input clock
  input wire                        en                  ; //Enable signal    
  input wire                        sign_reg            ; //Mantissa Booth multiplier output
  input wire   [MANT_MUL-1  :0]     mant_out_reg        ; //Sign bit register
  input wire   [EXP-1       :0]     exp_opa_a_reg       ; //Exponent bit of input-A 
  input wire   [EXP-1       :0]     exp_opa_b_reg       ; //Exponent bit of input-B     
  input wire   [2           :0]     spe_case_a_reg      ; //Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
  input wire   [2           :0]     spe_case_b_reg      ; //Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN 
  input wire                        exp_eq_inf_reg      ; //To identify exponent value equal to 31 or not  
                                                     
  //------------------------------------------------------//
  //-------------------Output Ports-----------------------//       
  //------------------------------------------------------//
   
  output reg                         flag_bit_reg        ; //flgbit register for mantissa shift 
  output reg                         sign_reg2           ; //Sign bit register 
  output reg   [L_SHIFT-1   :0]      l_shift_time_reg    ; //Leading Zero detection for Mantissa Booth multiplier output
  output reg   [EXP         :0]      exp_out_reg         ; //Exponent register value E=Ea+Eb-15
  output reg                         exp_out_gt_max_reg  ; //To identify exponent value greater to 31 or not     
  output reg                         add_less_bias_reg   ; //To identify exponent addition value Lesser to 15 or not 
  output reg                         add_gt_bias_reg     ; //To identify exponent addition value greater to 15 or not 
  output reg                         mat_out_bit_inv_reg ; //To find shifting concept 
  output reg   [MANT_MUL-1  :0]      mant_out_reg_2      ; //Mantissa Booth multiplier output
  output reg   [2           :0]      spe_case_a_reg2     ; //Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
  output reg   [2           :0]      spe_case_b_reg2     ; //Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN   
  output reg                         exp_eq_inf_reg2     ; //To identify exponent value equal to 31 or not  
 
 
  ///////////////////////////////////////////////////
  //----------Internal Wires-----------------------//
  ///////////////////////////////////////////////////  
  wire  [EXP        :0]      addition           ;//Exponent Addition value E=Ea+Eb
  wire                       add_gt_bias        ;//To identify exponent addition value greater to 15 or not
  wire                       add_less_bias      ;//To identify exponent addition value Lesser to 15 or not   
  wire  [EXP        :0]      exp_out            ;//Exponent register value E=Ea+Eb-15
  wire                       exp_out_gt_max     ;//To identify exponent value greater to 31 or not    
  wire                       flag_bit           ;//Flag bit assignation
  wire                       mat_out_bit_inv    ;//To find shifting concept 
  wire  [L_SHIFT-1  :0]      l_shift_time       ;//Leading Zero detection for Mantissa Booth multiplier output
  
  //-----------------------------------------------------------------------------------
  //---------------Pipeline Stage-2 function ------------------------------------------
  //-----------------------------------------------------------------------------------
 
  //Exponent addition
  assign addition        =  exp_opa_a_reg + exp_opa_b_reg                                  ;  
  assign add_less_bias   =  (addition < {EXP-1{1'd1}} )                                    ;   
  assign add_gt_bias     =  (addition > {EXP-1{1'd1}} )                                    ;
  
  //Exponent bit calculation
  assign exp_out         =  (add_gt_bias)?addition-({EXP-1{1'd1}}):({EXP-1{1'd1}})-addition  ;    
  assign exp_out_gt_max  =  (exp_out > {EXP{1'd1}}-1)                                      ;  
  
  //Flag bit assignation
  assign flag_bit        = |(exp_out[EXP-1:0])                                             ;
  assign mat_out_bit_inv = |(mant_out_reg[MANT_MUL1:MANT_MUL1-1])                          ;
  
  //leading zero detection concept  
  generic_lead_zero_detect
   #( .DW (MANT_MUL1))
   uut_lead_zero_detect
   (
    .in_d  (mant_out_reg[MANT_MUL1-1:0] ),
    .out_d (l_shift_time                )
   );
  
  //stage-1 output register
generate
  if(CG_EN)
    begin
      always @(posedge clk)                    
        begin                 
          flag_bit_reg         <= flag_bit        ;
          sign_reg2            <= sign_reg        ; 
          l_shift_time_reg     <= l_shift_time    ;
          exp_out_reg          <= exp_out         ;
          exp_out_gt_max_reg   <= exp_out_gt_max  ;
          add_less_bias_reg    <= add_less_bias   ;
          add_gt_bias_reg      <= add_gt_bias     ;
          mat_out_bit_inv_reg  <= mat_out_bit_inv ;
          mant_out_reg_2       <= mant_out_reg    ;
          exp_eq_inf_reg2      <= exp_eq_inf_reg  ; 
          spe_case_a_reg2      <= spe_case_a_reg  ;
          spe_case_b_reg2      <= spe_case_b_reg  ;        
        end
    end
  else
    begin
      always @(posedge clk)  
        if(en)
          begin                 
            flag_bit_reg         <= flag_bit        ;
            sign_reg2            <= sign_reg        ; 
            l_shift_time_reg     <= l_shift_time    ;
            exp_out_reg          <= exp_out         ;
            exp_out_gt_max_reg   <= exp_out_gt_max  ;
            add_less_bias_reg    <= add_less_bias   ;
            add_gt_bias_reg      <= add_gt_bias     ;
            mat_out_bit_inv_reg  <= mat_out_bit_inv ;
            mant_out_reg_2       <= mant_out_reg    ;
            exp_eq_inf_reg2      <= exp_eq_inf_reg  ; 
            spe_case_a_reg2      <= spe_case_a_reg  ;
            spe_case_b_reg2      <= spe_case_b_reg  ;        
          end
    end  
endgenerate
  
endmodule