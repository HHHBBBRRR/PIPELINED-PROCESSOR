module controller (
    input  wire                   clk,
    input  wire                 reset,
    // Decode stage signals
    input  wire [6 : 0]          opD,
    input  wire [2 : 0]      funct3D,
    input  wire            funct7b5D,
    output wire [2 : 0]     imm_srcD,
    // Execute stage signals
    input wire                flushE,
    input  wire [3 : 0]       flagsE,
    output wire              pc_srcE,
    output wire [3 : 0] alu_controlE,
    output wire           ALU_src_AE,
    output wire           ALU_src_BE,
    output wire          result_srcE,
    output wire       pc_target_srcE,
    // Memory stage signals
    output wire           mem_writeM,
    output wire           reg_writeM,
    output wire [1 : 0]   load_typeM,
    output wire          store_typeM,
    // Writeback stage signals
    output wire           reg_writeW,
    output wire [1 : 0]  result_srcW,
);
    // Decode stage signals
    wire                   reg_writeD;
    wire                  result_srcD;
    wire                   mem_writeD;
    wire                        jumpD;
    wire                      branchD;
    wire [1 : 0]              alu_opD;
    wire [3 : 0]         alu_controlD;
    wire                   ALU_src_AD;
    wire                   ALU_src_BD;
    wire               pc_target_srcD;
    wire [1 : 0]           load_typeD;
    wire                  store_typeD;
    // Execute stage signals
    wire                   reg_writeE;
    wire                   mem_writeE;
    wire [2 : 0]              funct3E;
    wire                        jumpE;
    wire                      branchE;
    wire [1 : 0]           load_typeE;
    wire                  store_typeE;
    wire                branch_takenE;
    // Memory stage signals
    wire [1 : 0]          result_srcM;          

    /**************
    * Decode stage
    **************/
    maindec md (
        .op(opD),
        .result_src(result_srcD),
        .mem_write(mem_writeD),
        .branch(branchD),
        .ALU_src_A(ALU_src_AD),
        .ALU_src_B(ALU_src_BD),
        .reg_write(reg_writeD),
        .imm_src(imm_src),
        .jump(jumpD),
        .alu_op(alu_opD),
        .pc_target_src(pc_target_src)
    );

    aludec ad (
        .opb5(opD[5]),
        .funct3(funct3D),
        .funct7b5(funct7b5D),
        .alu_op(alu_opD),
        .alu_control(alu_controlD)
    );

    lsu lsu (
        .funct3(funct3D),
        .load_tyep(load_typeD),
        .store_type(store_typeD)
    );

    /***************
    * Execute stage
    ***************/
    floprc #(17) regE (
        .clk(clk),
        .reset(reset),
        .d({reg_writeD, result_srcD, mem_writeD, branchD,
            jumpD, alu_controlD, ALU_src_AD, ALU_src_BD, funct3D
            pc_target_srcD, load_typeD, store_typeD}),
        .q({reg_writeE, result_srcE, mem_writeE, branchE,
        jumpE, alu_controlE, ALU_src_AE, ALU_src_BE, funct3E
        pc_target_srcE, load_typeE, store_typeE})
    );

    bu branch_unit (
        .branch(branchE),
        .flags(flagsE),
        .funct3(funct3E),
        .taken(branch_takenE)
    );

    assign pc_srcE = jumpE | branch_takenE;

    /***************
    * Memory stage
    ***************/
    floprc #(11) regM (
        .clk(clk),
        .reset(reset),
        .d({reg_writeE, result_srcE, mem_writeE, load_typeE, store_typeE}),
        .q({reg_writeM, result_srcM, mem_writeM, load_typeM, store_typeM})
    );

    /*****************
    * Writeback stage
    *****************/
    floprc #(3) regW (
        .clk(clk),
        .reset(reset),
        .d({reg_writeM, result_srcM}),
        .q({reg_writeW, result_srcW})
    );
    
endmodule