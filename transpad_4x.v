module transpad_4x (
  input  [1:0]  unit,  // Target unit
  input         rdy,   // Ready
  input  [2:0]  cmd,   // Command
  input  [47:0] data,  // Data
  input         rstn,  // Reset (negative, synchronous)
  input         clk,   // Clock
  output [23:0] out,   // Output
  output        act,   // Active
  output        spm    // SPM or Main Memory
  );

  wire [3:0] st_addr_reg_rst;
  wire [3:0] sd2_ctrl_reg_rst;
  wire [3:0] d3_ctrl_reg_rst;
  wire [3:0] olp_ctrl_reg_rst;
  wire [3:0] mod_ctrl_reg_rst;
  wire [3:0] ofs_addr_reg_rst;
  wire [3:0] ofs_addr_reg_we;
  wire [3:0] t1_addr_reg_rst;
  wire [3:0] t2_addr_reg_rst;
  wire [3:0] t3_addr_reg_rst;
  wire [3:0] lst_addr_reg_rst;
  wire [3:0] lst_addr_reg_we;
  wire [3:0] lst_spad_reg_rst;
  wire [3:0] intlv_cnt_rst;
  wire [3:0] intlv_cnt_en;
  wire [3:0] loop_cnt_rst;
  wire [3:0] oloop_cnt_rst;
  wire [3:0] spaddr_cnt_rst;
  wire [3:0] conf_dec_en;
  wire [3:0] tx_addr_dec_en;
  wire [3:0] ofs_addr_sel;
  wire [3:0] tx_addr_sel;
  wire [3:0] start_req_ok;
  wire [3:0] stop_req;
  wire [3:0] intlv_end;
  wire [3:0] loop_end;
  wire [3:0] oloop_end;

  // unit selection decoder
  wire [3:0] u_dec, u_rdy;
  decoder4 sel_dec(.en(1'b1),
                   .in(unit),
                   .out(u_dec));
  assign u_rdy = (u_dec & {4{rdy}});

  // output selection muxes
  wire [95:0]  u_out;
  wire [3:0]   u_act;
  wire [3:0]   u_spm;
  integer u_idx;
  always @(*)
    u_idx = unit;
  assign out = u_out[u_idx*24+23:u_idx*24];
  assign spm = u_spm[u_idx];
  assign act = u_act[u_idx];

  genvar i;
  generate
    for (i=0; i<4; i=i+1) begin : unit
      transpad_dp datapath (
        .st_addr_reg_rst(st_addr_reg_rst[i]),
        .sd2_ctrl_reg_rst(sd2_ctrl_reg_rst[i]),
        .d3_ctrl_reg_rst(d3_ctrl_reg_rst[i]),
        .olp_ctrl_reg_rst(olp_ctrl_reg_rst[i]),
        .mod_ctrl_reg_rst(mod_ctrl_reg_rst[i]),
        .ofs_addr_reg_rst(ofs_addr_reg_rst[i]),
        .ofs_addr_reg_we(ofs_addr_reg_we[i]),
        .t1_addr_reg_rst(t1_addr_reg_rst[i]),
        .t2_addr_reg_rst(t2_addr_reg_rst[i]),
        .t3_addr_reg_rst(t3_addr_reg_rst[i]),
        .lst_addr_reg_rst(lst_addr_reg_rst[i]),
        .lst_addr_reg_we(lst_addr_reg_we[i]),
        .lst_spad_reg_rst(lst_spad_reg_rst[i]),
        .intlv_cnt_rst(intlv_cnt_rst[i]),
        .intlv_cnt_en(intlv_cnt_en[i]),
        .loop_cnt_rst(loop_cnt_rst[i]),
        .oloop_cnt_rst(oloop_cnt_rst[i]),
        .spaddr_cnt_rst(spaddr_cnt_rst[i]),
        .conf_dec_en(conf_dec_en[i]),
        .tx_addr_dec_en(tx_addr_dec_en[i]),
        .ofs_addr_sel(ofs_addr_sel[i]),
        .tx_addr_sel(tx_addr_sel[i]),
        .cmd(cmd),
        .data(data),
        .rdy(u_rdy[i]),
        .clk(clk),
        .start_req_ok(start_req_ok[i]),
        .stop_req(stop_req[i]),
        .intlv_end(intlv_end[i]),
        .loop_end(loop_end[i]),
        .oloop_end(oloop_end[i]),
        .out(u_out[i*24+23:i*24]),
        .spm(u_spm[i])
      );
      transpad_cu control_unit (
        .clk(clk),
        .rstn(rstn),
        .start_req_ok(start_req_ok[i]),
        .stop_req(stop_req[i]),
        .intlv_end(intlv_end[i]),
        .loop_end(loop_end[i]),
        .oloop_end(oloop_end[i]),
        .act(u_act[i]),
        .st_addr_reg_rst(st_addr_reg_rst[i]),
        .sd2_ctrl_reg_rst(sd2_ctrl_reg_rst[i]),
        .d3_ctrl_reg_rst(d3_ctrl_reg_rst[i]),
        .olp_ctrl_reg_rst(olp_ctrl_reg_rst[i]),
        .mod_ctrl_reg_rst(mod_ctrl_reg_rst[i]),
        .ofs_addr_reg_rst(ofs_addr_reg_rst[i]),
        .ofs_addr_reg_we(ofs_addr_reg_we[i]),
        .t1_addr_reg_rst(t1_addr_reg_rst[i]),
        .t2_addr_reg_rst(t2_addr_reg_rst[i]),
        .t3_addr_reg_rst(t3_addr_reg_rst[i]),
        .lst_addr_reg_rst(lst_addr_reg_rst[i]),
        .lst_addr_reg_we(lst_addr_reg_we[i]),
        .lst_spad_reg_rst(lst_spad_reg_rst[i]),
        .intlv_cnt_rst(intlv_cnt_rst[i]),
        .intlv_cnt_en(intlv_cnt_en[i]),
        .loop_cnt_rst(loop_cnt_rst[i]),
        .oloop_cnt_rst(oloop_cnt_rst[i]),
        .spaddr_cnt_rst(spaddr_cnt_rst[i]),
        .conf_dec_en(conf_dec_en[i]),
        .tx_addr_dec_en(tx_addr_dec_en[i]),
        .ofs_addr_sel(ofs_addr_sel[i]),
        .tx_addr_sel(tx_addr_sel[i])
      );
  end
  endgenerate

endmodule
