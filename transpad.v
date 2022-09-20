module transpad (
  input  [2:0]   cmd,  // Command
  input  [47:0]  data, // Data
  input          rstn, // Reset (negative, synchronous)
  input          rdy,  // Ready
  input          clk,  // Clock
  output [23:0]  out,  // Output
  output         act,  // Active
  output         spm   // SPM or Main Memory
  );

  wire st_addr_reg_rst;
  wire sd2_ctrl_reg_rst;
  wire d3_ctrl_reg_rst;
  wire olp_ctrl_reg_rst;
  wire mod_ctrl_reg_rst;
  wire ofs_addr_reg_rst;
  wire ofs_addr_reg_we;
  wire t1_addr_reg_rst;
  wire t2_addr_reg_rst;
  wire t3_addr_reg_rst;
  wire lst_addr_reg_rst;
  wire lst_addr_reg_we;
  wire lst_spad_reg_rst;
  wire intlv_cnt_rst;
  wire intlv_cnt_en;
  wire loop_cnt_rst;
  wire oloop_cnt_rst;
  wire spaddr_cnt_rst;
  wire conf_dec_en;
  wire tx_addr_dec_en;
  wire ofs_addr_sel;
  wire tx_addr_sel;
  wire start_req_ok;
  wire stop_req;
  wire intlv_end;
  wire loop_end;
  wire oloop_end;

  // datapath
  transpad_dp datapath(.*);

  // control unit
  transpad_cu control_unit(.*);

endmodule
