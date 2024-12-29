module csr_reg (
    input logic clk,
    input logic rst,
    input logic [31:0] pc_input,
    input logic [31:0] addr,
    input logic [31:0] wdata,
    input logic [31:0] inst,
    // input logic intr,
    input logic csr_wr,
    input logic csr_rd,

    input logic t_intr,
    input logic e_intr,
    input logic is_mret,

    output logic [31:0] rdata,
    output logic [31:0] epc,
    output logic intr_flag

);

    logic [31:0] mstatus;
    logic [31:0] mie;
    logic [31:0] mip;
    logic [31:0] mepc;
    logic [31:0] mcause;
    logic [31:0] mtvec;

    //ASYNC READ
    always_comb
    begin
        if(csr_rd)
        begin
            case (addr)
                12'h300:
                    rdata = mstatus;
                12'h304:
                    rdata = mie;
                12'h344:
                    rdata = mip;
                12'h4e3:
                    rdata = mepc;
            endcase
        end
    end

    //SYNC WRITE
    always_ff @(posedge clk)
    begin
        if(csr_wr)
        begin
            case (addr)
                12'h300:
                    mstatus <= wdata;
                12'h304:
                    mie <= wdata;
                12'h344:
                    mip <= wdata;
                12'h4e3:
                    mepc <= wdata;
            endcase
        end
    end

    //INTERRUPT HANDLING
    always_ff @(posedge t_intr, posedge e_intr, posedge rst)
    begin
        if (rst)
        begin
            mepc <= '0;
        end
        else
        begin
            mepc <= pc_input;
        end
   end

    //SET INTERRUPT BITS
    always_ff @(posedge clk, posedge rst)
    begin
        if (rst)
        begin
            mip <= '0;
        end
        if (t_intr)
        begin
            mip[7] <= 1'b1;
        end
        if (e_intr)
        begin
            mip[11] <= 1'b1;
        end
        else if (is_mret)
        begin
            mip <= '0;
        end
    end


    //GENERATING OUTPUT SIGNAL
    always_ff @(posedge clk, posedge rst)
    begin
        if (rst)
        begin
            intr_flag <= 1'b0;
        end
        else
        begin
            epc <= (mcause[30:0] << 2) + mtvec[31:2];
            intr_flag <= ( (mip[7] & mie[7]) | (mip[11] & mie[11]) ) & mstatus[3];
        end

    end



endmodule