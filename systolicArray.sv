`default_nettype none

module systolicArray
  #(parameter int unsigned N = 4)
  ( input  var logic                         i_clk
  , input  var logic                         i_arst

  , input  var logic                         i_doProcess

  , input  var logic [N-1:0][(2*N)-2:0][7:0] i_row
  , input  var logic [N-1:0][(2*N)-2:0][7:0] i_col

  , output var logic [N-1:0][N-1:0][31:0]    o_c
  );



    
  
  wire [N-1:0][N:0][7:0] rowInterConnect;
  wire [N:0][N-1:0][7:0] colInterConnect;
  

  for (genvar i = 0; i < N; i++) begin: PerDummyRowColInterconnect

    // These are dummy interconnects used to pass data from the row matrices to
    // the i_a ports of PE in the first col.
   
    assign rowInterConnect[i][0] = i_row[i][0];
    assign colInterConnect[0][i] = i_col[i][0];

  end: PerDummyRowColInterconnect

  for (genvar i = 0; i < N; i++) begin: PerRow
    for (genvar j = 0; j < N; j++) begin: PerCol

      pe u_pe
      ( .i_clk
      , .i_arst

      , .i_doProcess

      , .i_a (rowInterConnect[i][j])
      , .i_b (colInterConnect[i][j])

      , .o_a (rowInterConnect[i][j+1])
      , .o_b (colInterConnect[i+1][j])
      , .o_y (o_c[i][j])
      );

    end: PerCol
  end: PerRow

endmodule

`resetall
