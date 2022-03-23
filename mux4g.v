module mux4g #(parameter N = 8) (
  input      [1:0]   sel,
  input      [N-1:0] in1,
  input      [N-1:0] in2,
  input      [N-1:0] in3,
  input      [N-1:0] in4,
  output reg [N-1:0] out
  );

  always @(*)
    case (sel)
      default: out = in1;
      2'b01:   out = in2;
      2'b10:   out = in3;
      2'b11:   out = in4;
    endcase

endmodule

