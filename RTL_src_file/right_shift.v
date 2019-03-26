////////////////////////////////////////////////////////////////////////////////////////
// Project Code      : S_1006
// Project Name      : Floating Point IP Core
// Module Name       : Left shift for 6bit
// Function          : left shift
////////////////////////////////////////////////////////////////////////////////////////  
module right_shift

#(
   parameter    MANT_MUL   = 48,
   parameter    DW   = 32
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

  //////////////////////////////////////////////////
  //              Input Ports                     //       
  //////////////////////////////////////////////////

  input  [SHIFT-1  :0] shift_time ;
  input  [MANT_MUL-1     :0] shift_in   ;
  
  //////////////////////////////////////////////////
  //             Output Ports                     //       
  //////////////////////////////////////////////////
 
  output reg [MANT_MUL-1:0]  shift_out  ;

generate
 if (DW == 16)
   always@(*)
   begin
     case(shift_time)
 	    5'd01:shift_out={ 1'd0,shift_in[21:01]};
        5'd02:shift_out={ 2'd0,shift_in[21:02]};
 	    5'd03:shift_out={ 3'd0,shift_in[21:03]};
 	    5'd04:shift_out={ 4'd0,shift_in[21:04]};
 	    5'd05:shift_out={ 5'd0,shift_in[21:05]};
 	    5'd06:shift_out={ 6'd0,shift_in[21:06]};
 	    5'd07:shift_out={ 7'd0,shift_in[21:07]};
 	    5'd08:shift_out={ 8'd0,shift_in[21:08]};
 	    5'd09:shift_out={ 9'd0,shift_in[21:09]};
 	    5'd10:shift_out={10'd0,shift_in[21:10]};
 	    5'd11:shift_out={11'd0,shift_in[21:11]};
 	    5'd12:shift_out={12'd0,shift_in[21:12]};
 	    5'd13:shift_out={13'd0,shift_in[21:13]};
 	    5'd14:shift_out={14'd0,shift_in[21:14]};
 	    5'd15:shift_out={15'd0,shift_in[21:15]};
 	    5'd16:shift_out={16'd0,shift_in[21:16]};
 	    5'd17:shift_out={17'd0,shift_in[21:17]};
 	    5'd18:shift_out={18'd0,shift_in[21:18]};
 	    5'd19:shift_out={19'd0,shift_in[21:19]};
 	    5'd20:shift_out={20'd0,shift_in[21:20]};
 	    5'd21:shift_out={21'd0,shift_in[21   ]};
 	  
 	    default:shift_out=shift_in;
     endcase
   end
 else if (DW == 32)   
  always@(*)
  begin
   case(shift_time)
	    6'd01:shift_out={ 1'd0,shift_in[47:01]};
        6'd02:shift_out={ 2'd0,shift_in[47:02]};
	    6'd03:shift_out={ 3'd0,shift_in[47:03]};
	    6'd04:shift_out={ 4'd0,shift_in[47:04]};
	    6'd05:shift_out={ 5'd0,shift_in[47:05]};
	    6'd06:shift_out={ 6'd0,shift_in[47:06]};
	    6'd07:shift_out={ 7'd0,shift_in[47:07]};
	    6'd08:shift_out={ 8'd0,shift_in[47:08]};
	    6'd09:shift_out={ 9'd0,shift_in[47:09]};
	    6'd10:shift_out={10'd0,shift_in[47:10]};
	    6'd11:shift_out={11'd0,shift_in[47:11]};
	    6'd12:shift_out={12'd0,shift_in[47:12]};
	    6'd13:shift_out={13'd0,shift_in[47:13]};
	    6'd14:shift_out={14'd0,shift_in[47:14]};
	    6'd15:shift_out={15'd0,shift_in[47:15]};
	    6'd16:shift_out={16'd0,shift_in[47:16]};
	    6'd17:shift_out={17'd0,shift_in[47:17]};
	    6'd18:shift_out={18'd0,shift_in[47:18]};
	    6'd19:shift_out={19'd0,shift_in[47:19]};
	    6'd20:shift_out={20'd0,shift_in[47:20]};
	    6'd21:shift_out={21'd0,shift_in[47:21]};
	    6'd22:shift_out={22'd0,shift_in[47:22]};
	    6'd23:shift_out={23'd0,shift_in[47:23]};
	    6'd24:shift_out={24'd0,shift_in[47:24]};
	    6'd25:shift_out={25'd0,shift_in[47:25]};
        6'd26:shift_out={26'd0,shift_in[47:26]};
        6'd27:shift_out={27'd0,shift_in[47:27]};
        6'd28:shift_out={28'd0,shift_in[47:28]};
        6'd29:shift_out={29'd0,shift_in[47:29]};
        6'd30:shift_out={30'd0,shift_in[47:30]};
        6'd31:shift_out={31'd0,shift_in[47:31]};
        6'd32:shift_out={32'd0,shift_in[47:32]};  
        6'd33:shift_out={33'd0,shift_in[47:33]}; 
        6'd34:shift_out={34'd0,shift_in[47:34]};  
        6'd35:shift_out={35'd0,shift_in[47:35]};
        6'd36:shift_out={36'd0,shift_in[47:36]};
        6'd37:shift_out={37'd0,shift_in[47:37]};
        6'd38:shift_out={38'd0,shift_in[47:38]};
        6'd39:shift_out={39'd0,shift_in[47:39]};
        6'd40:shift_out={40'd0,shift_in[47:40]};
        6'd41:shift_out={41'd0,shift_in[47:41]};
        6'd42:shift_out={42'd0,shift_in[47:42]};
        6'd43:shift_out={43'd0,shift_in[47:43]};
        6'd44:shift_out={44'd0,shift_in[47:44]};
        6'd45:shift_out={45'd0,shift_in[47:45]}; 
        6'd46:shift_out={46'd0,shift_in[47:46]}; 
        6'd47:shift_out={47'd0,shift_in[47   ]};      
	    default:shift_out=shift_in;
   endcase
  end
 else
  always@(*)
  begin
   case(shift_time)
	    7'd01:shift_out ={ 1'd0,shift_in[105:01]};
        7'd02:shift_out ={ 2'd0,shift_in[105:02]};
	    7'd03:shift_out ={ 3'd0,shift_in[105:03]};
	    7'd04:shift_out ={ 4'd0,shift_in[105:04]};
	    7'd05:shift_out ={ 5'd0,shift_in[105:05]};
	    7'd06:shift_out ={ 6'd0,shift_in[105:06]};
	    7'd07:shift_out ={ 7'd0,shift_in[105:07]};
	    7'd08:shift_out ={ 8'd0,shift_in[105:08]};
	    7'd09:shift_out ={ 9'd0,shift_in[105:09]};
	    7'd10:shift_out ={10'd0,shift_in[105:10]};
	    7'd11:shift_out ={11'd0,shift_in[105:11]};
	    7'd12:shift_out ={12'd0,shift_in[105:12]};
	    7'd13:shift_out ={13'd0,shift_in[105:13]};
	    7'd14:shift_out ={14'd0,shift_in[105:14]};
	    7'd15:shift_out ={15'd0,shift_in[105:15]};
	    7'd16:shift_out ={16'd0,shift_in[105:16]};
	    7'd17:shift_out ={17'd0,shift_in[105:17]};
	    7'd18:shift_out ={18'd0,shift_in[105:18]};
	    7'd19:shift_out ={19'd0,shift_in[105:19]};
	    7'd20:shift_out ={20'd0,shift_in[105:20]};
	    7'd21:shift_out ={21'd0,shift_in[105:21]};
	    7'd22:shift_out ={22'd0,shift_in[105:22]};
	    7'd23:shift_out ={23'd0,shift_in[105:23]};
	    7'd24:shift_out ={24'd0,shift_in[105:24]};
	    7'd25:shift_out ={25'd0,shift_in[105:25]};
        7'd26:shift_out ={26'd0,shift_in[105:26]};
        7'd27:shift_out ={27'd0,shift_in[105:27]};
        7'd28:shift_out ={28'd0,shift_in[105:28]};
        7'd29:shift_out ={29'd0,shift_in[105:29]};
        7'd30:shift_out ={30'd0,shift_in[105:30]};
        7'd31:shift_out ={31'd0,shift_in[105:31]};
        7'd32:shift_out ={32'd0,shift_in[105:32]};  
        7'd33:shift_out ={33'd0,shift_in[105:33]}; 
        7'd34:shift_out ={34'd0,shift_in[105:34]};  
        7'd35:shift_out ={35'd0,shift_in[105:35]};
        7'd36:shift_out ={36'd0,shift_in[105:36]};
        7'd37:shift_out ={37'd0,shift_in[105:37]};
        7'd38:shift_out ={38'd0,shift_in[105:38]};
        7'd39:shift_out ={39'd0,shift_in[105:39]};
        7'd40:shift_out ={40'd0,shift_in[105:40]};
        7'd41:shift_out ={41'd0,shift_in[105:41]};
        7'd42:shift_out ={42'd0,shift_in[105:42]};
        7'd43:shift_out ={43'd0,shift_in[105:43]};
        7'd44:shift_out ={44'd0,shift_in[105:44]};
        7'd45:shift_out ={45'd0,shift_in[105:45]}; 
        7'd46:shift_out ={46'd0,shift_in[105:46]}; 
        7'd47:shift_out ={47'd0,shift_in[105:47]};      
        7'd48:shift_out ={48'd0,shift_in[105:48]};      
        7'd49:shift_out ={49'd0,shift_in[105:49]};      
        7'd50:shift_out ={50'd0,shift_in[105:50]};      
        7'd51:shift_out ={51'd0,shift_in[105:51]};      
        7'd52:shift_out ={52'd0,shift_in[105:52]};      
        7'd53:shift_out ={53'd0,shift_in[105:53]};      
        7'd54:shift_out ={54'd0,shift_in[105:54]};      
        7'd55:shift_out ={55'd0,shift_in[105:55]};      
        7'd56:shift_out ={56'd0,shift_in[105:56]};      
        7'd57:shift_out ={57'd0,shift_in[105:57]};      
        7'd58:shift_out ={58'd0,shift_in[105:58]};      
        7'd59:shift_out ={59'd0,shift_in[105:59]};      
        7'd60:shift_out ={60'd0,shift_in[105:60]};      
        7'd61:shift_out ={61'd0,shift_in[105:61]};      
        7'd62:shift_out ={62'd0,shift_in[105:62]};      
        7'd63:shift_out ={63'd0,shift_in[105:63]};      
        7'd64:shift_out ={64'd0,shift_in[105:64]};      
        7'd65:shift_out ={65'd0,shift_in[105:65]};      
        7'd66:shift_out ={66'd0,shift_in[105:66]};      
        7'd67:shift_out ={67'd0,shift_in[105:67]};      
        7'd68:shift_out ={68'd0,shift_in[105:68]};      
        7'd69:shift_out ={69'd0,shift_in[105:69]};      
        7'd70:shift_out ={70'd0,shift_in[105:70]};      
        7'd71:shift_out ={71'd0,shift_in[105:71]};      
        7'd72:shift_out ={72'd0,shift_in[105:72]};      
        7'd73:shift_out ={73'd0,shift_in[105:73]};      
        7'd74:shift_out ={74'd0,shift_in[105:74]};      
        7'd75:shift_out ={75'd0,shift_in[105:75]};      
        7'd76:shift_out ={76'd0,shift_in[105:76]};      
        7'd77:shift_out ={77'd0,shift_in[105:77]};      
        7'd78:shift_out ={78'd0,shift_in[105:78]};      
        7'd79:shift_out ={79'd0,shift_in[105:79]};      
        7'd80:shift_out ={80'd0,shift_in[105:80]};      
        7'd81:shift_out ={81'd0,shift_in[105:81]};      
        7'd82:shift_out ={82'd0,shift_in[105:82]};      
        7'd83:shift_out ={83'd0,shift_in[105:83]};      
        7'd84:shift_out ={84'd0,shift_in[105:84]};      
        7'd85:shift_out ={85'd0,shift_in[105:85]};      
        7'd86:shift_out ={86'd0,shift_in[105:86]};      
        7'd87:shift_out ={87'd0,shift_in[105:87]};      
        7'd88:shift_out ={88'd0,shift_in[105:88]};      
        7'd89:shift_out ={89'd0,shift_in[105:89]};      
        7'd90:shift_out ={90'd0,shift_in[105:90]};      
        7'd91:shift_out ={91'd0,shift_in[105:91]};      
        7'd92:shift_out ={92'd0,shift_in[105:92]};      
        7'd93:shift_out ={93'd0,shift_in[105:93]};      
        7'd94:shift_out ={94'd0,shift_in[105:94]};      
        7'd95:shift_out ={95'd0,shift_in[105:95]};      
        7'd96:shift_out ={96'd0,shift_in[105:96]};      
        7'd97:shift_out ={97'd0,shift_in[105:97]};      
        7'd98:shift_out ={98'd0,shift_in[105:98]};      
        7'd99:shift_out ={99'd0,shift_in[105:99]};      
        7'd100:shift_out={100'd0,shift_in[105:100]};      
        7'd101:shift_out={101'd0,shift_in[105:101]};      
        7'd102:shift_out={102'd0,shift_in[105:102]};      
        7'd103:shift_out={103'd0,shift_in[105:103]};      
        7'd104:shift_out={104'd0,shift_in[105:104]};      
        7'd105:shift_out={105'd0,shift_in[105   ]};      
	    default:shift_out=shift_in;
	endcase
  end
 endgenerate
endmodule