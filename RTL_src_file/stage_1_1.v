///////////////////////////////////////////////////////////////////////////////////////////////
// Project Code      : S_1006
// Project Name      : Floating Point IP Core
// Module Name       : Stage-I.I Pipeline Floating point Multiplication
// Author            : Sruthi
// Function          : Multiply the two input Mantissa value by using Booth Multiplier
//////////////////////////////////////////////////////////////////////////////////////////////

module stage_1_1
#(
   parameter    DW       = 16,
   parameter    EXP      = 5 ,
   parameter    MANT     = 10,
   parameter    DSP      = 0 ,
   parameter    CG_EN    = 0     
 )
 
(
    clk              ,//system Clock
    en               ,//Enable signal  
    sign_reg         ,//Sign bit
    exp_opa_a_reg    ,//Mantissa bit of input-A
    exp_opa_b_reg    ,//Mantissa bit of input-B    
    spe_case_a_reg   ,//Exponent bit of input-A
    spe_case_b_reg   ,//Exponent bit of input-B
    exp_eq_inf_reg   ,//To identify exponent value equal to 255 or not
    mant_opa_a_reg   ,//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
    mant_opa_b_reg   ,//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN 
    
    mant_out_reg1    ,//Mantissa Booth multiplier output
    sign_reg1        ,//Sign bit register
    exp_opa_a_reg1   ,//Exponent bit of input-A
    exp_opa_b_reg1   ,//Exponent bit of input-B
    spe_case_a_reg1  ,//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
    spe_case_b_reg1  ,//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
    exp_eq_inf_reg1    //To identify exponent value equal to 255 or not
  
  );
  
/////////////////////////////////////////////////////////////////////////
//-------------Local Parameters--------------------------------------////
/////////////////////////////////////////////////////////////////////////  
  localparam MANT_IMP = MANT+1             ;
  localparam MANT_MUL = MANT_IMP+MANT_IMP  ;
 
 
 /////////////////////////////////////////////////////////////////////////////
 //----------------Input ports-------------------------------------------/////
 /////////////////////////////////////////////////////////////////////////////
                                    
  input wire                        clk                 ;//system Clock
  input wire                        en                  ;//Enable signal  
  input wire                        sign_reg            ;//Sign bit
  input wire   [EXP-1      :0]      exp_opa_a_reg       ;//Mantissa bit of input-A
  input wire   [EXP-1      :0]      exp_opa_b_reg       ;//Mantissa bit of input-B    
  input wire   [2          :0]      spe_case_a_reg      ;//Exponent bit of input-A
  input wire   [2          :0]      spe_case_b_reg      ;//Exponent bit of input-B
  input wire                        exp_eq_inf_reg      ;//To identify exponent value equal to 255 or not
  input wire   [MANT       :0]      mant_opa_a_reg      ;//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
  input wire   [MANT       :0]      mant_opa_b_reg      ;//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN 
                                                 
  
  /////////////////////////////////////////////////////////////////////////////////
  ///------------------Output ports---------------------------------------////////
  ////////////////////////////////////////////////////////////////////////////////
  
  output reg   [MANT_MUL-1 :0]      mant_out_reg1       ;//Mantissa Booth multiplier output
  output reg                        sign_reg1           ;//Sign bit register
  output reg   [EXP-1      :0]      exp_opa_a_reg1      ;//Exponent bit of input-A
  output reg   [EXP-1      :0]      exp_opa_b_reg1      ;//Exponent bit of input-B
  output reg   [2          :0]      spe_case_a_reg1     ;//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
  output reg   [2          :0]      spe_case_b_reg1     ;//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
  output reg                        exp_eq_inf_reg1     ;//To identify exponent value equal to 255 or not
  
  
  
  ///////////////////////////////////////////////////
  //       Stage-1 Registers                       //
  ///////////////////////////////////////////////////    
  wire   [MANT_MUL-1  :0]  mant_out              ;

  
 /* reg                      sign_reg0             ;
  reg    [EXP-1       :0]  exp_opa_a_reg0        ;
  reg    [EXP-1       :0]  exp_opa_b_reg0        ;
  reg    [2           :0]  spe_case_a_reg0       ;
  reg    [2           :0]  spe_case_b_reg0       ;
  reg                      exp_eq_inf_reg0       ; */
  

  //Mantissa bit calculation by using booth multiplier
  generate  
    if(DSP)
      begin
        assign mant_out     = mant_opa_a_reg * mant_opa_b_reg ;
      end 
    else
      begin
        booth_mult
        #(
          .A_SIGNED (0 )      ,
          .B_SIGNED (0 )      ,    
          .A_DW     (MANT_IMP),  
          .B_DW     (MANT_IMP),
          .PP_REG   (0 )      ,
          .ADD_REG  (0 )         
        )
        uut_booth_mult_11x11
        (
          .clk     (clk           ),
          .mult_in1(mant_opa_a_reg),
          .mult_in2(mant_opa_b_reg),
          .mult_out(mant_out      )       
        );          
      end
  endgenerate 
  
  generate 
    if(CG_EN)  
      begin
        if(DSP)
          begin  
            //stage-1 output register
            always @(posedge clk)                   
                begin 
                  mant_out_reg1     <= mant_out            ;            
                  sign_reg1         <= sign_reg            ;
                  exp_opa_a_reg1    <= exp_opa_a_reg       ;
                  exp_opa_b_reg1    <= exp_opa_b_reg       ; 
                  spe_case_a_reg1   <= spe_case_a_reg      ;   
                  spe_case_b_reg1   <= spe_case_b_reg      ;
                  exp_eq_inf_reg1   <= exp_eq_inf_reg      ;
                end    
          end
        else
          begin  
            //stage-1 output register(to equalent delay for booth multiplier register delay )
            always @(posedge clk)                          
                begin 
                  mant_out_reg1     <= mant_out         ; 
                  sign_reg1         <= sign_reg         ;
                  exp_opa_a_reg1    <= exp_opa_a_reg    ;
                  exp_opa_b_reg1    <= exp_opa_b_reg    ; 
                  spe_case_a_reg1   <= spe_case_a_reg   ;   
                  spe_case_b_reg1   <= spe_case_b_reg   ;
                  exp_eq_inf_reg1   <= exp_eq_inf_reg   ;
                end  
          end       
      end
    else 
      begin
        if(DSP)
          begin  
            //stage-1 output register
            always @(posedge clk) 
              if(en)
                begin 
                  mant_out_reg1     <= mant_out            ;            
                  sign_reg1         <= sign_reg            ;
                  exp_opa_a_reg1    <= exp_opa_a_reg       ;
                  exp_opa_b_reg1    <= exp_opa_b_reg       ; 
                  spe_case_a_reg1   <= spe_case_a_reg      ;   
                  spe_case_b_reg1   <= spe_case_b_reg      ;
                  exp_eq_inf_reg1   <= exp_eq_inf_reg      ;
                end    
          end
        else
          begin  
            //stage-1 output register(to equalent delay for booth multiplier register delay )
            always @(posedge clk)  
              if(en)            
             begin 
                  mant_out_reg1     <= mant_out           ; 
                  sign_reg1         <= sign_reg           ;
                  exp_opa_a_reg1    <= exp_opa_a_reg      ;
                  exp_opa_b_reg1    <= exp_opa_b_reg      ; 
                  spe_case_a_reg1   <= spe_case_a_reg     ;   
                  spe_case_b_reg1   <= spe_case_b_reg     ;
                  exp_eq_inf_reg1   <= exp_eq_inf_reg     ;
                end  
          end       
      end
    
  endgenerate 
  
endmodule

