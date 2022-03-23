module register #(parameter N = 8) (
  input              clk,  // clock
  input              rstn, // sync active low reset
  input              we,   // write enable signal
  input      [N-1:0] in,   // input data
  output reg [N-1:0] out   // output data
  );

  always @(posedge clk)
    if (!rstn)
      out <= 0;
    else if (we)
      out <= in;

endmodule

