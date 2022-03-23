module decoder4 (
  input            en,
  input      [1:0] in,
  output reg [3:0] out
  );

  always @(*)
    if (!en)
      out = 4'b0;
    else begin
      case(in)
        default: out = 4'b0001;
        2'b01:   out = 4'b0010;
        2'b10:   out = 4'b0100;
        2'b11:   out = 4'b1000;
      endcase
    end

endmodule

