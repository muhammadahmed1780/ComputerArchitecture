module tb_processor();

    // add x3, x4, x2
    // 00000000001000100000000110110011

    logic clk;
    logic rst;

    processor dut
    (
        .clk ( clk ),
        .rst ( rst )
    );

    // clock generator
    initial
    begin
        clk = 0;
        forever
        begin
            #5 clk = 1;
            #5 clk = 0;
            // $display("pc_in: %b", dut.pc_in);
            $display("pc_d: %b", dut.pc_out_d);


            // $display("oprA:%b", dut.alu_i.opr_a);
		    // $display("oprB:%b", dut.alu_i.opr_b);
		    $display("alu_out:%b", dut.BUFFER_EM_i.alu_out_M);
		    $display("wdata:%b", dut.reg_file_i.wdata);
		    $display("waddr:%b\n", dut.reg_file_i.waddr);
		    $display("datamem:%b", dut.data_mem_i.data_mem[0]);
		    $display("datamem:%b", dut.data_mem_i.data_mem[1]);
		    $display("datamem:%b", dut.data_mem_i.data_mem[2]);
		    $display("datamem:%b", dut.data_mem_i.data_mem[3]);
		    $display("datamemout:%b", dut.data_mem_i.out_data);
		    $display("wb_selected:%b", dut.sel_wb_mux.sel);
		    $display("\n");
            // $display("pc_sel_br:%b", dut.br_taken);
		    // $display("pc_sel_j:%b\n", dut.jump);
        end
    end

    // reset generator
    initial
    begin
        rst = 1;
        #10;
        rst = 0;
        #150;
		    $display("datamem:%b\n", dut.data_mem_i.data_mem[0]);
        $display("Processor is running");
        $display("x1: %b", dut.reg_file_i.reg_mem[1]);
        $display("x2: %b", dut.reg_file_i.reg_mem[2]);
        $display("x3: %b", dut.reg_file_i.reg_mem[3]);
        // $display("loaded in x4: %b", dut.reg_file_i.reg_mem[4]);
        // $display("JAL return address x5: %b", dut.reg_file_i.reg_mem[5]);
        // $display("loaded UI in x6: %b", dut.reg_file_i.reg_mem[6]);
        // $display("loaded UI+PC in x7: %b", dut.reg_file_i.reg_mem[7]);
        $finish;
    end

    // initialize memory
    initial
    begin
        $readmemh("inst.mem", dut.inst_mem_i.mem);
        $readmemb("rf.mem", dut.reg_file_i.reg_mem);
    end

    // dumping the waveform
    initial
    begin
        $dumpfile("processor.vcd");
        $dumpvars(0, dut);
    end

endmodule