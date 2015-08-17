--------------------------------------------------------------------------------
-- FILE: Consts
-- DESC: Define all constants.
--
-- Author:
-- Create: 2015-05-20
-- Update: 2015-06-05
-- Status: TESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package Consts is
	constant C_SYS_DATA_SIZE 	: integer	:= 32;			-- Data size
	constant C_SYS_ISTR_SIZE	: integer	:= 32;			-- Instruction size
	constant C_SYS_ADDR_SIZE	: integer	:= 32;			-- Address size
	constant C_SYS_CWRD_SIZE	: integer	:= 20;			-- Control Word size
	constant C_SYS_OPCD_SIZE	: integer	:= 6;			-- Operation code size
	constant C_SYS_FUNC_SIZE	: integer	:= 11;			-- Function code size
	constant C_SYS_IMME_SIZE	: integer	:= 16;			-- Immediate value size
	constant C_CTR_CALU_SIZE	: integer	:= 5;			-- ALU Operation Code size
	constant C_CTR_DRCW_SIZE	: integer	:= 4;			-- Data Memory Control word size
	constant C_ADD_SPARSITY		: integer	:= 4;			-- Sparsity of Adder carray generator
	constant C_MUL_STAGE		: integer	:= 4;			-- Stage of multiply operation
	constant C_DIV_STAGE		: integer	:= 4;			-- Stage of division operation
	constant C_REG_NUM			: integer	:= 32;			-- Number of Register in Register File
	constant C_REG_GLOBAL_NUM	: integer	:= 8;			-- Number of Global register in register file
	constant C_REG_GENERAL_NUM	: integer	:= 8;			-- Number of General registers (I/L/O) in register file
	constant C_REG_WINDOW_NUM	: integer	:= 8;			-- Number of Windows in register file
	constant C_RAM_IRAM_SIZE	: integer	:= 10240;		-- IRAM size
	constant C_RAM_DRAM_SIZE	: integer	:= 10240;		-- DRAM size
	
	-- ALU Operations
	constant OP_ADD		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "00000";	--0x00
	constant OP_AND		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "00001";	--0x01
	constant OP_OR		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "00010";	--0x02
	constant OP_XOR		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "00011";	--0x03
	constant OP_SLL		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "00100";	--0x04
	constant OP_SRL		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "00101";	--0x05
	constant OP_SRA		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "00111";	--0x07
	constant OP_MULT	: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "01000";	--0x08
	constant OP_DIV		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "01010";	--0x0a
	constant OP_SUB		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "10000";	--0x10
	constant OP_SGT		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "10001";	--0x11
	constant OP_SGE		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "10010";	--0x12
	constant OP_SLT		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "10011";	--0x13
	constant OP_SLE		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "10100";	--0x14
	constant OP_SGTU	: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "10101";	--0x15
	constant OP_SGEU	: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "10110";	--0x16
	constant OP_SLTU	: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "10111";	--0x17
	constant OP_SLEU	: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "11000";	--0x18
	constant OP_SEQ		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "11001";	--0x19
	constant OP_SNE		: std_logic_vector(C_CTR_CALU_SIZE-1 downto 0) := "11010";	--0x1a
	
	-- Control Word
	constant CW_S1_LATCH	: integer := 0;
	constant CW_S2_JUMP		: integer := 1;		-- JUMP HAPPENS ?
	constant CW_S2_SEL_JA_0	: integer := 2;		-- ADDR0 = NPC + EXT_I or ADDR = NPC + EXT_J ?
	constant CW_S2_SEL_JA_1	: integer := 3;		-- ADDR1 = ADDR0 or ADD1 = REG_A ?
	constant CW_S2_LINK		: integer := 4;
	constant CW_S2_EXT_S	: integer := 5;
	constant CW_S2_LATCH	: integer := 6;
	constant CW_S3_SEL_B	: integer := 7;
	constant CW_S3_LD_FLAG	: integer := 8;
	constant CW_S3_WB_FLAG	: integer := 9;
	constant CW_S3_LATCH	: integer := 10;
	constant CW_S4_DRAM_T_0	: integer := 11;
	constant CW_S4_DRAM_T_1	: integer := 12;
	constant CW_S4_DRAM_T_2	: integer := 13;
	constant CW_S4_DRAM_WR	: integer := 14;
	constant CW_S4_SEL_WB	: integer := 15;
	constant CW_S4_LD_FLAG	: integer := 16;
	constant CW_S4_WB_FLAG	: integer := 17;
	constant CW_S4_LATCH	: integer := 18;
	constant CW_S5_EN_WB	: integer := 19;
	
	-- Instructions -- OpCode
	constant OPCD_R		: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "000000";	--0x00
	constant OPCD_F		: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "000001";	--0x01
	constant OPCD_J		: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "000010";	--0x02
	constant OPCD_JAL	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "000011";	--0x03
	constant OPCD_BEQZ	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "000100";	--0x04
	constant OPCD_BNEZ	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "000101";	--0x05
	constant OPCD_ADDI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "001000";	--0x08
	constant OPCD_ADDUI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "001001";	--0x09
	constant OPCD_SUBI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "001010";	--0x0a
	constant OPCD_SUBUI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "001011";	--0x0b
	constant OPCD_ANDI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "001100";	--0x0c
	constant OPCD_ORI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "001101";	--0x0d
	constant OPCD_XORI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "001110";	--0x0e
	constant OPCD_LHI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "001110";	--0x0f
	constant OPCD_JR	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "010010";	--0x12
	constant OPCD_JALR	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "010011";	--0x13
	constant OPCD_SLLI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "010100";	--0x14
	constant OPCD_NOP	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "010101";	--0x15
	constant OPCD_SRLI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "010110";	--0x16
	constant OPCD_SRAI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "010111";	--0x17
	constant OPCD_SEQI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "011000";	--0x18
	constant OPCD_SNEI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "011001";	--0x19
	constant OPCD_SLTI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "011010";	--0x1a
	constant OPCD_SGTI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "011011";	--0x1b
	constant OPCD_SLEI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "011100";	--0x1c
	constant OPCD_SGEI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "011101";	--0x1d
	constant OPCD_LB	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "100000"; --0x20
	constant OPCD_LH	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "100001"; --0x21
	constant OPCD_LW	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "100011"; --0x23
	constant OPCD_LBU	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "100100"; --0x24
	constant OPCD_LHU	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "100101"; --0x25
	constant OPCD_SB	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "101000"; --0x28
	constant OPCD_SH	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "101001"; --0x29
	constant OPCD_SW	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "101011"; --0x2b
	constant OPCD_SLTUI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "111010";	--0x3a
	constant OPCD_SGTUI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "111011";	--0x3b
	constant OPCD_SLEUI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "111100";	--0x3c
	constant OPCD_SGEUI	: std_logic_vector(C_SYS_OPCD_SIZE-1 downto 0) := "111101";	--0x3d
	
	-- Instructions --FUNC
	constant FUNC_SLL	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000000100";	--0x04
	constant FUNC_SRL	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000000110";	--0x06
	constant FUNC_SRA	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000000111";	--0x07
	constant FUNC_MULT	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000001110";	--0x0e
	constant FUNC_DIV	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000001111";	--0x0f
	constant FUNC_ADD	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000100000";	--0x20
	constant FUNC_ADDU	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000100001";	--0x21
	constant FUNC_SUB	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000100010";	--0x22
	constant FUNC_SUBU	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000100011";	--0x23
	constant FUNC_AND	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000100100";	--0x24
	constant FUNC_OR	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000100101";	--0x25
	constant FUNC_XOR	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000100110";	--0x26
	constant FUNC_SEQ	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000101000";	--0x28
	constant FUNC_SNE	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000101001";	--0x29
	constant FUNC_SLT	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000101010";	--0x2a
	constant FUNC_SGT	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000101011";	--0x2b
	constant FUNC_SLE	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000101100";	--0x2c
	constant FUNC_SGE	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000101101";	--0x2d
	constant FUNC_SLTU	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000111010";	--0x3a
	constant FUNC_SGTU	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000111011";	--0x3b
	constant FUNC_SLEU	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000111100";	--0x3c
	constant FUNC_SGEU	: std_logic_vector(C_SYS_FUNC_SIZE-1 downto 0) := "00000111101";	--0x3d
	
	-- STALL GENERATOR STATES
	constant SG_ST00000	: integer := 0;		-- STALL NONE
	constant SG_ST00001	: integer := 1;		-- STALL STAGE 1
	constant SG_ST00010	: integer := 2;		-- STALL STAGE 2
	constant SG_ST00011	: integer := 3;		-- STALL STAGE 1,2
	constant SG_ST00100	: integer := 4;		-- STALL STAGE 3
	constant SG_ST00101	: integer := 5;		-- STALL STAGE 1,3
	constant SG_ST00110	: integer := 6;		-- STALL STAGE 2,3
	constant SG_ST00111	: integer := 7;		-- STALL STAGE 1,2,3
	constant SG_ST01000	: integer := 8;		-- STALL STAGE 4
	constant SG_ST01001	: integer := 9;		-- STALL STAGE 1,4
	constant SG_ST01010	: integer := 10;	-- STALL STAGE 2,4
	constant SG_ST01011	: integer := 11;	-- STALL STAGE 1,2,4
	constant SG_ST01100	: integer := 12;	-- STALL STAGE 3,4
	constant SG_ST01101	: integer := 13;	-- STALL STAGE 1,3,4
	constant SG_ST01110	: integer := 14;	-- STALL STAGE 2,3,4
	constant SG_ST01111	: integer := 15;	-- STALL STAGE 1,2,3,4
	constant SG_ST10000	: integer := 16;	-- STALL STAGE 5
	constant SG_ST10001	: integer := 17;	-- STALL STAGE 1,5
	constant SG_ST10010	: integer := 18;	-- STALL STAGE 2,5
	constant SG_ST10011	: integer := 19;	-- STALL STAGE 1,2,5
	constant SG_ST10100	: integer := 20;	-- STALL STAGE 3,5
	constant SG_ST10101	: integer := 21;	-- STALL STAGE 1,3,5
	constant SG_ST10110	: integer := 22;	-- STALL STAGE 2,3,5
	constant SG_ST10111	: integer := 23;	-- STALL STAGE 1,2,3,5
	constant SG_ST11000	: integer := 24;	-- STALL STAGE 4,5
	constant SG_ST11001	: integer := 25;	-- STALL STAGE 1,4,5
	constant SG_ST11010	: integer := 26;	-- STALL STAGE 2,4,5
	constant SG_ST11011	: integer := 27;	-- STALL STAGE 1,2,4,5
	constant SG_ST11100	: integer := 28;	-- STALL STAGE 3,4,5
	constant SG_ST11101	: integer := 29;	-- STALL STAGE 1,3,4,5
	constant SG_ST11110	: integer := 30;	-- STALL STAGE 2,3,4,5
	constant SG_ST11111	: integer := 31;	-- STALL STAGE 1,2,3,4,5
	
	constant SG_ST0		: integer := 0;
	constant SG_ST1		: integer := 1;
	constant SG_ST2		: integer := 2;
	constant SG_ST3		: integer := 3;
	constant SG_ST4		: integer := 4;
	constant SG_ST5		: integer := 5;
	
	
end package Consts;
