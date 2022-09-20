module transpad_dp (
  input             st_addr_reg_rst,
  input             sd2_ctrl_reg_rst,
  input             d3_ctrl_reg_rst,
  input             olp_ctrl_reg_rst,
  input             mod_ctrl_reg_rst,
  input             ofs_addr_reg_rst,
  input             ofs_addr_reg_we,
  input             t1_addr_reg_rst,
  input             t2_addr_reg_rst,
  input             t3_addr_reg_rst,
  input             lst_addr_reg_rst,
  input             lst_addr_reg_we,
  input             lst_spad_reg_rst,
  input             intlv_cnt_rst,
  input             intlv_cnt_en,
  input             loop_cnt_rst,
  input             oloop_cnt_rst,
  input             spaddr_cnt_rst,
  input             conf_dec_en,
  input             tx_addr_dec_en,
  input             ofs_addr_sel,
  input             tx_addr_sel,
  input      [2:0]  cmd,
  input      [47:0] data,
  input             rdy,
  input             clk,
  output            start_req_ok,
  output            stop_req,
  output            intlv_end,
  output            loop_end,
  output            oloop_end,
  output     [23:0] out,
  output            spm
  );

  // conf_dec signals
  /* verilator lint_off UNUSED */
  wire [7:0] conf_dec_out;
  /* verilator lint_on UNUSED */
  wire       st_addr_reg_we  = conf_dec_out[0];
  wire       sd2_ctrl_reg_we = conf_dec_out[1];
  wire       d3_ctrl_reg_we  = conf_dec_out[2];
  wire       olp_ctrl_reg_we = conf_dec_out[3];
  wire       mod_ctrl_reg_we = conf_dec_out[4];
  wire       conf_dec_en_int = (rdy && conf_dec_en);
  decoder8 conf_dec(.en(conf_dec_en_int),
                    .in(cmd),
                    .out(conf_dec_out));

  // st_addr_reg signals
  wire [47:0] st_addr;
  wire        st_addr_reg_we;
  register #(.N(48)) st_addr_reg( .clk(clk),
                                  .rstn(st_addr_reg_rst),
                                  .we(st_addr_reg_we),
                                  .in(data),
                                  .out(st_addr));

  // sd2_ctrl_reg signals
  wire [47:0] sd2_ctrl_reg_out;
  wire [15:0] str1 = sd2_ctrl_reg_out[47:32];
  wire [15:0] str2 = sd2_ctrl_reg_out[31:16];
  wire [15:0] ofs2 = sd2_ctrl_reg_out[15:0];
  wire        sd2_ctrl_reg_we;
  register #(.N(48)) sd2_ctrl_reg(.clk(clk),
                                  .rstn(sd2_ctrl_reg_rst),
                                  .we(sd2_ctrl_reg_we),
                                  .in(data),
                                  .out(sd2_ctrl_reg_out));

  // d3_ctrl_reg signals
  /* verilator lint_off UNUSED */
  wire [47:0] d3_ctrl_reg_out;
  /* verilator lint_on UNUSED */
  wire [15:0] str3 = d3_ctrl_reg_out[31:16];
  wire [15:0] ofs3 = d3_ctrl_reg_out[15:0];
  wire        d3_ctrl_reg_we;
  register #(.N(48)) d3_ctrl_reg( .clk(clk),
                                  .rstn(d3_ctrl_reg_rst),
                                  .we(d3_ctrl_reg_we),
                                  .in(data),
                                  .out(d3_ctrl_reg_out));

  // olp_ctrl_reg signals
  /* verilator lint_off UNUSED */
  wire [47:0] olp_ctrl_reg_out;
  /* verilator lint_on UNUSED */
  wire [15:0] oofs = olp_ctrl_reg_out[31:16];
  wire [15:0] olen = olp_ctrl_reg_out[15:0];
  wire        olp_ctrl_reg_we;
  register #(.N(48)) olp_ctrl_reg(.clk(clk),
                                  .rstn(olp_ctrl_reg_rst),
                                  .we(olp_ctrl_reg_we),
                                  .in(data),
                                  .out(olp_ctrl_reg_out));

  // mod_ctrl_reg signals
  /* verilator lint_off UNUSED */
  wire [47:0] mod_ctrl_reg_out;
  wire [15:0] mode = mod_ctrl_reg_out[31:16];
  /* verilator lint_on UNUSED */
  wire [15:0] len  = mod_ctrl_reg_out[15:0];
  wire        mod_ctrl_reg_we;
  register #(.N(48)) mod_ctrl_reg(.clk(clk),
                                  .rstn(mod_ctrl_reg_rst),
                                  .we(mod_ctrl_reg_we),
                                  .in(data),
                                  .out(mod_ctrl_reg_out));

  // ofs_addr_reg signals
  wire [15:0] ofs_mux_out;
  wire [1:0]  ofs_sel = (ofs_addr_sel ? 2'b11 : intlv_cnt_out);
  wire [47:0] ofs_addr_reg_out;
  wire [47:0] ofs_addr = (ofs_addr_reg_out + {32'b0, ofs_mux_out});
  wire [47:0] ofs_addr_reg_in = (ofs_addr_sel ? ofs_addr : st_addr);
  register #(.N(48)) ofs_addr_reg(.clk(clk),
                                  .rstn(ofs_addr_reg_rst),
                                  .we(ofs_addr_reg_we),
                                  .in(ofs_addr_reg_in),
                                  .out(ofs_addr_reg_out));
  mux4g    #(.N(16)) ofs_mux(     .sel(ofs_sel),
                                  .in1(16'b0),
                                  .in2(ofs2),
                                  .in3(ofs3),
                                  .in4(oofs),
                                  .out(ofs_mux_out));

  // tx_addr_dec signals
  /* verilator lint_off UNUSED */
  wire [3:0] tx_addr_dec_out;
  /* verilator lint_on UNUSED */
  wire       t1_addr_reg_we = tx_addr_dec_out[0];
  wire       t2_addr_reg_we = tx_addr_dec_out[1];
  wire       t3_addr_reg_we = tx_addr_dec_out[2];
  wire       tx_addr_dec_en_int = (ch_addr || tx_addr_dec_en);
  decoder4 tx_addr_dec(.en(tx_addr_dec_en_int),
                       .in(intlv_cnt_out),
                       .out(tx_addr_dec_out));

  // tx_addr_reg signals
  wire [47:0] tx_addr_in = (tx_addr_sel ? new_addr : ofs_addr);
  wire [47:0] t1_addr_reg_out, t2_addr_reg_out, t3_addr_reg_out;
  wire        t1_addr_reg_we, t2_addr_reg_we, t3_addr_reg_we;
  wire [47:0] tgt_addr;
  wire [15:0] str_mux_out;
  wire [47:0] new_addr = (tgt_addr + {32'b0, str_mux_out});
  register #(.N(48)) t1_addr_reg(.clk(clk),
                                 .rstn(t1_addr_reg_rst),
                                 .we(t1_addr_reg_we),
                                 .in(tx_addr_in),
                                 .out(t1_addr_reg_out));
  register #(.N(48)) t2_addr_reg(.clk(clk),
                                 .rstn(t2_addr_reg_rst),
                                 .we(t2_addr_reg_we),
                                 .in(tx_addr_in),
                                 .out(t2_addr_reg_out));
  register #(.N(48)) t3_addr_reg(.clk(clk),
                                 .rstn(t3_addr_reg_rst),
                                 .we(t3_addr_reg_we),
                                 .in(tx_addr_in),
                                 .out(t3_addr_reg_out));
  mux4g    #(.N(48)) tx_addr_mux(.sel(intlv_cnt_out),
                                 .in1(t1_addr_reg_out),
                                 .in2(t2_addr_reg_out),
                                 .in3(t3_addr_reg_out),
                                 .in4(48'b0),
                                 .out(tgt_addr));
  mux4g    #(.N(16)) str_mux(    .sel(intlv_cnt_out),
                                 .in1(str1),
                                 .in2(str2),
                                 .in3(str3),
                                 .in4(16'b0),
                                 .out(str_mux_out));

  // lst_addr_reg signals
  wire [47:0] lst_addr_reg_in = (lst_addr_reg_we ? st_addr : tgt_addr);
  wire [47:0] lst_addr_reg_out;
  wire        lst_addr_reg_we_int = (ch_addr || lst_addr_reg_we);
  register #(.N(48)) lst_addr_reg(.clk(clk),
                                  .rstn(lst_addr_reg_rst),
                                  .we(lst_addr_reg_we_int),
                                  .in(lst_addr_reg_in),
                                  .out(lst_addr_reg_out));

  // lst_spad_reg signals
  wire [23:0] lst_spad_reg_out;
  register #(.N(24)) lst_spad_reg(.clk(clk),
                                  .rstn(lst_spad_reg_rst),
                                  .we(ch_addr),
                                  .in(spaddr_cnt_out),
                                  .out(lst_spad_reg_out));

  // intlv_cnt signals
  wire [1:0] intlv_cnt_out;
  assign     intlv_end          = (mode[1:0] == intlv_cnt_out);
  wire       intlv_cnt_rst_int  = (intlv_cnt_rst && ~intlv_end);
  wire       intlv_cnt_en_int   = (intlv_cnt_en  || ch_addr);
  counter  #(.N(2))  intlv_cnt(  .clk(clk),
                                 .rstn(intlv_cnt_rst_int),
                                 .en(intlv_cnt_en_int),
                                 .out(intlv_cnt_out));

  // loop_cnt signals
  wire [15:0] loop_cnt_out;
  assign      loop_end          = (len == loop_cnt_out);
  wire        loop_cnt_rst_int  = (loop_cnt_rst && ~loop_end);
  counter  #(.N(16)) loop_cnt(   .clk(clk),
                                 .rstn(loop_cnt_rst_int),
                                 .en(ch_addr),
                                 .out(loop_cnt_out));

  // oloop_cnt signals
  wire [15:0] oloop_cnt_out;
  assign      oloop_end         = (olen == oloop_cnt_out);
  wire        oloop_cnt_rst_int = (oloop_cnt_rst && ~oloop_end);
  counter  #(.N(16)) oloop_cnt(  .clk(clk),
                                 .rstn(oloop_cnt_rst_int),
                                 .en(loop_end),
                                 .out(oloop_cnt_out));

  // spaddr_cnt signals
  wire [23:0] spaddr_cnt_out;
  counter  #(.N(24)) spaddr_cnt( .clk(clk),
                                 .rstn(spaddr_cnt_rst),
                                 .en(ch_addr),
                                 .out(spaddr_cnt_out));

  // other signals
  wire   start_req    = (rdy && (cmd == 3'b111) && (data[7:0] == 8'b10100101));
  assign stop_req     = (rdy && (cmd == 3'b111) && (data[7:0] == 8'b01011010));
  wire   valid_mode   = (mode[3:0] == 4'b1100) ||
                        (mode[3:0] == 4'b1101) ||
                        (mode[3:0] == 4'b1110);
  assign start_req_ok = (start_req && valid_mode);
  wire   tgt_found    = (data == tgt_addr);
  wire   lst_found    = (data == lst_addr_reg_out);
  wire   ch_addr      = (rdy && tgt_found);
  assign spm          = (rdy && (tgt_found || lst_found));
  assign out          = (lst_found ? lst_spad_reg_out : spaddr_cnt_out);

endmodule
