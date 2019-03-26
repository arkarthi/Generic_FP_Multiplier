////////////////////////////////////////////////////////////////////////////////////////
// Project Code      : S_1006
// Project Name      : Floating Point IP Core
// Module Name       : Generic Leading Zero Detection
// Function          : Multiply the two floating point operands
////////////////////////////////////////////////////////////////////////////////////////

module generic_lead_zero_detect
       # ( parameter   DW = 16)
         (
           // ......................//
           // Input port declaration//
           // ......................//
             in_d    ,
           // .......................//
           // Output port declaration//
           // .......................//
             out_d
         );

  function integer clog2;
    input integer DW;
      begin
        clog2 = 0;
        while (DW > 0)
          begin
            DW    = DW >> 1  ;
            clog2 = clog2 +1 ;
          end
       end
   endfunction//clog2
  localparam IDX_W      = clog2(DW-1)  ;
///////////////////////////////////////////////////
//-----------------Input Declaration-------------//
///////////////////////////////////////////////////
  input  wire[DW-1:0]           in_d    ;
///////////////////////////////////////////////////
//-----------------Output Declaration------------//
///////////////////////////////////////////////////
  output wire [IDX_W-1:0]        out_d   ;
///////////////////////////////////////////////////
//-----------------Wire Declaration--------------//
///////////////////////////////////////////////////
  wire   [DW-1  :0]      one_hot         ;
  wire   [DW-1  :0]      in_d_rev        ;
  //wire   [IDX_W-1:0]     out_d_next      ;
  //compute the lead zero detect one hot value
  //Bit reverse logic assignment - Low area just wire assignment
  genvar d;
   generate
    for (d=0; d<DW; d=d+1)
      begin:bit_reverse
       assign in_d_rev[d] = in_d[(DW-1)-d];
      end
   endgenerate

   // Method -1
   //one hot computation
   assign one_hot       =  (~in_d_rev + {{DW-1{1'B0}},1'B1}) & in_d_rev ;

   //one hot to binary converter
    genvar id,idm;
      generate
       for (idm=0; idm<IDX_W; idm=idm+1)
         begin : idx_gen
           wire [DW-1:0] mask;
             for (id=0; id<DW; id=id+1)
             begin : id_gen
               assign mask[id] = id[idm];
             end
         assign out_d[idm] = |(mask & one_hot);
       end
    endgenerate

 endmodule //generic_lead_zero_detect