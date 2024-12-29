module BUFFER_EM (
    input logic clk, rst,
    input logic wr_en_E, rd_en_E, rf_en_E,
    input logic [1:0] sel_wb_E,
    input logic [31:0] pc_E, alu_out_E, rdata2_E, inst_E,

    output logic wr_en_M, rd_en_M, rf_en_M,
    output logic [1:0] sel_wb_M,
    output logic [4:0] rd_M,
    output logic [31:0] pc_M, alu_out_M, rdata2_M, inst_M
);

always_ff @(posedge clk, posedge rst)
begin

    if (rst)
    begin
        wr_en_M <= 0;
        rd_en_M <= 0;
        rf_en_M <= 0;
        sel_wb_M <= 2'b0;
        rd_M <= 5'b0;
        pc_M <= 32'b0;
        alu_out_M <= 32'b0;
        rdata2_M <= 32'b0;
        inst_M <= 32'b0;
    end
    else
    begin
        wr_en_M <= wr_en_E;
        rd_en_M <= rd_en_E;
        rf_en_M <= rf_en_E;
        sel_wb_M <= sel_wb_E;
        rd_M <= inst_E[11: 7];
        pc_M <= pc_E;
        alu_out_M <= alu_out_E;
        rdata2_M <= rdata2_E;
        inst_M <= inst_E;
    end

end

endmodule