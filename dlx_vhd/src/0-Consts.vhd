--------------------------------------------------------------------------------
-- FILE: Consts
-- DESC: Define all constants.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package Consts is
	constant C_SYS_DATA_SIZE 	: integer	:= 32;			-- Data size
	constant C_SYS_ISTR_SIZE	: integer	:= 32;			-- Instruction size
	constant C_SYS_ADDR_SIZE	: integer	:= 32;			-- Address size
	constant C_SYS_CWRD_SIZE	: integer	:= 15;			-- Control Word size
	constant C_SYS_CALU_SIZE	: integer	:= 2;			-- ALU control word size
	constant C_SYS_OPCD_SIZE	: integer	:= 6;			-- Operation code size
	constant C_SYS_FUNC_SIZE	: integer	:= 11;			-- Function code size
	constant C_SYS_IMME_SIZE	: integer	:= 26;			-- Immediate value size
	constant C_CTR_CALU_SIZE	: integer	:= 5;			-- ALU Operation Code size
	constant C_CTR_DRCW_SIZE	: integer	:= 1;			-- Data Memory Control word size
	constant C_ADD_SPARSITY		: integer	:= 4;			-- Sparsity of Adder carray generator
	constant C_REG_NUM			: integer	:= 32;			-- Number of Register in Register File
	constant C_REG_GLOBAL_NUM	: integer	:= 8;			-- Number of Global register in register file
	constant C_REG_GENERAL_NUM	: integer	:= 8;			-- Number of General registers (I/L/O) in register file
	constant C_REG_WINDOW_NUM	: integer	:= 8;			-- Number of Windows in register file
	
	-- ALU Operations
	constant OP_ADD		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "00000";
	constant OP_AND		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "00001";
	constant OP_OR		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "00010";
	constant OP_XOR		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "00011";
	constant OP_SLL		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "00100";
	constant OP_SRL		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "00101";
	constant OP_SRA		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "00111";
	constant OP_SUB		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "10000";
	constant OP_SGT		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "10001";
	constant OP_SGE		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "10010";
	constant OP_SLT		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "10011";
	constant OP_SLE		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "10100";
	constant OP_SGTU	: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "10101";
	constant OP_SGEU	: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "10110";
	constant OP_SLTU	: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "10111";
	constant OP_SLEU	: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "11000";
	constant OP_SEQ		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "11001";
	constant OP_SNE		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "11010";
	
	-- Control Word
	constant CW_S1_LATCH	: integer := 0;
	constant CW_S2_LATCH	: integer := 1;
	constant CW_S2_JUMP		: integer := 2;
	constant CW_S2_J_ABS	: integer := 3;
	constant CW_S3_SEL_A_0	: integer := 4;
	constant CW_S3_SEL_A_1	: integer := 5;
	constant CW_S3_SEL_B_0	: integer := 6;
	constant CW_S3_SEL_B_1	: integer := 7;
	constant CW_S3_LATCH	: integer := 8;
	constant CW_S3_EQ_COND	: integer := 9;
	constant CW_S4_WR_DRAM	: integer := 10;
	constant CW_S4_LATCH	: integer := 11;
	constant CW_S4_JUMP		: integer := 12;
	constant CW_S4_SEL_WB	: integer := 13;
	constant CW_S5_EN_WB	: integer := 14;
	
	
end package Consts;
