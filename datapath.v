module datapath (
    input  wire                  clk,
    input  wire                reset,
    // Fetch stage signals
    input  wire               stallF,
    input  wire [31 : 0]      instrF,
    output wire [31 : 0]         pcF,
    // Decode stage signals
    input  wire               stallD,
    input  wire               flushD,
    input  wire [2 : 0]     imm_srcD,
    output wire [6 : 0]          opD,
    output wire [2 : 0]      funct3D,
    output wire            funct7b5D,
    // Execute stage signals
    input  wire               flushE,
    input  wire [1 : 0]   forward_AE,
    input  wire [1 : 0]   forward_BE,
    inout  wire              pc_srcE,
    input  wire       pc_target_srcE,
    input  wire [3 : 0] alu_controlE,
    input  wire           ALU_src_AE,
    input  wire           ALU_src_BE,
    output wire [3 : 0]       flagsE,
    // Memory stage signals
    input  wire           mem_writeM,
    input  wire [31 : 0]  read_dataM,
    input  wire [1 : 0]   load_typeM,
    input  wire          store_typeM,
    output wire [31 : 0] alu_resultM,
    output wire [31 : 0] write_dataM,
    // Writeback stage signals
    input  wire           reg_writeW,
    input  wire [1 : 0]  result_srcW,
    // Hazard Unit signals
    output wire [4 : 0]         Rs1D,
    output wire [4 : 0]         Rs2D,
    output wire [4 : 0]         Rs1E,
    output wire [4 : 0]         Rs1E,
    output wire [4 : 0]          RdE,
    output wire [4 : 0]          RdM,
    output wire [4 : 0]          RdW
); 
    // Fetch stage signals
    wire [31 : 0] pc_nextF;
    wire [31 : 0] pc_plus4F;

    // Decode stage signals
    wire [31 : 0] instrD;
    wire [31 : 0] pcD;
    wire [31 : 0] pc_plus4D;
    wire [31 : 0] RD1D;
    wire [31 : 0] RD2D;
    wire [31 : 0] imm_extD;
    wire [4 : 0] RdD;

    // Execute stage signals
    wire [31 : 0] RD1E;
    wire [31 : 0] RD2E;
    wire [31 : 0] PCE;
    wire [31 : 0] imm_ExtE;
    wire [31 : 0] pc_targetE;
    wire [31 : 0] pc_plus4E;
    wire [31 : 0] pc_relative_targetE;
    wire [31 : 0] write_dataE;
    wire [31 : 0] src_AE;
    wire [31 : 0] src_BE;
    wire [31 : 0] src_AE_forward;
    wire [31 : 0] alu_resultE;

    // Memory stage signals
    wire [31 : 0] RD2M;
    wire [31 : 0] pc_plus4M;
    wire [31 : 0] pc_targetM;
    wire [7 : 0]  byte_outM;
    wire [31 : 0] zero_extend_byteM;
    wire [31 : 0] read_data_outM;
    wire [31 : 0] sign_extend_byteM;

    // Writeback stage signals
    wire [31 : 0] alu_resultW;
    wire [31 : 0] read_data_outW;
    wire [31 : 0] pc_plus4W;
    wire [31 : 0] pc_targetW;
    wire [31 : 0] RD2W;
    wire [31 : 0] resultW;

    /**************
    * Fetch stage
    **************/
    mux2 #(32) pc_mux(
        .d0(pc_plus4F),
        .d1(pc_targetE),
        .s(pc_srcE),
        .y(pc_nextF)
    );

    flopenr #(32) pc_reg (
        .clk(clk),
        .reset(reset),
        .en(~stallF),
        .d(pc_nextF),
        .q(pcF)
    );

    adder #(32) pc_add4 (
        .a(pcF),
        .b(32'd4),
        .y(pc_plus4F)
    );

    /***************
    * Decode stage
    ***************/ 
    flopenrc #(96) regD(
        .clk(clk),
        .reset(reset),
        .en(~stallD),
        .clear(flushD),
        .d({instrF, pcF, pc_plus4F}),
        .q({instrD, pcD, pc_plus4D})
    );

    assign opD = instrD[6:0];
    assign funct3D = instrD[14:12];
    assign funct7b5D = instrD[31];
    assign RdD = instrD[11:7];
    assign Rs1D = instrD[19:15];
    assign Rs2D = instrD[24:20];

    regfile rf(
        .clk(clk),
        .we3(reg_writeW),
        .a1(Rs1D),
        .a2(Rs2D),
        .a3(RdW),
        .wd3(resultW),
        .rd1(RD1D),
        .rd2(RD2D)
    );

    extender ext(
        .instr(instrD[31 : 7]),
        .imm_src(imm_srcD),
        .imm_ext(imm_extD)
    );

    /***************
    * Execute stage
    ***************/
    floprc #(175) regE (
        .clk(clk),
        .reset(reset),
        .clear(flushE),
        .d({RD1D, RD2D, pcD, Rs1D, Rs2D, RdD, imm_extD, pc_plus4D}),
        .q({RD1E, RD2E, PCE, Rs1E, Rs2E, RdE, imm_ExtE, pc_plus4E})
    );

    mux3 #(32) forward_AE_mux(
        .d0(RD1E),
        .d1(resultW),
        .d2(alu_resultM),
        .s(forward_AE),
        .y(src_AE_forward)
    );

    mux2 #(32) src_a_mux(
        .d0(src_AE_forward),
        .d1(32'b0),
        .s(ALU_src_AE),
        .y(write_dataE)
    );

    mux3 #(32) forward_BE_mux(
        .d0(RD2E),
        .d1(resultW),
        .d2(alu_resultM),
        .s(forward_BE),
        .y(write_dataE)
    );

    mux2 #(32) src_b_mux(
        .d0(write_dataE),
        .d1(imm_ExtE),
        .s(ALU_src_BE),
        .y(src_BE)
    );

    alu alu(
        .a(src_AE),
        .b(src_BE),
        .alu_control(alu_controlE),
        .result(alu_resultE),
        .flags(flagsE)
    );

    adder #(32) pc_branch (
        .a(PCE),
        .b(imm_ExtE),
        .y(pc_relative_targetE)
    );

    mux2 #(32) pc_target_mux(
        .d0(pc_relative_targetE),
        .d1(alu_resultE),
        .s(pc_target_srcE),
        .y(pc_targetE)
    );

    /***************
    * Memory stage
    ***************/
    flopr #(133) regM (
        .clk(clk),
        .reset(reset),
        .d({alu_resultE, RD2E, write_dataE, RdE, pc_plus_4E, pc_targetE}),
        .q({alu_resultM, RD2M, write_dataM, RdM, pc_plus_4M, pc_targetM})
    );

    wdunit wd(
        .rd2(RD2M),
        .read_data(read_dataM),
        .store_type(store_typeM),
        .byte_of_fset(alu_resultM[1 : 0]),
        .write_data(write_dataM)
    );

    mux4 #(8) byte_select (
        .d0(read_dataM[7 : 0]),
        .d1(read_dataM[15 : 8]),
        .d2(read_dataM[23 : 16]),
        .d3(read_dataM[31 : 24]),
        .s(alu_resultM[1 : 0]),
        .y(byte_outM)
    );

    zeroextend ze (
        .a(byte_outM),
        .zeroimmext(zero_extend_byteM)
    );

    signeextend se (
        .a(byte_outM),
        .signimmext(sign_extend_byteM)
    );

    mux3 #(32) read_data_mux (
        .d0(read_dataM),
        .d1(zero_extend_byteM),
        .d2(sign_extend_byteM),
        .s(load_typeM),
        .y(read_data_outM)
    );

    /*****************
    * Writeback stage
    *****************/
    flopr #(133) regW (
        .clk(clk),
        .reset(reset),
        .d({alu_resultM, read_data_outM, RdM, pc_plus4M, pc_targetM}),
        .q({alu_resultW, read_data_outW, RdW, pc_plus4W, pc_targetW})
    );

    mux4 #(32) result_mux (
        .d0(alu_resultW),
        .d1(read_data_outW),
        .d2(pc_plus4W),
        .d3(pc_targetW),
        .s(result_srcW),
        .y(resultW)
    );

endmodule