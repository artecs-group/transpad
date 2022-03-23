module counter #(parameter N = 8) (
  input              clk,  // clock
  input              rstn, // sync active low reset
  input              en,   // enable signal
  output reg [N-1:0] out   // counter output
  );

  always @(posedge clk)
    if (!rstn)
      out <= 0;
    else if (en)
      out <= out + 1;

endmodule

