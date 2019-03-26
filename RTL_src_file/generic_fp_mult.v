////////////////////////////////////////////////////////////////////////////////////////
// Project Code      : S_1006
// Project Name      : Floating Point IP Core
// Module Name       : Floating point multiplication 
// Author            : Sruthi
// Function          : Multiply the two floating point operands
////////////////////////////////////////////////////////////////////////////////////////


module fp_multiplication

#(
   parameter    DW         = 32,
   parameter    EXP        = 8,
   parameter    MANT       = 23,
   parameter    IN_DELAY   = 0 ,
   parameter    DSP        = 0 ,
   parameter    CG_EN      = 1 ,
   parameter    ROUND_TYP  = 1   // ROUND_TYP  = 1 - round to nearest even
                                 // ROUND_TYP  = 2 - round toward zero
                                 // ROUND_TYP  = 3 - round toward + infinity 
                                 // ROUND_TYP  = 4 - round toward - infinity
 )
(
  //////////////////////////////////////////////////
  //              Input Ports                     //       
  //////////////////////////////////////////////////
  
  input wire                clk              , //System clock
  input wire                reset_n          , //As-synchronous Active low reset
  input wire                in_valid         , //Data in valid signal 
  input wire  [DW-1 :0]     opa_a            , //16-bit half precision floating point input-A
  input wire  [DW-1 :0]     opa_b            , //16-bit half precision floating point input-B
  input wire                en               , //clock gate enable signal 
  //////////////////////////////////////////////////
  //             Output Ports                     //       
  //////////////////////////////////////////////////
  output wire  [DW-1 :0]     out_result      , //Final 16-bit half precision floating point multiplication output
  output wire  [2    :0]     num_value       , //identification flag value for Nromalized,De-Normalized,Infinity,Zero or NAN
  output wire                over_flow       , //Overflow bit
  output wire                under_flow      , //underflow bit 
  output wire                out_valid         //Output data valid signal

);

/////////////////////////////////////////////////////////
//-----------------Local Parameters---------------------//
/////////////////////////////////////////////////////////
 localparam MANT_IMP       =  MANT+1             ;
 localparam MANT_MUL       =  MANT_IMP+MANT_IMP  ;
 localparam MANT_MUL1      =  MANT_MUL-1         ;
 
 //Function clog2
  function integer clog2;
    input integer MANT_MUL1;
      begin
        clog2 = 0;
        while (MANT_MUL1 > 0)
          begin
            MANT_MUL1    = MANT_MUL1 >> 1  ;
            clog2        = clog2 +1 ;
          end
       end
   endfunction
                   
 localparam L_SHIFT       = clog2(MANT_MUL1-1)                ;
 localparam SHIFT         = ( (DW==16)? 5 : (DW==32)? 6 : 7 ) ;
 
  ///////////////////////////////////////////////////
  // ------------ Registers------------------      //
  ///////////////////////////////////////////////////   
  
  reg                reg_in_valid    ;  
  reg  [DW-1 :0]     reg_opa_a       ;
  reg  [DW-1 :0]     reg_opa_b       ;
  reg  [6    :0]     temp_reg        ; 
  ///////////////////////////////////////////////////
  // ------------ wires----------------------------//
  ///////////////////////////////////////////////////    

  //-----------------------------------------
  //---------Stage-1 Registers---------------
  //-----------------------------------------   
  wire                         gclk                 ;  
  wire                         sign_reg             ;
  wire   [EXP-1      :0]       exp_opa_a_reg        ;
  wire   [EXP-1      :0]       exp_opa_b_reg        ;
  wire   [2          :0]       spe_case_a_reg       ;
  wire   [2          :0]       spe_case_b_reg       ;
  wire                         exp_eq_inf_reg       ;
  wire   [MANT       :0]       mant_opa_a_reg       ; 
  wire   [MANT       :0]       mant_opa_b_reg       ;  
                                                    
  wire   [MANT_MUL-1 :0]       mant_out_reg1        ;
  wire                         sign_reg1            ;
  wire   [EXP-1      :0]       exp_opa_a_reg1       ;
  wire   [EXP-1      :0]       exp_opa_b_reg1       ;
  wire   [2          :0]       spe_case_a_reg1      ;
  wire   [2          :0]       spe_case_b_reg1      ;
  wire                         exp_eq_inf_reg1      ;
                                                   
  //-----------------------------------------
  //---------Stage-2 Registers---------------
  //-----------------------------------------   
  wire                         flag_bit_reg         ;
  wire                         sign_reg2            ;  
  wire   [L_SHIFT-1  :0]       l_shift_time_reg     ;
  wire   [EXP        :0]       exp_out_reg          ; 
  wire                         exp_out_gt_max_reg   ;     
  wire                         add_less_bias_reg    ;
  wire                         add_gt_bias_reg      ; 
  wire                         mat_out_bit_inv_reg  ;   
  wire   [MANT_MUL-1 :0]       mant_out_reg_2       ;
  wire   [2          :0]       spe_case_a_reg2      ;
  wire   [2          :0]       spe_case_b_reg2      ;  
  wire                         exp_eq_inf_reg2      ;
                            
  //-----------------------------------------
  //---------Stage-3 Registers---------------
  //----------------------------------------- 
  wire                        sign_reg3              ;
  wire   [MANT_MUL-1 :0]      mant_out_reg3          ;
  wire   [EXP-1      :0]      exp_reg3               ; 
  wire                        over_flow_reg3         ;     
  wire   [2          :0]      spe_case_a_reg3        ;
  wire   [2          :0]      spe_case_b_reg3        ; 
  wire   [1          :0]      mant_shift_type_reg3   ;   
  wire   [SHIFT-1    :0]      mant_shift_value_reg3  ;
 
  
  //-----------------------------------------
  //---------Stage-4 Registers---------------
  //----------------------------------------- 
  wire                        sign_reg4              ;
  wire   [MANT       :0]      mant_out_reg4          ;
  wire   [EXP-1      :0]      exp_reg4               ; 
  wire                        over_flow_reg4         ;     
  wire   [2          :0]      spe_case_a_reg4        ;
  wire   [2          :0]      spe_case_b_reg4        ;   
  wire   [MANT       :0]      discard_bit_reg4       ; 
  wire                        over_flow1_reg4        ;
                                                    
  
