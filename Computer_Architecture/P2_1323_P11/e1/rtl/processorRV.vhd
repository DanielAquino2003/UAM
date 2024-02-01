--------------------------------------------------------------------------------
-- Procesador RISC V Segmentado curso Arquitectura Ordenadores 2023
-- Initial Release G.Sutter jun 2022. Last Rev. sep2023
-- Daniel Aquino
-- Jorge Paniagua
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.RISCV_pack.ALL;

ENTITY processorRV IS
  PORT (
    Clk : IN STD_LOGIC; -- Reloj activo en flanco subida
    Reset : IN STD_LOGIC; -- Reset asincrono activo nivel alto
    -- Instruction memory
    IAddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Direccion Instr
    IDataIn : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Instruccion leida
    -- Data memory
    DAddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Direccion
    DRdEn : OUT STD_LOGIC; -- Habilitacion lectura
    DWrEn : OUT STD_LOGIC; -- Habilitacion escritura
    DDataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Dato escrito
    DDataIn : IN STD_LOGIC_VECTOR(31 DOWNTO 0) -- Dato leido
  );
END processorRV;

ARCHITECTURE rtl OF processorRV IS

  COMPONENT alu_RV
    PORT (
      OpA : IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- Operando A
      OpB : IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- Operando B
      Control : IN STD_LOGIC_VECTOR (3 DOWNTO 0); -- Codigo de control=op. a ejecutar
      Result : OUT STD_LOGIC_VECTOR (31 DOWNTO 0); -- Resultado
      SignFlag : OUT STD_LOGIC; -- Sign Flag
      CarryOut : OUT STD_LOGIC; -- Carry bit
      ZFlag : OUT STD_LOGIC -- Flag Z
    );
  END COMPONENT;

  COMPONENT reg_bank
    PORT (
      Clk : IN STD_LOGIC; -- Reloj activo en flanco de subida
      Reset : IN STD_LOGIC; -- Reset asincrono a nivel alto
      A1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Direccion para el primer registro fuente (rs1)
      Rd1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Dato del primer registro fuente (rs1)
      A2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Direccion para el segundo registro fuente (rs2)
      Rd2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Dato del segundo registro fuente (rs2)
      A3 : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Direccion para el registro destino (rd)
      Wd3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Dato de entrada para el registro destino (rd)
      We3 : IN STD_LOGIC -- Habilitacion de la escritura de Wd3 (rd)
    );
  END COMPONENT reg_bank;

  COMPONENT control_unit
    PORT (
      -- Entrada = codigo de operacion en la instruccion:
      OpCode : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
      -- Seniales para el PC
      Branch : OUT STD_LOGIC; -- 1 = Ejecutandose instruccion branch
      Ins_Jal : OUT STD_LOGIC; -- 1 = jal , 0 = otra instruccion, 
      Ins_Jalr : OUT STD_LOGIC; -- 1 = jalr, 0 = otra instruccion, 
      -- Seniales relativas a la memoria y seleccion dato escritura registros
      ResultSrc : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- 00 salida Alu; 01 = salida de la mem.; 10 PC_plus4
      MemWrite : OUT STD_LOGIC; -- Escribir la memoria
      MemRead : OUT STD_LOGIC; -- Leer la memoria
      -- Seniales para la ALU
      ALUSrc : OUT STD_LOGIC; -- 0 = oper.B es registro, 1 = es valor inm.
      AuipcLui : OUT STD_LOGIC_VECTOR (1 DOWNTO 0); -- 0 = PC. 1 = zeros, 2 = reg1.
      ALUOp : OUT STD_LOGIC_VECTOR (2 DOWNTO 0); -- Tipo operacion para control de la ALU
      -- Seniales para el GPR
      RegWrite : OUT STD_LOGIC -- 1 = Escribir registro
    );
  END COMPONENT;

  COMPONENT alu_control IS
    PORT (
      -- Entradas:
      ALUOp : IN STD_LOGIC_VECTOR (2 DOWNTO 0); -- Codigo de control desde la unidad de control
      Funct3 : IN STD_LOGIC_VECTOR (2 DOWNTO 0); -- Campo "funct3" de la instruccion (I(14:12))
      Funct7 : IN STD_LOGIC_VECTOR (6 DOWNTO 0); -- Campo "funct7" de la instruccion (I(31:25))     
      -- Salida de control para la ALU:
      ALUControl : OUT STD_LOGIC_VECTOR (3 DOWNTO 0) -- Define operacion a ejecutar por la ALU
    );
  END COMPONENT alu_control;

  COMPONENT Imm_Gen IS
    PORT (
      instr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      imm : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
  END COMPONENT Imm_Gen;

  SIGNAL Alu_Op1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL Alu_Op2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL Alu_ZERO : STD_LOGIC;
  SIGNAL Alu_SIGN : STD_LOGIC;
  SIGNAL AluControl : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL reg_RD_data : STD_LOGIC_VECTOR(31 DOWNTO 0);

  SIGNAL branch_true : STD_LOGIC;
  SIGNAL PC_next : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL PC_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL PC_plus4 : STD_LOGIC_VECTOR(31 DOWNTO 0);

  SIGNAL Instruction : STD_LOGIC_VECTOR(31 DOWNTO 0); -- La instrucción desde lamem de instr
  SIGNAL Imm_ext : STD_LOGIC_VECTOR(31 DOWNTO 0); -- La parte baja de la instrucción extendida de signo
  SIGNAL reg_RS1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL reg_RS2 : STD_LOGIC_VECTOR(31 DOWNTO 0);

  SIGNAL dataIn_Mem : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Dato desde memoria
  SIGNAL Addr_BranchJal : STD_LOGIC_VECTOR(31 DOWNTO 0);

  SIGNAL Ctrl_Jal, Ctrl_Jalr, Ctrl_Branch, Ctrl_MemWrite, Ctrl_MemRead, Ctrl_ALUSrc, Ctrl_RegWrite : STD_LOGIC;

  SIGNAL Ctrl_ALUOp : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL Ctrl_PcLui : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL Ctrl_ResSrc : STD_LOGIC_VECTOR(1 DOWNTO 0);

  SIGNAL Addr_Jalr : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL Addr_Jump_dest : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL decision_Jump : STD_LOGIC;
  SIGNAL Alu_Res : STD_LOGIC_VECTOR(31 DOWNTO 0);
  -- Instruction fields:
  SIGNAL Funct3 : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL Funct7 : STD_LOGIC_VECTOR(6 DOWNTO 0);
  SIGNAL RS1, RS2, RD : STD_LOGIC_VECTOR(4 DOWNTO 0);

  -- SEÑALES NUEVAS
  SIGNAL PC_IF : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL PC_plus4_IF : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL instruccion_IF : STD_LOGIC_VECTOR(31 DOWNTO 0);

  -- IF/ID
  SIGNAL PC_ID : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL PC_plus4_ID : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL instruccion_ID : STD_LOGIC_VECTOR(31 DOWNTO 0);

  -- ID/EX
  SIGNAL PC_EX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL PC_plus4_EX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL reg_RS1_EX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL reg_RS2_EX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL Ctrl_Jal_EX : STD_LOGIC;
  SIGNAL Ctrl_Jalr_EX : STD_LOGIC;
  SIGNAL Ctrl_Branch_EX : STD_LOGIC;
  SIGNAL Ctrl_ResSrc_EX : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL Ctrl_MemWrite_EX : STD_LOGIC;
  SIGNAL Ctrl_MemRead_EX : STD_LOGIC;
  SIGNAL Ctrl_AluSrc_EX : STD_LOGIC;
  SIGNAL Ctrl_PcLui_EX : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL Ctrl_ALUOp_EX : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL Ctrl_RegWrite_EX : STD_LOGIC;
  SIGNAL funct3_EX : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL Imm_ext_EX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL instruccion_EX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL REG_RD_EX : STD_LOGIC_VECTOR(31 DOWNTO 0);

  -- EX/MEM
  SIGNAL PC_MEM : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL PC_plus4_MEM : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL reg_RS2_MEM : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL Addr_Jump_dest_MEM : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL funct3_MEM : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL RD_MEM : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL Ctrl_Jal_MEM : STD_LOGIC;
  SIGNAL Ctrl_Jalr_MEM : STD_LOGIC;
  SIGNAL Ctrl_Branch_MEM : STD_LOGIC;
  SIGNAL Ctrl_MemWrite_MEM : STD_LOGIC;
  SIGNAL Ctrl_MemRead_MEM : STD_LOGIC;
  SIGNAL Ctrl_AluSrc_MEM : STD_LOGIC;
  SIGNAL Ctrl_PcLui_MEM : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL Ctrl_ALUOp_MEM : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL Ctrl_RegWrite_MEM : STD_LOGIC;
  SIGNAL Ctrl_ResSrc_MEM : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL Alu_Res_MEM : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL REG_RD_MEM : STD_LOGIC_VECTOR(31 DOWNTO 0);

  -- MEM/WB
  SIGNAL PC_plus4_WB : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL Ctrl_ResSrc_WB : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL REG_RD_WB : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL Ctrl_RegWrite_WB : STD_LOGIC;
  SIGNAL RD_WB : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL Alu_Res_WB : STD_LOGIC_VECTOR(31 DOWNTO 0);

  --FORWARDING UNIT
  SIGNAL MuxFU1 : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL MuxFU2 : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL ResMuxFU1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL ResMuxFU2 : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
  PC_next <= Addr_Jump_dest WHEN decision_Jump = '1' ELSE
    PC_plus4;

  -- Program Counter+
  PC_reg_proc : PROCESS (Clk, Reset)
  BEGIN
    IF Reset = '1' THEN
      PC_reg <= (22 => '1', OTHERS => '0'); -- 0040_0000
    ELSIF rising_edge(Clk) THEN
      PC_reg <= PC_next;
    END IF;
  END PROCESS;

  PC_plus4 <= PC_reg + 4;
  IAddr <= PC_reg;
  Instruction <= IDataIn;
  Funct3 <= instruction(14 DOWNTO 12); -- Campo "funct3" de la instruccion
  Funct7 <= instruction(31 DOWNTO 25); -- Campo "funct7" de la instruccion
  RD <= Instruction(11 DOWNTO 7);
  RS1 <= Instruction(19 DOWNTO 15);
  RS2 <= Instruction(24 DOWNTO 20);

  ------------------------------------------------------------
  -- IF STAGE
  IF_STAGE : PROCESS (Clk, Reset)
  BEGIN
    IF Reset = '1' THEN
      PC_IF <= (OTHERS => '0');
      PC_plus4_IF <= (OTHERS => '0');
      instruccion_IF <= (OTHERS => '0');
    ELSIF rising_edge(Clk) THEN
      PC_IF <= PC_reg;
      instruccion_IF <= Instruction;
      PC_plus4_IF <= PC_plus4;
    END IF;
  END PROCESS;
  ------------------------------------------------------------
  -- PIPELINE IF/ID
  IF_ID_REG : PROCESS (Clk, Reset)
  BEGIN
    IF Reset = '1' THEN
      PC_ID <= (OTHERS => '0');
      instruccion_ID <= (OTHERS => '0');
      PC_plus4_ID <= (OTHERS => '0');
    ELSIF rising_edge(Clk) THEN
      PC_ID <= PC_IF;
      instruccion_ID <= instruccion_IF;
      PC_plus4_ID <= PC_plus4_IF;
    END IF;
  END PROCESS;
  ------------------------------------------------------------
  -- ID STAGE
  ------------------------------------------------------------
  -- PIPELINE ID/EX
  ID_EX_REG : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      PC_EX <= (OTHERS => '0');
      reg_RS1_EX <= (OTHERS => '0');
      reg_RS2_EX <= (OTHERS => '0');
      funct3_EX <= (OTHERS => '0');
      Ctrl_Jal_EX <= '0';
      Ctrl_Jalr_EX <= '0';
      Ctrl_Branch_EX <= '0';
      Ctrl_MemWrite_EX <= '0';
      Ctrl_MemRead_EX <= '0';
      Ctrl_ALUSrc_EX <= '0';
      Ctrl_PcLui_EX <= "00";
      Ctrl_ALUOp_EX <= "000";
      Ctrl_RegWrite_EX <= '0';
      Ctrl_ResSrc_EX <= "00";
      Imm_ext_EX <= (OTHERS => '0');
      instruccion_EX <= (OTHERS => '0');
      PC_plus4_EX <= (OTHERS => '0');
    ELSIF rising_edge(clk) THEN
      Imm_ext_EX <= Imm_ext;
      funct3_EX <= instruccion_ID(14 DOWNTO 12);
      Ctrl_Jal_EX <= Ctrl_Jal;
      Ctrl_Jalr_EX <= Ctrl_Jalr;
      Ctrl_Branch_EX <= Ctrl_Branch;
      Ctrl_MemWrite_EX <= Ctrl_MemWrite;
      Ctrl_MemRead_EX <= Ctrl_MemRead;
      Ctrl_ALUSrc_EX <= Ctrl_ALUSrc;
      Ctrl_PcLui_EX <= Ctrl_PcLui;
      Ctrl_ALUOp_EX <= Ctrl_ALUOp;
      Ctrl_RegWrite_EX <= Ctrl_RegWrite;
      Ctrl_ResSrc_EX <= Ctrl_ResSrc;
      PC_EX <= PC_ID;
      reg_RS1_EX <= ResMuxFU1 WHEN (MuxFU1 = "10" OR MuxFU1 = "01") ELSE
        reg_RS1;
      reg_RS2_EX <= ResMuxFU2 WHEN (MuxFU2 = "10" OR MuxFU2 = "01") ELSE
        reg_RS2;
      instruccion_EX <= instruccion_ID;
      PC_plus4_EX <= PC_plus4_ID;
    END IF;
  END PROCESS;
  -------------------------------------------------------------
  -- EX STAGE
  -------------------------------------------------------------
  -- PIPELINE EX/MEM
  EX_MEM_REG : PROCESS (Clk, Reset)
  BEGIN
    IF Reset = '1' THEN
      PC_MEM <= (OTHERS => '0');
      reg_RS2_MEM <= (OTHERS => '0');
      Addr_Jump_dest_MEM <= (OTHERS => '0');
      funct3_MEM <= (OTHERS => '0');
      RD_MEM <= (OTHERS => '0');
      Ctrl_Jal_MEM <= '0';
      Ctrl_Jalr_MEM <= '0';
      Ctrl_Branch_MEM <= '0';
      Ctrl_MemWrite_MEM <= '0';
      Ctrl_MemRead_MEM <= '0';
      Ctrl_ALUSrc_MEM <= '0';
      Ctrl_PcLui_MEM <= "00";
      Ctrl_ALUOp_MEM <= "000";
      Ctrl_RegWrite_MEM <= '0';
      Ctrl_ResSrc_MEM <= "00";
      Alu_Res_MEM <= (OTHERS => '0');
      PC_plus4_MEM <= (OTHERS => '0');
      REG_RD_MEM <= (OTHERS => '0');
    ELSIF rising_edge(Clk) THEN
      PC_MEM <= PC_EX;
      reg_RS2_MEM <= reg_RS2_EX;
      Addr_Jump_dest_MEM <= Addr_Jump_dest;
      funct3_MEM <= funct3_EX;
      RD_MEM <= instruccion_EX(11 DOWNTO 7);
      Ctrl_Jal_MEM <= Ctrl_Jal_EX;
      Ctrl_Jalr_MEM <= Ctrl_Jalr_EX;
      Ctrl_Branch_MEM <= Ctrl_Branch_EX;
      Ctrl_MemWrite_MEM <= Ctrl_MemWrite_EX;
      Ctrl_MemRead_MEM <= Ctrl_MemRead_EX;
      Ctrl_ALUSrc_MEM <= Ctrl_ALUSrc_EX;
      Ctrl_PcLui_MEM <= Ctrl_PcLui_EX;
      Ctrl_ALUOp_MEM <= Ctrl_ALUOp_EX;
      Ctrl_RegWrite_MEM <= Ctrl_RegWrite_EX;
      Ctrl_ResSrc_MEM <= Ctrl_ResSrc_EX;
      Alu_Res_MEM <= Alu_Res;
      PC_plus4_MEM <= PC_plus4_EX;
      REG_RD_MEM <= REG_RD_EX;
      IF Ctrl_RegWrite_MEM = '1' THEN
        IF (RD_MEM /= "00000" AND (RD_MEM = instruccion_EX(19 DOWNTO 15))) THEN
          MuxFU1 <= "10";
          ResMuxFU1 <= Alu_Res_MEM;
        ELSIF (RD_MEM /= "00000" AND (RD_MEM = instruccion_EX(24 DOWNTO 20))) THEN
          MuxFU2 <= "10";
          ResMuxFU2 <= Alu_Res_MEM;
        END IF;
      END IF;
    END IF;
  END PROCESS;
  -------------------------------------------------------------
  ----MEM STAGE
  -------------------------------------------------------------
  -- PIPELINE MEM/WB
  MEM_WB_reg : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      Ctrl_ResSrc_WB <= "00";
      REG_RD_WB <= (OTHERS => '0');
      Ctrl_RegWrite_WB <= '0';
      RD_WB <= (OTHERS => '0');
      Alu_Res_WB <= (OTHERS => '0');
      PC_plus4_WB <= (OTHERS => '0');
    ELSIF rising_edge(clk) THEN
      Ctrl_ResSrc_WB <= Ctrl_ResSrc_MEM;
      REG_RD_WB <= REG_RD_MEM;
      Ctrl_RegWrite_WB <= Ctrl_RegWrite_MEM;
      RD_WB <= RD_MEM;
      Alu_Res_WB <= Alu_Res_MEM;
      PC_plus4_WB <= PC_plus4_MEM;
      IF (Ctrl_RegWrite_WB = '1'
        AND (RD_WB /= "00000")
        AND NOT(Ctrl_RegWrite_MEM = '1' AND (RD_MEM /= "00000")
        AND (RD_MEM /= RS1))
        AND (RD_WB = RS1)) THEN MuxFU1 <= "01";
      ELSIF (Ctrl_RegWrite_WB = '1'
        AND (RD_WB /= "00000")
        AND NOT(Ctrl_RegWrite_MEM = '1' AND (RD_MEM /= "00000")
        AND (RD_MEM /= RS2))
        AND (RD_WB = RS2)) THEN MuxFU2 <= "01";
      END IF;
    END IF;
  END PROCESS;
    ------------------------------------------------------------

    RegsRISCV : reg_bank
    PORT MAP(
      Clk => Clk,
      Reset => Reset,
      A1 => RS1, --Instruction(19 downto 15), --rs1
      Rd1 => reg_RS1,
      A2 => RS2, --Instruction(24 downto 20), --rs2
      Rd2 => reg_RS2,
      A3 => RD, --Instruction(11 downto 7),,
      Wd3 => reg_RD_data,
      We3 => Ctrl_RegWrite
    );

    UnidadControl : control_unit
    PORT MAP(
      OpCode => Instruction(6 DOWNTO 0),
      -- Señales para el PC
      Branch => Ctrl_Branch,
      Ins_Jal => Ctrl_Jal,
      Ins_Jalr => Ctrl_Jalr,
      -- Señales para la memoria y seleccion dato escritura registros
      ResultSrc => Ctrl_ResSrc,
      MemWrite => Ctrl_MemWrite,
      MemRead => Ctrl_MemRead,
      -- Señales para la ALU
      ALUSrc => Ctrl_ALUSrc,
      AuipcLui => Ctrl_PcLui,
      ALUOp => Ctrl_ALUOp,
      -- Señales para el GPR
      RegWrite => Ctrl_RegWrite
    );

    immed_op : Imm_Gen
    PORT MAP(
      instr => Instruction,
      imm => Imm_ext
    );

    Addr_BranchJal <= PC_reg + Imm_ext;
    Addr_Jalr <= reg_RS1 + Imm_ext;

    decision_Jump <= Ctrl_Jal OR Ctrl_Jalr OR (Ctrl_Branch AND branch_true);
    branch_true <= '1' WHEN (((Funct3 = BR_F3_BEQ) AND (Alu_ZERO = '1')) OR
      ((Funct3 = BR_F3_BNE) AND (Alu_ZERO = '0')) OR
      ((Funct3 = BR_F3_BLT) AND (Alu_SIGN = '1')) OR
      ((Funct3 = BR_F3_BGE) AND (Alu_SIGN = '0'))) ELSE
      '0';

    Addr_Jump_dest <= Addr_Jalr WHEN Ctrl_Jalr = '1' ELSE
      Addr_BranchJal WHEN (Ctrl_Branch = '1') OR (Ctrl_Jal = '1') ELSE
      (OTHERS => '0');

    Alu_control_i : alu_control
    PORT MAP(
      -- Entradas:
      ALUOp => Ctrl_ALUOp, -- Codigo de control desde la unidad de control
      Funct3 => Funct3, -- Campo "funct3" de la instruccion
      Funct7 => Funct7, -- Campo "funct7" de la instruccion
      -- Salida de control para la ALU:
      ALUControl => AluControl -- Define operacion a ejecutar por la ALU
    );

    Alu_RISCV : alu_RV
    PORT MAP(
      OpA => Alu_Op1,
      OpB => Alu_Op2,
      Control => AluControl,
      Result => Alu_Res,
      Signflag => Alu_SIGN,
      CarryOut => OPEN,
      Zflag => Alu_ZERO
    );

    Alu_Op1 <= PC_reg WHEN Ctrl_PcLui = "00" ELSE
      (OTHERS => '0') WHEN Ctrl_PcLui = "01" ELSE
      reg_RS1; -- any other 
    Alu_Op2 <= reg_RS2 WHEN Ctrl_ALUSrc = '0' ELSE
      Imm_ext;
    DAddr <= Alu_Res;
    DDataOut <= reg_RS2;
    DWrEn <= Ctrl_MemWrite;
    DRdEn <= Ctrl_MemRead;
    dataIn_Mem <= DDataIn;

    reg_RD_data <= dataIn_Mem WHEN Ctrl_ResSrc = "01" ELSE
      PC_plus4 WHEN Ctrl_ResSrc = "10" ELSE
      Alu_Res; -- When 00

  END ARCHITECTURE;