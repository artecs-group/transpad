module transpad_cu (
  input      clk,
  input      rstn,
  input      start_req_ok,
  input      stop_req,
  input      intlv_end,
  input      loop_end,
  input      oloop_end,
  output reg act,
  output reg st_addr_reg_rst,
  output reg sd2_ctrl_reg_rst,
  output reg d3_ctrl_reg_rst,
  output reg olp_ctrl_reg_rst,
  output reg mod_ctrl_reg_rst,
  output reg ofs_addr_reg_rst,
  output reg ofs_addr_reg_we,
  output reg t1_addr_reg_rst,
  output reg t2_addr_reg_rst,
  output reg t3_addr_reg_rst,
  output reg lst_addr_reg_rst,
  output reg lst_addr_reg_we,
  output reg lst_spad_reg_rst,
  output reg intlv_cnt_rst,
  output reg intlv_cnt_en,
  output reg loop_cnt_rst,
  output reg oloop_cnt_rst,
  output reg spaddr_cnt_rst,
  output reg conf_dec_en,
  output reg tx_addr_dec_en,
  output reg ofs_addr_sel,
  output reg tx_addr_sel
  );

  localparam [2:0]
    reset_state         = 3'b000,
    config_state        = 3'b001,
    init_ofs_addr_state = 3'b010,
    upd_ofs_addr_state  = 3'b011,
    load_tx_addr_state  = 3'b100,
    transl_state        = 3'b101;

  reg [2:0] cur_state, next_state;

  // next state generation logic
  always @(*)
  begin
    next_state = cur_state; // default case
    if (!rstn)
      next_state = reset_state;
    else
      case (cur_state)
        default:
          next_state = config_state;
        config_state:
          if (start_req_ok)
            next_state = init_ofs_addr_state;
        init_ofs_addr_state:
          next_state = load_tx_addr_state;
        load_tx_addr_state:
          if (intlv_end)
            next_state = transl_state;
        transl_state:
          if (loop_end || stop_req)
            if (oloop_end || stop_req)
              next_state = config_state;
            else
              next_state = upd_ofs_addr_state;
        upd_ofs_addr_state:
          next_state = load_tx_addr_state;
      endcase
  end

  // output generation logic
  always @(*)
  begin
    st_addr_reg_rst  = 1;
    sd2_ctrl_reg_rst = 1;
    d3_ctrl_reg_rst  = 1;
    olp_ctrl_reg_rst = 1;
    mod_ctrl_reg_rst = 1;
    ofs_addr_reg_rst = 1;
    ofs_addr_reg_we  = 0;
    t1_addr_reg_rst  = 1;
    t2_addr_reg_rst  = 1;
    t3_addr_reg_rst  = 1;
    lst_addr_reg_rst = 1;
    lst_addr_reg_we  = 0;
    lst_spad_reg_rst = 1;
    intlv_cnt_rst    = 1;
    intlv_cnt_en     = 0;
    loop_cnt_rst     = 1;
    oloop_cnt_rst    = 1;
    spaddr_cnt_rst   = 1;
    conf_dec_en      = 0;
    tx_addr_dec_en   = 0;
    ofs_addr_sel     = 0;
    tx_addr_sel      = 0;
    act              = 0;
    case (cur_state)
      default:
      begin
        st_addr_reg_rst  = 0;
        sd2_ctrl_reg_rst = 0;
        d3_ctrl_reg_rst  = 0;
        olp_ctrl_reg_rst = 0;
        mod_ctrl_reg_rst = 0;
        ofs_addr_reg_rst = 0;
        t1_addr_reg_rst  = 0;
        t2_addr_reg_rst  = 0;
        t3_addr_reg_rst  = 0;
        lst_addr_reg_rst = 0;
        lst_spad_reg_rst = 0;
        intlv_cnt_rst    = 0;
        loop_cnt_rst     = 0;
        oloop_cnt_rst    = 0;
        spaddr_cnt_rst   = 0;
      end
      config_state:
      begin
        conf_dec_en      = 1;
        lst_addr_reg_we  = 1;
      end
      init_ofs_addr_state:
        ofs_addr_reg_we  = 1;
      load_tx_addr_state:
      begin
        tx_addr_dec_en   = 1;
        intlv_cnt_en     = 1;
      end
      transl_state:
      begin
        tx_addr_sel      = 1;
        act              = 1;
      end
      upd_ofs_addr_state:
      begin
        ofs_addr_reg_we  = 1;
        ofs_addr_sel     = 1;
      end
    endcase 
  end

  // state evolution logic
  always @(posedge clk)
    cur_state <= next_state;

endmodule
