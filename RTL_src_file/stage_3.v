////////////////////////////////////////////////////////////////////////////////////////
// Project Code      : S_1006
// Project Name      : Floating Point IP Core
// Module Name       : Stage-3 Pipeline Floating point Multiplication
// Author            : Sruthi
// Function          : control logic for shift type(left or right) & shift value
////////////////////////////////////////////////////////////////////////////////////////

module stage_3

#( parameter    DW       = 16,    
   parameter    EXP      = 4 ,    
   parameter    MANT     = 10,    
   parameter    CG_EN    = 0     
 )
 
(
  
        clk                   ,//system clock 
        en                    ,//Enable signal   
        flag_bit_reg          ,//flgbit register for mantissa shift 
        sign_reg2             ,//Sign bit register 
        l_shift_time_reg      ,//Leading Zero detection for Mantissa Booth multiplier output
        exp_out_reg           ,//Exponent register value
        exp_out_gt_max_reg    ,//To identify exponent value greater to 31 or not      
        add_less_bias_reg     ,//To identify exponent addition value Lesser to 15 or not      
        add_gt_bias_reg       ,//To identify exponent addition value greater to 15 or not 
        mat_out_bit_inv_reg   ,//To find shifting concept 
        mant_out_reg_2        ,//Mantissa Booth multiplier output 
        spe_case_a_reg2       ,//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
        spe_case_b_reg2       ,//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN  
        exp_eq_inf_reg2       ,//To identify exponent value equal to 15 or not   
                              
 
        sign_reg3             ,//Sign bit register
        mant_out_reg3         ,//Mantissa Booth multiplier output 
        exp_reg3              ,//Exponent register value
        over_flow_reg3        ,//Overflow output     
        spe_case_a_reg3       ,//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
        spe_case_b_reg3       ,//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN      
        mant_shift_type_reg3  ,//Shift type right or left shift
        mant_shift_value_reg3  //right or left shift value to shifting
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
   
    localparam L_SHIFT      = clog2(MANT_MUL1-1)              ;
    localparam SHIFT      = ( (DW==16)? 5 : (DW==32)? 6 : 7 ) ;


  //----------------------------------------------------//
  //---------------Input Ports--------------------------//       
  //----------------------------------------------------//
  input wire                          clk                 ;//system clock 
  input wire                          en                  ;//Enable signal   
  input wire                          flag_bit_reg        ;//flgbit register for mantissa shift 
  input wire                          sign_reg2           ;//Sign bit register 
  input wire   [L_SHIFT-1    :0]      l_shift_time_reg    ;//Leading Zero detection for Mantissa Booth multiplier output
  input wire   [EXP          :0]      exp_out_reg         ;//Exponent register value
  input wire                          exp_out_gt_max_reg  ;//To identify exponent value greater to 31 or not      
  input wire                          add_less_bias_reg   ;//To identify exponent addition value Lesser to 15 or not      
  input wire                          add_gt_bias_reg     ;//To identify exponent addition value greater to 15 or not 
  input wire                          mat_out_bit_inv_reg ;//To find shifting concept 
  input wire   [MANT_MUL-1   :0]      mant_out_reg_2      ;//Mantissa Booth multiplier output 
  input wire   [2            :0]      spe_case_a_reg2     ;//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
  input wire   [2            :0]      spe_case_b_reg2     ;//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN  
  input wire                          exp_eq_inf_reg2     ;//To identify exponent value equal to 15 or not   
  
  //-----------------------------------------------------//
  //------------------Output Ports-----------------------//       
  ///----------------------------------------------------//
  output reg                          sign_reg3             ;//Sign bit register
  output reg   [MANT_MUL-1   :0]      mant_out_reg3         ;//Mantissa Booth multiplier output 
  output reg   [EXP-1        :0]      exp_reg3              ;//Exponent register value
  output reg                          over_flow_reg3        ;//Overflow output     
  output reg   [2            :0]      spe_case_a_reg3       ;//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN
  output reg   [2            :0]      spe_case_b_reg3       ;//Special case identification for Nromalized,De-Normalized,Infinity,Zero or NAN      
  output reg   [1            :0]      mant_shift_type_reg3  ;//Shift type right or left shift
  output reg   [SHIFT-1      :0]      mant_shift_value_reg3 ;//right or left shift value to shifting
  
  //-----------------------------------------------------//
  //----------Internal Wires-----------------------------//
  //-----------------------------------------------------// 
  
  wire  [EXP-1      :0]    shift_time         ; 
  wire  [EXP-1      :0]    w_exp_reg1         ;
  wire                     under_flow_bit     ; 
  wire                     over_flow_bit      ;
  wire  [SHIFT      :0]    right_shift_time   ; 
  wire                     right_shift_time1  ;
  wire                     left_shift_time1   ;
  wire                     add_reg_less_bias  ;
  
  reg   [EXP-1      :0]    exp_out_1          ; 
  reg   [1          :0]    mant_shift_type    ;
  reg   [SHIFT      :0]    mant_shift_value   ;   
  
  //-----------------------------------------------------------------------------------
  //---------------Pipeline Stage-3 function ------------------------------------------
  //-----------------------------------------------------------------------------------
  
  assign w_exp_reg1         = exp_out_reg[EXP-1 :0];
                                                                                                   
  //overflow concept                                                                               
  assign over_flow_bit      = exp_out_gt_max_reg & mat_out_bit_inv_reg & exp_eq_inf_reg2;   
                                                                                                   
  //underflow concept                                                                              
  assign under_flow_bit     = flag_bit_reg & ((w_exp_reg1<={l_shift_time_reg})| add_less_bias_reg );
                                                                                                   
  //left shift time                                                                                
  assign shift_time         = (under_flow_bit)?w_exp_reg1:{l_shift_time_reg};
                                                                                                   
  assign right_shift_time   = (w_exp_reg1 <= MANT_MUL1 )?w_exp_reg1[EXP-1:0]: MANT_MUL1;
                                                                                                   
  assign add_reg_less_bias  = (~add_gt_bias_reg);
                            
  //right shift time        
  assign right_shift_time1  = flag_bit_reg & under_flow_bit & add_reg_less_bias;
                            
  assign left_shift_time1   = flag_bit_reg & under_flow_bit & add_gt_bias_reg;
 
  //Mantissa & exponent left shift & right shift control logic
  /*
  when mant_out_reg_2[21:20] == "00" & Exponent value less than bias value , Mantissa Booth multiplier output must be right shift
  when mant_out_reg_2[21:20] == "00" & Exponent value greater than bias value , Mantissa Booth multiplier output must be left shift shift
  when mant_out_reg_2[21:20] other factors , Mantissa Booth multiplier output must be right shift.
  */

  always @(*)
    begin
      case(mant_out_reg_2[MANT_MUL1:MANT_MUL1-1])
       2'd0:
            begin
            mant_shift_type  = (!flag_bit_reg )?2'b10:((right_shift_time1)?2'b00:2'b01);                             
            mant_shift_value = ((!flag_bit_reg)     ?  {SHIFT{1'd0}}                                   :
			                   ((right_shift_time1) ?  right_shift_time                                : 
                               ((left_shift_time1)  ?  shift_time[EXP-1:0]                             :
							                           (shift_time[EXP-1:0] + ({EXP{1'd0}} + 1'd1 ))))); 
            exp_out_1        = (flag_bit_reg)       ?  (w_exp_reg1-shift_time)                         :
			                                           w_exp_reg1                                      ;                                                  
            end
       2'd1:
            begin
            mant_shift_type  = (add_reg_less_bias)  ?2'b00:2'b01;            
            mant_shift_value = (add_reg_less_bias)  ? right_shift_time          :  
			                                          ({EXP{1'd0}} + 1'd1)      ;  
            exp_out_1        = (add_less_bias_reg)  ? {EXP{1'd0}}:w_exp_reg1    ;
            end
       default:
            begin
            mant_shift_type  = (add_reg_less_bias)?2'b00:2'b10;             
            mant_shift_value = (add_reg_less_bias)? right_shift_time              :  
			                                      {EXP{1'd0}}                     ; 
            exp_out_1        = (add_less_bias_reg)? {EXP{1'd0}}                   :
			                                      w_exp_reg1+({EXP{1'd0}}+1'd1)   ;            
            end  
      endcase
    end 
  
  //stage-3 output register
generate
  if(CG_EN)
    begin
      always @(posedge clk)     
        begin                 
          sign_reg3             <= sign_reg2              ;
          mant_out_reg3         <= mant_out_reg_2         ;
          exp_reg3              <= exp_out_1              ;
          over_flow_reg3        <= over_flow_bit          ;
          spe_case_a_reg3       <= spe_case_a_reg2        ;
          spe_case_b_reg3       <= spe_case_b_reg2        ; 
          mant_shift_type_reg3  <= mant_shift_type        ;
          mant_shift_value_reg3 <= mant_shift_value       ;
        end
    end
  else
    begin
      always @(posedge clk)   
        if(en)
          begin                 
            sign_reg3             <= sign_reg2              ;
            mant_out_reg3         <= mant_out_reg_2         ;
            exp_reg3              <= exp_out_1              ;
            over_flow_reg3        <= over_flow_bit          ;
            spe_case_a_reg3       <= spe_case_a_reg2        ;
            spe_case_b_reg3       <= spe_case_b_reg2        ; 
            mant_shift_type_reg3  <= mant_shift_type        ;
            mant_shift_value_reg3 <= mant_shift_value       ;
          end
    end
endgenerate
    
endmodule