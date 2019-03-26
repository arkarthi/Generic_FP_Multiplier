module fp_multiplier_tb();

parameter DATA_WIDTH=16;
parameter T_IN=31;


reg           clk           ;
reg           rst           ;
reg           in_vld        ;
reg    [15:0] fp_in1        ;
reg    [15:0] fp_in2        ;
reg           en            ;
wire   [15:0] fp_out        ;
wire          out_vld       ;
wire   [2 :0] num_value     ; 
wire          over_flow     ;
wire          under_flow    ;


event e1;

fp_multiplication

#(
   .DW(DATA_WIDTH)
 )
uut_fp_multiplication
(
  
 .clk           (clk           ),
 .in_valid      (in_vld ),
 .reset_n       (rst       ),
 .opa_a         (fp_in1        ),
 .opa_b         (fp_in2        ), 
 .en            (en          ), 
 .out_result    (fp_out        ),
 .out_valid     (out_vld),
 .num_value     (num_value     ),
 .over_flow     (over_flow     ),
 .under_flow    (under_flow    ) 
);


reg [15:0] data[0:(2*T_IN)-1];
reg [15:0] exp_out[T_IN-1:0];
reg [15:0] our_out[T_IN-1:0];


initial
  begin
    clk=1'b1; 
    forever #10 clk=~clk;
  end
  
initial
  begin
    rst=1'b0; 
	en =1'b0; 
	repeat(5)
    @(posedge clk);
	    rst=1'b1;
	     @(posedge clk);
       	en =1'b1; 
	     repeat(2)
         @(posedge clk);
     ->e1;
  end  

integer our;
integer i,j,k,count;
initial 
  begin
  fp_in1<=16'd0;
  fp_in2<=16'd0;
  in_vld<=1'd0;
	  $readmemh("fp_inout.txt",data);	
	  $readmemh("predicted_out.txt",exp_out);
	  @(e1);
	     for(i=0;i<(2*T_IN);i=i+2)
         begin
          @(posedge clk);
          fp_in1<=data[i];
          fp_in2<=data[i+1];	
          in_vld<=1;
	     end	
	     in_vld<=0;
    end
 
initial
begin
our=$fopen("actual_out.txt");
@(e1);
while(!out_vld)
@(posedge clk);
for(j=0;j<T_IN;j=j+1)
  begin
   our_out[j]=fp_out;
	$fwrite(our,"%h\n",our_out[j]);
	 @(posedge clk);
  end
$fclose(our);
count=0;
for(k=0;k<T_IN;k=k+1)
  begin
   if(our_out[k]==exp_out[k])	
	 begin	
	  count=count+1;
	 end 
	else 
	 begin
	   $display("Wrong at %d",k+1);
	   count=count;	
	 end	 
  end
$display("%d out of %d is matched sucessfully",count,T_IN);
$stop;
end
  
endmodule