////////////////////////////////////////////////////////////////////////////////
//-----------------Latch based Clock Gating ----------------------------------//
////////////////////////////////////////////////////////////////////////////////

generate
  if(CG_EN)
    begin	
      reg  clk_en; 
      always @ (*)
        begin
          if (!clk)
      	   begin
      	     clk_en = en;
      	   end
        end
		assign gclk = clk & clk_en;
    end
  else
    begin
	   assign gclk = clk;	
	  end
endgenerate
  
//-------------------------------------------------------------------------------
//----------Input register stage-------------------------------------------------
//------------------------------------------------------------------------------- 
generate
  if(IN_DELAY)
    begin
      if(CG_EN)
        begin        
          always @(posedge gclk or negedge reset_n)
            begin:STAGE_1
              if(!reset_n)
                begin
                  reg_in_valid         <= 1'b0           ;
                  reg_opa_a            <= {DW  {1'b0}}   ;
                  reg_opa_b            <= {DW  {1'b0}}   ;      
                end                   
              else                    
                begin                 
                  reg_in_valid         <= in_valid       ;
                  reg_opa_a            <= opa_a          ;
                  reg_opa_b            <= opa_b          ;       
                end
            end 
        end
      else
        begin
          always @(posedge gclk or negedge reset_n)
            begin:STAGE_1
              if(!reset_n)
                begin
                  reg_in_valid         <= 1'b0           ;
                  reg_opa_a            <= {DW  {1'b0}}   ;
                  reg_opa_b            <= {DW  {1'b0}}   ;      
                end                   
              else if(en)                   
                begin                 
                  reg_in_valid         <= in_valid       ;
                  reg_opa_a            <= opa_a          ;
                  reg_opa_b            <= opa_b          ;       
                end
            end   
        end      
    end
  else 
    begin
      always @(*)                   
        begin                 
          reg_in_valid         <= in_valid       ;
          reg_opa_a            <= opa_a          ;
          reg_opa_b            <= opa_b          ;       
        end 
    end    
endgenerate  

//-------------------------------------------------------------------------------
//----------output valid calculation---------------------------------------------
//------------------------------------------------------------------------------- 
generate
  if(CG_EN)
    begin    
      always @(posedge gclk or negedge reset_n)
        begin:STAGE
          if(!reset_n)
            begin
              temp_reg        <= 7'd0 ;     
            end                   
          else                    
            begin                 
             temp_reg       <=(DSP) ?{1'b0,reg_in_valid,temp_reg[5:1]}:{1'b0,reg_in_valid,temp_reg[5:1]};     
            end
        end
    end
  else
    begin    
      always @(posedge gclk or negedge reset_n)
        begin:STAGE
          if(!reset_n)
            begin
              temp_reg        <= 7'd0 ;     
            end                   
          else if(en)                   
            begin                    
              temp_reg       <=(DSP) ?{1'b0,reg_in_valid,temp_reg[5:1]}:{1'b0,reg_in_valid,temp_reg[5:1]};       
            end
        end
    end  
endgenerate
 
 assign out_valid=temp_reg[0];  
 

//-------------------------------------------------------------------------------
//----------STAGE-I Instantiation------------------------------------------------
//-------------------------------------------------------------------------------    
   
stage_1   
  
#(
   .DW     (DW     ),
   .EXP    (EXP    ),
   .MANT   (MANT   ),
   .CG_EN  (CG_EN  )
 )
 uut_stage_1
( 
  .clk              (gclk            ),
  .en               (en              ),
  .opa_a            (reg_opa_a       ),
  .opa_b            (reg_opa_b       ),
 
  .sign_reg         (sign_reg        ), 
  .exp_opa_a_reg    (exp_opa_a_reg   ),
  .exp_opa_b_reg    (exp_opa_b_reg   ),
  .spe_case_a_reg   (spe_case_a_reg  ),
  .spe_case_b_reg   (spe_case_b_reg  ),
  .exp_eq_inf_reg   (exp_eq_inf_reg  ),
  .mant_opa_a_reg   (mant_opa_a_reg  ), 
  .mant_opa_b_reg   (mant_opa_b_reg  )  
);

stage_1_1
#( .DW     (DW     ),
   .EXP    (EXP    ),
   .MANT   (MANT   ),
   .DSP    (DSP    ),
   .CG_EN  (CG_EN  )   
 )
uut_stage_1_1 
(
 .clk             (gclk          ),
 .en              (en            ), 
 .sign_reg        (sign_reg      ),
 .exp_opa_a_reg   (exp_opa_a_reg ), 
 .exp_opa_b_reg   (exp_opa_b_reg ),     
 .spe_case_a_reg  (spe_case_a_reg),
 .spe_case_b_reg  (spe_case_b_reg), 
 .exp_eq_inf_reg  (exp_eq_inf_reg),
 .mant_opa_a_reg  (mant_opa_a_reg), 
 .mant_opa_b_reg  (mant_opa_b_reg),

 .sign_reg1       (sign_reg1      ),
 .mant_out_reg1   (mant_out_reg1  ), 
 .exp_opa_a_reg1  (exp_opa_a_reg1 ),
 .exp_opa_b_reg1  (exp_opa_b_reg1 ),
 .spe_case_a_reg1 (spe_case_a_reg1),
 .spe_case_b_reg1 (spe_case_b_reg1),
 .exp_eq_inf_reg1 (exp_eq_inf_reg1)
 
  );

//-------------------------------------------------------------------------------
//----------STAGE-II Instantiation-----------------------------------------------
//-------------------------------------------------------------------------------

stage_2
#(  
   .DW     (DW     ),
   .EXP    (EXP    ),
   .MANT   (MANT   ),
   .CG_EN  (CG_EN  )   
 )
uut_stage_2
( 
  .clk                (gclk                ),
  .en                 (en                  ),  
  .sign_reg           (sign_reg1           ),
  .mant_out_reg       (mant_out_reg1       ),
  .exp_opa_a_reg      (exp_opa_a_reg1      ), 
  .exp_opa_b_reg      (exp_opa_b_reg1      ),     
  .spe_case_a_reg     (spe_case_a_reg1     ),
  .spe_case_b_reg     (spe_case_b_reg1     ), 
  .exp_eq_inf_reg     (exp_eq_inf_reg1     ),  

  .flag_bit_reg        (flag_bit_reg        ) ,
  .sign_reg2           (sign_reg2           ) ,  
  .l_shift_time_reg    (l_shift_time_reg    ) ,
  .exp_out_reg         (exp_out_reg         ) , 
  .exp_out_gt_max_reg  (exp_out_gt_max_reg  ) ,     
  .add_less_bias_reg   (add_less_bias_reg   ) ,
  .add_gt_bias_reg     (add_gt_bias_reg     ) , 
  .mat_out_bit_inv_reg (mat_out_bit_inv_reg ) ,   
  .mant_out_reg_2      (mant_out_reg_2      ) ,
  .spe_case_a_reg2     (spe_case_a_reg2     ) ,
  .spe_case_b_reg2     (spe_case_b_reg2     ) ,  
  .exp_eq_inf_reg2     (exp_eq_inf_reg2     )
);

//-------------------------------------------------------------------------------
//----------STAGE-III Instantiation----------------------------------------------
//-------------------------------------------------------------------------------

stage_3
#( .DW     (DW     ),
   .EXP    (EXP    ),
   .MANT   (MANT   ),
   .CG_EN  (CG_EN  )   
 )
uut_stage_3
(
  .clk                   (gclk                  ),
  .en                    (en                    ),  
  .flag_bit_reg          (flag_bit_reg          ),
  .sign_reg2             (sign_reg2             ),
  .l_shift_time_reg      (l_shift_time_reg      ),
  .exp_out_reg           (exp_out_reg           ),
  .exp_out_gt_max_reg    (exp_out_gt_max_reg    ), 
  .add_less_bias_reg     (add_less_bias_reg     ),     
  .add_gt_bias_reg       (add_gt_bias_reg       ),
  .mat_out_bit_inv_reg   (mat_out_bit_inv_reg   ),
  .mant_out_reg_2        (mant_out_reg_2        ), 
  .spe_case_a_reg2       (spe_case_a_reg2       ),
  .spe_case_b_reg2       (spe_case_b_reg2       ),
  .exp_eq_inf_reg2       (exp_eq_inf_reg2       ), 
  
  .sign_reg3             (sign_reg3             ),
  .mant_out_reg3         (mant_out_reg3         ),
  .exp_reg3              (exp_reg3              ), 
  .over_flow_reg3        (over_flow_reg3        ),     
  .spe_case_a_reg3       (spe_case_a_reg3       ),
  .spe_case_b_reg3       (spe_case_b_reg3       ), 
  .mant_shift_type_reg3  (mant_shift_type_reg3  ),   
  .mant_shift_value_reg3 (mant_shift_value_reg3 )
);
 
//-------------------------------------------------------------------------------
//----------STAGE-IV Instantiation----------------------------------------------
//-------------------------------------------------------------------------------

stage_4
#( .DW     (DW     ),
   .EXP    (EXP    ),
   .MANT   (MANT   ),
   .CG_EN  (CG_EN  )   
 )
uut_stage_4
(
  .clk                   (gclk                  ),  
  .en                    (en                    ),  
  .sign_reg3             (sign_reg3             ),
  .mant_out_reg3         (mant_out_reg3         ),
  .exp_reg3              (exp_reg3              ), 
  .over_flow_reg3        (over_flow_reg3        ),     
  .spe_case_a_reg3       (spe_case_a_reg3       ),
  .spe_case_b_reg3       (spe_case_b_reg3       ), 
  .mant_shift_type_reg3  (mant_shift_type_reg3  ),   
  .mant_shift_value_reg3 (mant_shift_value_reg3 ),

  .sign_reg4             (sign_reg4             ),
  .mant_out_reg4         (mant_out_reg4         ),
  .exp_reg4              (exp_reg4              ), 
  .over_flow_reg4        (over_flow_reg4        ),
  .over_flow1_reg4       (over_flow1_reg4       ),  
  .spe_case_a_reg4       (spe_case_a_reg4       ),
  .spe_case_b_reg4       (spe_case_b_reg4       ),   
  .discard_bit_reg4      (discard_bit_reg4      )
); 
 
//-------------------------------------------------------------------------------
//----------STAGE-V Instantiation----------------------------------------------
//-------------------------------------------------------------------------------

stage_5
#( .DW         (DW         ),
   .EXP        (EXP        ),
   .MANT       (MANT       ),
   .CG_EN      (CG_EN      ),   
   .ROUND_TYP  (ROUND_TYP  )
   )
uut_stage_5
(
  .clk                   (gclk                ), 
  .en                    (en                  ),  
  .sign_reg4             (sign_reg4           ),
  .mant_out_reg4         (mant_out_reg4       ),
  .exp_reg4              (exp_reg4            ),
  .over_flow_reg4        (over_flow_reg4      ),
  .over_flow1_reg4       (over_flow1_reg4     ),  
  .spe_case_a_reg4       (spe_case_a_reg4     ),
  .spe_case_b_reg4       (spe_case_b_reg4     ),    
  .discard_bit_reg4      (discard_bit_reg4    ),
 
  .out_result            (out_result           ), 
  .num_value             (num_value            ),
  .over_flow             (over_flow            ),
  .under_flow            (under_flow           )
);


`ifdef DFV 

localparam LATENCY = 6+IN_DELAY; 

//sequenceto check whether the flag bits are less than 5
sequence chk_flg(logic [2:0] flag);
  (flag<5);
endsequence

//Sequence to check whether the exponent bits are 255 and mantissa bits are zero
sequence chk_inf(logic [DW-1:0] in);
  ( (&(in[DW-2:MANT])) & ~(|(in[MANT-1:0])) );
endsequence

//Sequence to check whether the exponent bits are 255 and mantissa bits are non zero
sequence chk_nan(logic [DW-1:0] in);
  ( (&(in[DW-2:MANT])) & (|(in[MANT-1:0])) );
endsequence

//Sequence to check whether the exponent bits are zero and mantissa bits are zero
sequence chk_zero(logic [DW-1:0] in);
  ( ~(|(in[DW-2:MANT])) & ~(|(in[MANT-1:0])) );
endsequence

//Sequence to check whether the exponent bits are zero and mantissa bits are non zero
sequence chk_denorm(logic [DW-1:0] in);
  ( ~(|(in[DW-2:MANT])) & (|(in[MANT-1:0])) );
endsequence

//Sequence to check whether the exponent bits are non zero and mantissa bits are from 0 to 8388607
sequence chk_norm(logic [DW-1:0] in);
  ((|(in[DW-2:MANT])) &  ~(&(in[DW-2:MANT])));
endsequence


//This property checks the flag bit range 
property p_flg_rang_chk(logic [2:0] flag,logic out_vld,integer cycle);
  @(posedge clk) disable iff (!reset_n) 
  (out_vld) |-> ##cycle  (flag==0 or flag==1 or flag==2 or flag==3 or flag==4 );
endproperty


//This property checks whether the output is normalized when the flag bit is zero
property p_norm_chk(logic [2:0] flag,logic [DW-1:0] in,logic out_vld,integer cycle);
  @(posedge clk) disable iff (!reset_n) 
  (out_vld&(flag==0)) |-> ##cycle  chk_norm(in)   ;
endproperty


//This property checks whether the output is denormalized when the flag bit is one
property p_denorm_chk(logic [2:0] flag,logic [DW-1:0] in,logic out_vld,integer cycle);
  @(posedge clk) disable iff (!reset_n) 
  (out_vld&(flag==1)) |-> ##cycle  chk_denorm(in) ;
endproperty


//This property checks whether the output is zero when the flag bit is two
property p_zero_chk(logic [2:0] flag,logic [DW-1:0] in,logic out_vld,integer cycle);
  @(posedge clk) disable iff (!reset_n) 
  (out_vld&(flag==2)) |-> ##cycle  chk_zero(in)   ;
endproperty


//This property checks whether the output is infinity when the flag bit is three
property p_inf_chk(logic [2:0] flag,logic [DW-1:0] in,logic out_vld,integer cycle);
  @(posedge clk) disable iff (!reset_n) 
  (out_vld&(flag==3)) |-> ##cycle  chk_inf(in)    ;
endproperty


//This property checks whether the output is NaN when the flag bit is four
property p_nan_chk(logic [2:0] flag,logic [DW-1:0] in,logic out_vld,integer cycle);
  @(posedge clk) disable iff (!reset_n) 
  (out_vld&(flag==4)) |-> ##cycle  chk_nan(in)    ;
endproperty


//This property checks whether the output is normalized or over_flow or under_flow or denormalized when the flag bit is zero
property p_norm_out_spl_chk(logic [2:0] flag,logic [DW-1:0] in,logic out_vld,logic of,logic uf,integer cycle);
  @(posedge clk) disable iff (!reset_n) 
  (out_vld&(flag==0)) |-> ##cycle  (chk_norm(in) or of or uf or chk_denorm(in) )  ;
endproperty

//This property checks over_flow and underflow flags are mutually exclusive
property p_mutex_chk(logic valid,logic in1,logic in2);
  @(posedge clk) disable iff (!reset_n) 
  (valid) |-> !(in1 & in2) ;
endproperty

//This property checks whether the output is infinity for overflow
property p_overflow_chk(logic valid,logic overflow,logic [2:0] flag);
  @(posedge clk) disable iff (!reset_n) 
  (valid & overflow) |-> (flag==3) ;
endproperty

//This property checks whether the output is zero for underflow
property p_underflow_chk(logic valid,logic underflow,logic [2:0] flag);
  @(posedge clk) disable iff (!reset_n) 
  (valid & underflow) |-> (flag==2) ;
endproperty

function [2:0] flag_compute(input logic [DW-1:0] fp_val);
  flag_compute  =((fp_val[DW-2:MANT] == {EXP{1'd0}}) && (fp_val[MANT-1:0]!={MANT{1'd0}}))  ?3'd1: 
                 ((fp_val[DW-2:MANT] == {EXP{1'd0}}) && (fp_val[MANT-1:0]=={MANT{1'd0}}))  ?3'd2: 
                 ((fp_val[DW-2:MANT] == {EXP{1'd1}}) && (fp_val[MANT-1:0]=={MANT{1'd0}}))  ?3'd3: 
                 ((fp_val[DW-2:MANT] == {EXP{1'd1}}) && (fp_val[MANT-1:0]!={MANT{1'd0}}))  ?3'd4: 3'd0;
endfunction


function [2:0] flag_out(input logic [2:0] flag_in1,input logic [2:0] flag_in2);
	
	case({flag_in1,flag_in2})
	  {3'd1,3'd1}:flag_out=3'd2;
	  {3'd1,3'd4}:flag_out=3'd4;
	  {3'd0,3'd3}:flag_out=3'd3;
	  {3'd3,3'd0}:flag_out=3'd3;
	  {3'd3,3'd3}:flag_out=3'd3;
	  {3'd3,3'd1}:flag_out=3'd3;
	  {3'd1,3'd3}:flag_out=3'd3;
	  {3'd4,3'd0}:flag_out=3'd4;
	  {3'd4,3'd1}:flag_out=3'd4;
	  {3'd4,3'd2}:flag_out=3'd4;
	  {3'd4,3'd3}:flag_out=3'd4;
	  {3'd4,3'd4}:flag_out=3'd4;
	  {3'd0,3'd4}:flag_out=3'd4;
	  {3'd2,3'd4}:flag_out=3'd4;
	  {3'd3,3'd4}:flag_out=3'd4;
	  {3'd2,3'd0}:flag_out=3'd2;
	  {3'd2,3'd1}:flag_out=3'd2;
	  {3'd2,3'd3}:flag_out=3'd4;
	  {3'd0,3'd2}:flag_out=3'd2;
	  {3'd1,3'd2}:flag_out=3'd2;
	  {3'd3,3'd2}:flag_out=3'd4;
	  {3'd2,3'd2}:flag_out=3'd2;
	  default    :flag_out=3'd0;
	endcase
	
endfunction



ap_out_flag_chk  : assert property (p_flg_rang_chk   (num_value,out_valid,0)) else 
                   $error("Out flag mismatch   :\t%0d",$past(num_value,0));
ap_op_a_flag_chk : assert property (p_flg_rang_chk   (spe_case_a_reg,out_valid,0)) else 
                   $error("Op_a flag mismatch   :\t%0d",$past(spe_case_a_reg,0));
ap_op_b_flag_chk : assert property (p_flg_rang_chk   (spe_case_b_reg,out_valid,0)) else 
                   $error("Op_b flag mismatch :\t%0d",$past(spe_case_b_reg,0));
					
ap_norm_chk      : assert property (p_norm_chk  (num_value,out_result,out_valid,0)) else 
                   $error("Normalize mismatch  :\t%0d-->%32b---OF:%0d---UF:%0d",$past(num_value,0),$past(out_result,0),$past(over_flow,0),$past(under_flow,0));
ap_denorm_chk    : assert property (p_denorm_chk(num_value,out_result,out_valid,0)) else 
                   $error("Denormalize mismatch:\t%0d-->%32b---OF:%0d---UF:%0d",$past(num_value,0),$past(out_result,0),$past(over_flow,0),$past(under_flow,0));
ap_zero_chk      : assert property (p_zero_chk  (num_value,out_result,out_valid,0)) else 
                   $error("Zero mismatch       :\t%0d-->%32b---OF:%0d---UF:%0d",$past(num_value,0),$past(out_result,0),$past(over_flow,0),$past(under_flow,0));
ap_inf_chk       : assert property (p_inf_chk   (num_value,out_result,out_valid,0)) else 
                   $error("Infinity mismatch   :\t%0d-->%32b---OF:%0d---UF:%0d",$past(num_value,0),$past(out_result,0),$past(over_flow,0),$past(under_flow,0));
ap_nan_chk       : assert property (p_nan_chk   (num_value,out_result,out_valid,0)) else 
                   $error("NaN mismatch        :\t%0d-->%32b---OF:%0d---UF:%0d",$past(num_value,0),$past(out_result,0),$past(over_flow,0),$past(under_flow,0));
					
ap_mutex_chk     : assert property (p_mutex_chk (out_valid,over_flow,under_flow)) else 
                   $error("Mutex Mismatch      :\tFlag:%0d --> %32b---%8h %8h",$past(num_value,0),$past(out_result,0),$past(opa_a,LATENCY),$past(opa_b,LATENCY));
ap_overflow_chk  : assert property (p_overflow_chk (out_valid,over_flow,num_value)) else 
                   $error("Overflow Error      :\tFlag:%0d --> %32b---%8h %8h",$past(num_value,0),$past(out_result,0),$past(opa_a,LATENCY),$past(opa_b,LATENCY));
ap_underflow_chk : assert property (p_underflow_chk (out_valid,under_flow,num_value)) else 
                   $error("Underflow Error     :\tFlag:%0d --> %32b---%8h %8h",$past(num_value,0),$past(out_result,0),$past(opa_a,LATENCY),$past(opa_b,LATENCY));
					
ap_norm_chk_out  : assert property (p_norm_out_spl_chk (flag_out(flag_compute(opa_a),flag_compute(opa_b)),out_result,out_valid,over_flow,under_flow,LATENCY)) else 
                   $error("Normalize Out mismatch  :\t%0d --> %32b---OF:%0d---UF:%0d---%8h %8h",$past(num_value,0),$past(out_result,0),$past(over_flow,0),$past(under_flow,0),$past(opa_a,LATENCY),$past(opa_b,LATENCY));
ap_denorm_chk_out: assert property (p_denorm_chk(flag_out(flag_compute(opa_a),flag_compute(opa_b)),out_result,out_valid,LATENCY)) else
                   $error("Denormalize Out mismatch:\t%0d --> %32b---OF:%0d---UF:%0d---%8h %8h",$past(num_value,0),$past(out_result,0),$past(over_flow,0),$past(under_flow,0),$past(opa_a,LATENCY),$past(opa_b,LATENCY));
ap_zero_chk_out  : assert property (p_zero_chk  (flag_out(flag_compute(opa_a),flag_compute(opa_b)),out_result,out_valid,LATENCY)) else
                   $error("Zero Out mismatch       :\t%0d --> %32b---OF:%0d---UF:%0d---%8h %8h",$past(num_value,0),$past(out_result,0),$past(over_flow,0),$past(under_flow,0),$past(opa_a,LATENCY),$past(opa_b,LATENCY));
ap_inf_chk_out   : assert property (p_inf_chk   (flag_out(flag_compute(opa_a),flag_compute(opa_b)),out_result,out_valid,LATENCY)) else
                   $error("Infinity Out mismatch   :\t%0d --> %32b---OF:%0d---UF:%0d---%8h %8h",$past(num_value,0),$past(out_result,0),$past(over_flow,0),$past(under_flow,0),$past(opa_a,LATENCY),$past(opa_b,LATENCY));
ap_nan_chk_out   : assert property (p_nan_chk   (flag_out(flag_compute(opa_a),flag_compute(opa_b)),out_result,out_valid,LATENCY)) else
                   $error("NaN Out mismatch        :\t%0d --> %32b---OF:%0d---UF:%0d---%8h %8h",$past(num_value,0),$past(out_result,0),$past(over_flow,0),$past(under_flow,0),$past(opa_a,LATENCY),$past(opa_b,LATENCY));
				   
`endif


endmodule