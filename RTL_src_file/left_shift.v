////////////////////////////////////////////////////////////////////////////////////////
// Project Code      : S_1006
// Project Name      : Floating Point IP Core
// Module Name       : Left shift for 6bit
// Function          : left shift
////////////////////////////////////////////////////////////////////////////////////////  
module left_shift

#(
   parameter    MANT_MUL   = 22,
   parameter    DW   = 16
 )
(
   shift_time ,
   shift_in   ,
   
   shift_out 
);  

/////////////////////////////////////////////////////////////////////////
//-------------Local Parameters--------------------------------------////
/////////////////////////////////////////////////////////////////////////  
 localparam SHIFT  = ( (DW==16)? 5 : (DW==32)? 6 : 7 ) ;

 //-----------------------------------------------//
  //-------------Input Ports----------------------//       
  //----------------------------------------------//

  input  [SHIFT-1    :0]   shift_time ;
  input  [MANT_MUL-1 :0]   shift_in   ;
  
  //----------------------------------------------//
  //             Output Ports                     //       
  //----------------------------------------------//
 
  output reg [MANT_MUL-1:0]  shift_out ;
  
generate
 if(DW == 16)
  always@(*)
  begin
    case(shift_time)
	    5'd01:shift_out={shift_in[20:0], 1'd0 };
        5'd02:shift_out={shift_in[19:0], 2'd0 };
	    5'd03:shift_out={shift_in[18:0], 3'd0 };
	    5'd04:shift_out={shift_in[17:0], 4'd0 };
	    5'd05:shift_out={shift_in[16:0], 5'd0 };
	    5'd06:shift_out={shift_in[15:0], 6'd0 };
	    5'd07:shift_out={shift_in[14:0], 7'd0 };
	    5'd08:shift_out={shift_in[13:0], 8'd0 };
	    5'd09:shift_out={shift_in[12:0], 9'd0 };
	    5'd10:shift_out={shift_in[11:0],10'd0 };
	    5'd11:shift_out={shift_in[10:0],11'd0 };
	    5'd12:shift_out={shift_in[09:0],12'd0 };
	    5'd13:shift_out={shift_in[08:0],13'd0 };
	    5'd14:shift_out={shift_in[07:0],14'd0 };
	    5'd15:shift_out={shift_in[06:0],15'd0 };
	    5'd16:shift_out={shift_in[05:0],16'd0 };
	    5'd17:shift_out={shift_in[04:0],17'd0 };
	    5'd18:shift_out={shift_in[03:0],18'd0 };
	    5'd19:shift_out={shift_in[02:0],19'd0 };
	    5'd20:shift_out={shift_in[01:0],20'd0 };
	    5'd21:shift_out={shift_in[   0],21'd0 };
	      
	    default:shift_out=shift_in;
    endcase
  end
 else if(DW == 32)
  always@(*)
  begin
    case(shift_time)
	    6'd01:shift_out={shift_in[46:0], 1'd0 };
        6'd02:shift_out={shift_in[45:0], 2'd0 };
	    6'd03:shift_out={shift_in[44:0], 3'd0 };
	    6'd04:shift_out={shift_in[43:0], 4'd0 };
	    6'd05:shift_out={shift_in[42:0], 5'd0 };
	    6'd06:shift_out={shift_in[41:0], 6'd0 };
	    6'd07:shift_out={shift_in[40:0], 7'd0 };
	    6'd08:shift_out={shift_in[39:0], 8'd0 };
	    6'd09:shift_out={shift_in[38:0], 9'd0 };
	    6'd10:shift_out={shift_in[37:0],10'd0 };
	    6'd11:shift_out={shift_in[36:0],11'd0 };
	    6'd12:shift_out={shift_in[35:0],12'd0 };
	    6'd13:shift_out={shift_in[34:0],13'd0 };
	    6'd14:shift_out={shift_in[33:0],14'd0 };
	    6'd15:shift_out={shift_in[32:0],15'd0 };
	    6'd16:shift_out={shift_in[31:0],16'd0 };
	    6'd17:shift_out={shift_in[30:0],17'd0 };
	    6'd18:shift_out={shift_in[29:0],18'd0 };
	    6'd19:shift_out={shift_in[28:0],19'd0 };
	    6'd20:shift_out={shift_in[27:0],20'd0 };
	    6'd21:shift_out={shift_in[26:0],21'd0 };
	    6'd22:shift_out={shift_in[25:0],22'd0 };
	    6'd23:shift_out={shift_in[24:0],23'd0 };
	    6'd24:shift_out={shift_in[23:0],24'd0 };
	    6'd25:shift_out={shift_in[22:0],25'd0 };
        6'd26:shift_out={shift_in[21:0],26'd0 };
        6'd27:shift_out={shift_in[20:0],27'd0 };
        6'd28:shift_out={shift_in[19:0],28'd0 };
        6'd29:shift_out={shift_in[18:0],29'd0 };
        6'd30:shift_out={shift_in[17:0],30'd0 };
        6'd31:shift_out={shift_in[16:0],31'd0 };
        6'd32:shift_out={shift_in[15:0],32'd0 };  
        6'd33:shift_out={shift_in[14:0],33'd0 }; 
        6'd34:shift_out={shift_in[13:0],34'd0 };  
        6'd35:shift_out={shift_in[12:0],35'd0 };
        6'd36:shift_out={shift_in[11:0],36'd0 };
        6'd37:shift_out={shift_in[10:0],37'd0 };
        6'd38:shift_out={shift_in[09:0],38'd0 };
        6'd39:shift_out={shift_in[08:0],39'd0 };
        6'd40:shift_out={shift_in[07:0],40'd0 };
        6'd41:shift_out={shift_in[06:0],41'd0 };
        6'd42:shift_out={shift_in[05:0],42'd0 };
        6'd43:shift_out={shift_in[04:0],43'd0 };
        6'd44:shift_out={shift_in[03:0],44'd0 };
        6'd45:shift_out={shift_in[02:0],45'd0 }; 
        6'd46:shift_out={shift_in[01:0],46'd0 };
        6'd47:shift_out={shift_in[   0],47'd0 };       
	    default:shift_out=shift_in;
    endcase
  end  
  else
  always@(*)
  begin
    case(shift_time)
	    7'd01:shift_out ={shift_in[104:0],1'd0 };
        7'd02:shift_out ={shift_in[103:0],2'd0 };
	    7'd03:shift_out ={shift_in[102:0],3'd0 };
	    7'd04:shift_out ={shift_in[101:0],4'd0 };
	    7'd05:shift_out ={shift_in[100:0],5'd0 };
	    7'd06:shift_out ={shift_in[99:0],6'd0 };
	    7'd07:shift_out ={shift_in[98:0],7'd0 };
	    7'd08:shift_out ={shift_in[97:0],8'd0 };
	    7'd09:shift_out ={shift_in[96:0],9'd0 };
	    7'd10:shift_out ={shift_in[95:0],10'd0 };
	    7'd11:shift_out ={shift_in[94:0],11'd0 };
	    7'd12:shift_out ={shift_in[93:0],12'd0 };
	    7'd13:shift_out ={shift_in[92:0],13'd0 };
	    7'd14:shift_out ={shift_in[91:0],14'd0 };
	    7'd15:shift_out ={shift_in[90:0],15'd0 };
	    7'd16:shift_out ={shift_in[89:0],16'd0 };
	    7'd17:shift_out ={shift_in[88:0],17'd0 };
	    7'd18:shift_out ={shift_in[87:0],18'd0 };
	    7'd19:shift_out ={shift_in[86:0],19'd0 };
	    7'd20:shift_out ={shift_in[85:0],20'd0 };
	    7'd21:shift_out ={shift_in[84:0],21'd0 };
	    7'd22:shift_out ={shift_in[83:0],22'd0 };
	    7'd23:shift_out ={shift_in[82:0],23'd0 };
	    7'd24:shift_out ={shift_in[81:0],24'd0 };
	    7'd25:shift_out ={shift_in[80:0],25'd0 };
        7'd26:shift_out ={shift_in[79:0],26'd0 };
        7'd27:shift_out ={shift_in[78:0],27'd0 };
        7'd28:shift_out ={shift_in[77:0],28'd0 };
        7'd29:shift_out ={shift_in[76:0],29'd0 };
        7'd30:shift_out ={shift_in[75:0],30'd0 };
        7'd31:shift_out ={shift_in[74:0],31'd0 };
        7'd32:shift_out ={shift_in[73:0],32'd0 };  
        7'd33:shift_out ={shift_in[72:0],33'd0 }; 
        7'd34:shift_out ={shift_in[71:0],34'd0 };  
        7'd35:shift_out ={shift_in[70:0],35'd0 };
        7'd36:shift_out ={shift_in[69:0],36'd0 };
        7'd37:shift_out ={shift_in[68:0],37'd0 };
        7'd38:shift_out ={shift_in[67:0],38'd0 };
        7'd39:shift_out ={shift_in[66:0],39'd0 };
        7'd40:shift_out ={shift_in[65:0],40'd0 };
        7'd41:shift_out ={shift_in[64:0],41'd0 };
        7'd42:shift_out ={shift_in[63:0],42'd0 };
        7'd43:shift_out ={shift_in[62:0],43'd0 };
        7'd44:shift_out ={shift_in[61:0],44'd0 };
        7'd45:shift_out ={shift_in[60:0],45'd0 }; 
        7'd46:shift_out ={shift_in[59:0],46'd0 };
        7'd47:shift_out ={shift_in[58:0],47'd0 }; 		
        7'd48:shift_out ={shift_in[57:0],48'd0 }; 		
        7'd49:shift_out ={shift_in[56:0],49'd0 }; 		
        7'd50:shift_out ={shift_in[55:0],50'd0 }; 		
        7'd51:shift_out ={shift_in[54:0],51'd0 }; 		
        7'd52:shift_out ={shift_in[53:0],52'd0 }; 		
        7'd53:shift_out ={shift_in[52:0],53'd0 }; 		
        7'd54:shift_out ={shift_in[51:0],54'd0 }; 		
        7'd55:shift_out ={shift_in[50:0],55'd0 }; 		
        7'd56:shift_out ={shift_in[49:0],56'd0 }; 		
        7'd57:shift_out ={shift_in[48:0],57'd0 }; 		
        7'd58:shift_out ={shift_in[47:0],58'd0 }; 		
        7'd59:shift_out ={shift_in[46:0],59'd0 }; 		
        7'd60:shift_out ={shift_in[45:0],60'd0 }; 		
        7'd61:shift_out ={shift_in[44:0],61'd0 }; 		
        7'd62:shift_out ={shift_in[43:0],62'd0 }; 		
        7'd63:shift_out ={shift_in[42:0],63'd0 }; 		
        7'd64:shift_out ={shift_in[41:0],64'd0 }; 		
        7'd65:shift_out ={shift_in[40:0],65'd0 }; 		
        7'd66:shift_out ={shift_in[39:0],66'd0 }; 		
        7'd67:shift_out ={shift_in[38:0],67'd0 }; 		
        7'd68:shift_out ={shift_in[37:0],68'd0 }; 		
        7'd69:shift_out ={shift_in[36:0],69'd0 }; 		
        7'd70:shift_out ={shift_in[35:0],70'd0 }; 		
        7'd71:shift_out ={shift_in[34:0],71'd0 }; 		
        7'd72:shift_out ={shift_in[33:0],72'd0 }; 		
        7'd73:shift_out ={shift_in[32:0],73'd0 }; 		
        7'd74:shift_out ={shift_in[31:0],74'd0 }; 		
        7'd75:shift_out ={shift_in[30:0],75'd0 }; 		
        7'd76:shift_out ={shift_in[29:0],76'd0 }; 		
        7'd77:shift_out ={shift_in[28:0],77'd0 }; 		
        7'd78:shift_out ={shift_in[27:0],78'd0 }; 		
        7'd79:shift_out ={shift_in[26:0],79'd0 }; 		
        7'd80:shift_out ={shift_in[25:0],80'd0 }; 		
        7'd81:shift_out ={shift_in[24:0],81'd0 }; 		
        7'd82:shift_out ={shift_in[23:0],82'd0 }; 		
        7'd83:shift_out ={shift_in[22:0],83'd0 }; 		
        7'd84:shift_out ={shift_in[21:0],84'd0 }; 		
        7'd85:shift_out ={shift_in[20:0],85'd0 }; 		
        7'd86:shift_out ={shift_in[19:0],86'd0 }; 		
        7'd87:shift_out ={shift_in[18:0],87'd0 }; 		
        7'd88:shift_out ={shift_in[17:0],88'd0 }; 		
        7'd89:shift_out ={shift_in[16:0],89'd0 }; 		
        7'd90:shift_out ={shift_in[15:0],90'd0 }; 		
        7'd91:shift_out ={shift_in[14:0],91'd0 }; 		
        7'd92:shift_out ={shift_in[13:0],92'd0 }; 		
        7'd93:shift_out ={shift_in[12:0],93'd0 }; 		
        7'd94:shift_out ={shift_in[11:0],94'd0 }; 		
        7'd95:shift_out ={shift_in[10:0],95'd0 }; 		
        7'd96:shift_out ={shift_in[09:0],96'd0 }; 		
        7'd97:shift_out ={shift_in[08:0],97'd0 }; 		
        7'd98:shift_out ={shift_in[07:0],98'd0 }; 		
        7'd99:shift_out ={shift_in[06:0],99'd0 }; 		
        7'd100:shift_out={shift_in[05:0],100'd0 }; 		
        7'd101:shift_out={shift_in[04:0],101'd0 }; 		
        7'd102:shift_out={shift_in[03:0],102'd0 }; 		
        7'd103:shift_out={shift_in[02:0],103'd0 }; 		
        7'd104:shift_out={shift_in[01:0],104'd0 }; 		
        7'd105:shift_out={shift_in[   0],105'd0 }; 		
                                   
	    default:shift_out=shift_in;
    endcase                        
  end  
endgenerate  
                                   
endmodule                          
                                   
                                   