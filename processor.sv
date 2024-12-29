module processor
(
    input logic clk,
    input logic rst
);
    // WIRES

    //Register file
    logic rf_en, rf_en_M;

    //Data Memory
    logic sel_a, sel_b;
    logic rd_en, rd_en_M, wr_en, wr_en_M;
    logic [1:0] sel_wb, sel_wb_M;

    //CSR
    logic csr_wr, csr_rd;
    logic t_intr, e_intr;
    logic is_mret, intr_flag, csr_op_sel;

    //Branch and Jump
    logic br_taken;
    logic jump;

    logic [3 :0] aluop;
    logic [2:0] mem_mode;
    logic [2:0] br_type;

    logic [31:0] pc_in;
    logic [31:0] pc_out_f, pc_out_d;
    logic [31:0] epc;
    logic [31:0] selected_pc, pc_d, pc_M;

    logic [31:0] inst_f, inst_d, inst_M;
    logic [ 4:0] rd, rd_M;
    logic [ 4:0] rs1;
    logic [ 4:0] rs2;
    logic [ 6:0] opcode;
    logic [ 2:0] funct3;
    logic [ 6:0] funct7;

    logic [31:0] rdata1;
    logic [31:0] rdata2, rdata2_M;
    logic [31:0] opr_a;
    logic [31:0] opr_b;
    logic [31:0] imm;

    logic [31:0] wdata;
    logic [31:0] alu_out, alu_out_M;
    logic [31:0] data_mem_out;
    logic [31:0] csr_data_out;
    logic [31:0] csr_op;

    //custom
    logic sel_laddr, wd2_en;
    logic [31:0] laddr;


 // ---------- FETCH -------- //

    // program counter
    pc pc_i
    (
        //in
        .clk(clk),
        .rst(rst),
        .pc_in(selected_pc),

        //out
        .pc_out(pc_out_f)
    );

    mux_2x1 pc_sel_mux
    (
        .sel(br_taken | jump),
        .input_a(pc_out_f + 32'd4),
        .input_b(alu_out),

        //out
        .out_y(pc_in)
    );

    mux_2x1 pc_final_sel
    (
        .sel(intr_flag),
        .input_a(pc_in),
        .input_b(epc),

        //out
        .out_y(selected_pc)
    );

    // instruction memory
    inst_mem inst_mem_i
    (
        .addr(pc_out_f),

        //out
        .data(inst_f)
    );


    BUFFER_FD BUFFER_FD_i
    (

        .clk(clk),
        .rst(rst),

        .pc_f(pc_out_f),
        .inst_f(inst_f),
        //out
        .pc_d(pc_out_d),
        .inst_d(inst_d)

    );

 // ---------- DECODE -------- //

    // instruction decoder
    inst_dec inst_dec_i
    (
        .inst(inst_d),

        //out
        .rs1(rs1),
        .rs2(rs2),
        // .rd(rd_M),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7)
    );

    //immediate generator
    imm_gen imm_gen_i
    (
        .inst(inst_d),

        //out
        .imm(imm)
    );

    // register file
    reg_file reg_file_i
    (
        .clk(clk),
        .rf_en(rf_en_M),
        .waddr(rd_M),
        .rs1(rs1),
        .rs2(rs2),
        .wdata(wdata),

        //custom
        .wd2_en(wd2_en),
        .wdata2(alu_out),

        //out
        .rdata1(rdata1),
        .rdata2(rdata2)

    );

        // controller
    controller controller_i
    (
        //in
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),

        //out
        .aluop(aluop),
        .rf_en(rf_en),
        .sel_a(sel_a),
        .sel_b(sel_b),
        .sel_wb(sel_wb),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .mem_mode(mem_mode),
        .br_type(br_type),
        .jump(jump),
        .csr_rd(csr_rd),
        .csr_wr(csr_wr),
        .is_mret(is_mret),
        .csr_op_sel(csr_op_sel),
        .sel_laddr(sel_laddr),
        .wd2_en(wd2_en)
    );

 // ---------- EXECUTE -------- //

    // alu
    alu alu_i
    (
        .aluop(aluop),
        .opr_a(opr_a),
        .opr_b(opr_b),

        //out
        .opr_res(alu_out)
    );

        //sel_a_mux
    mux_2x1 sel_a_mux
    (
        .sel(sel_a),
        .input_a(rdata1),
        .input_b(pc_out_d),

        //out
        .out_y(opr_a)
    );

    //sel_b_mux for I-type
    mux_2x1 sel_b_mux
    (
        .sel(sel_b),
        .input_a(rdata2),
        .input_b(imm),

        //out
        .out_y(opr_b)
    );

    //branch comparator
    branch_cond branch_cond_i
    (
        .rdata1(rdata1),
        .rdata2(rdata2),
        .br_type(br_type),

        //out
        .br_taken(br_taken)
    );


    BUFFER_EM BUFFER_EM_i
    (

        .clk(clk),
        .rst(rst),

        .wr_en_E(wr_en),
        .rd_en_E(rd_en),
        .sel_wb_E(sel_wb),
        .rf_en_E(rf_en),
        .pc_E(pc_d),
        .alu_out_E(alu_out),
        .rdata2_E(rdata2),
        .inst_E(inst_d),

        //out
        .wr_en_M(wr_en_M),
        .rd_en_M(rd_en_M),
        .sel_wb_M(sel_wb_M),
        .rf_en_M(rf_en_M),
        .pc_M(pc_M),
        .alu_out_M(alu_out_M),
        .rdata2_M(rdata2_M),
        .inst_M(inst_M),
        .rd_M(rd_M)
    );

 // ---------- MEMORY -------- //

    //Data memeory
     data_mem data_mem_i
    (
        .clk(clk),
        .rd_en(rd_en_M),
        .wr_en(wr_en_M),
        .addr(laddr),
        .wdata(rdata2_M),
        .mem_mode(mem_mode),

        //out
        .out_data(data_mem_out)
    );

    //csr
    csr_reg csr_reg_i
    (
        .clk(clk),
        .rst(rst),
        .pc_input(pc_in),
        .addr(alu_out_M),
        .wdata(csr_op),
        .inst(inst_d),
        .csr_rd(csr_rd),
        .csr_wr(csr_wr),
        .t_intr(t_intr),
        .e_intr(e_intr),
        .is_mret(is_mret),

        //out
        .rdata(csr_data_out),
        .epc(epc),
        .intr_flag(intr_flag)
    );

    //csr operand selection mux
    mux_2x1 sel_csr_op
    (
        .sel(csr_op_sel),
        .input_a(rdata1),
        .input_b(imm),

        //out
        .out_y(csr_op)
    );

    //selection of address for loading from data mem
    mux_2x1 sel_laddr_mux
    (
        .sel(sel_laddr),
        .input_a(alu_out_M),
        .input_b(rdata1),

        //out
        .out_y(laddr)
    );

 // ---------- WRITEBACK -------- //

    //write back selection for load instructions
    mux_4x1 sel_wb_mux
    (
        .sel(sel_wb_M),
        .input_a(alu_out_M),
        .input_b(data_mem_out),
        .input_c(pc_out+4),
        .input_d(csr_data_out),

        //out
        .out_y(wdata)
    );

endmodule