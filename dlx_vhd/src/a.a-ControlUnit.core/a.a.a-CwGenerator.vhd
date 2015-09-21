--------------------------------------------------------------------------------
-- FILE: CwGenerator
-- DESC: Generate Control Word
--
-- Author:
-- Create: 2015-05-30
-- Update: 2015-09-02
-- Status: TESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Consts.all;
use work.Funcs.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity CwGenerator is
	generic (
		DATA_SIZE	: integer := C_SYS_DATA_SIZE;			-- Data Size
		OPCD_SIZE	: integer := C_SYS_OPCD_SIZE;			-- Op Code Size
		FUNC_SIZE	: integer := C_SYS_FUNC_SIZE;			-- Func Field Size for R-Type Ops
		CWRD_SIZE	: integer := C_SYS_CWRD_SIZE;			-- Control Word Size
		CALU_SIZE	: integer := C_CTR_CALU_SIZE			-- ALU Op Code Word Size
	);
	port (
		clk		: in std_logic;
		rst		: in std_logic;
		opcd	: in std_logic_vector(OPCD_SIZE-1 downto 0):=(others=>'0');
		func	: in std_logic_vector(FUNC_SIZE-1 downto 0):=(others=>'0');
		stall_flag	: in std_logic_vector(4 downto 0):=(others=>'0');
		taken	: in std_logic;
		cw		: out std_logic_vector(CWRD_SIZE-1 downto 0):=(others=>'0');
		calu	: out std_logic_vector(CALU_SIZE-1 downto 0):=(others=>'0')
	);
end CwGenerator;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture cw_generator_arch of CwGenerator is
	constant PIPELINE_STAGE: integer := 5;
	--constant UCODE_MEM_SIZE : integer := 2**OPCD_SIZE;
	constant UCODE_MEM_SIZE : integer := 69;
	constant RELOC_MEM_SIZE : integer := 64;
	type ucode_mem_t is array (0 to UCODE_MEM_SIZE-1) of std_logic_vector(CWRD_SIZE-1 downto 0);
	type reloc_mem_t is array (0 to RELOC_MEM_SIZE-1) of std_logic_vector(OPCD_SIZE+1 downto 0);	-- Mul by 4, since each instruction need 4 stages, IF stage do not count. 

	signal stall1 : std_logic;
	signal stall2 : std_logic;
	signal stall3 : std_logic;
	signal stall4 : std_logic;
	signal stall5 : std_logic;
	signal reloc_mem : reloc_mem_t := (
		x"01",	-- 0x00 R
		x"01",	-- 0x01 F
		x"05",	-- 0x02 J
		x"09",	-- 0x03 JAL
		x"0d",	-- 0x04 BEQZ
		x"0d",	-- 0x05 BNEZ
		x"00",	-- 0x06 UNUSED
		x"00",	-- 0x07	UNUSED
		x"11",	-- 0x08 ADDI
		x"41",	-- 0x09 ADDUI
		x"11",	-- 0x0a SUBI
		x"41",	-- 0x0b SUBUI
		x"11",	-- 0x0c ANDI
		x"11",	-- 0x0d ORI
		x"11",	-- 0x0e XORI
		x"11",	-- 0x0f LHI
		x"00",	-- 0x10	UNUSED
		x"00",	-- 0x11 UNUSED
		x"15",	-- 0x12	JR
		x"19",	-- 0x13 JALR
		x"11",	-- 0x14 SLLI
		x"1d",	-- 0x15 NOP
		x"11",	-- 0x16 SRLI
		x"11",	-- 0x17	SRAI
		x"11",	-- 0x18 SEQI
		x"11",	-- 0x19 SNEI
		x"11",	-- 0x1a SLTI
		x"11",	-- 0x1b SGTI
		x"11",	-- 0x1c SLEI
		x"11",	-- 0x1d SGEI
		x"00",	-- 0x1e UNUSED
		x"00",	-- 0x1f UNUSED
		x"21",	-- 0x20	LB
		x"25",	-- 0x21 LH
		x"00",	-- 0x22	UNUSED
		x"29",	-- 0x23 LW
		x"2d",	-- 0x24 LBU
		x"31",	-- 0x25 LHU
		x"00",	-- 0x26 UNUSED
		x"00",	-- 0x27	UNUSED
		x"35",	-- 0x28 SB
		x"39",	-- 0x29 SH
		x"00",	-- 0x2a UNUSED
		x"3d",	-- 0x2b SW
		x"00",	-- 0x2c UNUSED
		x"00",	-- 0x2d UNUSED
		x"00",	-- 0x2e UNUSED
		x"00", 	-- 0x2f UNUSED
		x"00",	-- 0x30	UNUSED
		x"00",	-- 0x31 UNUSED
		x"00",	-- 0x32	UNUSED
		x"00",	-- 0x33 UNUSED
		x"00",	-- 0x34 UNUSED
		x"00",	-- 0x35 UNUSED
		x"00",	-- 0x36 UNUSED
		x"00",	-- 0x37	UNUSED
		x"00",	-- 0x38 UNUSED
		x"00",	-- 0x39 UNUSED
		x"41",	-- 0x3a SLTUI
		x"41",	-- 0x3b SGTUI
		x"41",	-- 0x3c SLEUI
		x"41",	-- 0x3d SGEUI
		x"00",	-- 0x3e UNUSED
		x"00" 	-- 0x3f UNUSED
	);
	signal ucode_mem : ucode_mem_t := (
		"00000000000000000000",	-- 0x00 RESET
		"00000000000001000000",	-- 0x01 R	[ID]	
		"00000000011000000000",	--		R	[EXE]
		"01100000000000000000",	--		R	[MEM]
		"10000000000000000000",	--		R	[WB]
		"00000000000001000110",	-- 0x05	J
		"00000000000000000000",
		"00000000000000000000",
		"00000000000000000000",
		"00000000000001010110",	-- 0x09	JAL
		"00000000000000000000",
		"00000000000000000000",
		"00000000000000000000",
		"00000000000001100000",	-- 0x0d	BEQZ/BENZ
		"00000000000000000000",
		"00000000000000000000",
		"00000000000000000000",
		"00000000000001100000",	-- 0x11	ADDI/...	
		"00000000011010000000",
		"01100000000000000000",
		"10000000000000000000",
		"00000000000001001010",	-- 0x15	JR
		"00000000000000000000",
		"00000000000000000000",
		"00000000000000000000",
		"00000000000001001010",	-- 0x19	JALR
		"00000000000000000000",
		"00000000000000000000",
		"00000000000000000000",
		"00000000000000000000",	-- 0x1d	NOP
		"00000000000000000000",
		"00000000000000000000",
		"00000000000000000000",
		"00000000000001000000",	-- 0x21	LB
		"00000000011110000000",
		"01111010100000000000",
		"10000000000000000000",
		"00000000000001000000",	-- 0x25	LH
		"00000000011110000000",
		"01111001100000000000",
		"10000000000000000000",
		"00000000000001000000",	-- 0x29	LW
		"00000000011110000000",
		"01111000000000000000",
		"10000000000000000000",
		"00000000000001000000",	-- 0x2d	LBU
		"00000000011110000000",
		"01111010000000000000",
		"10000000000000000000",
		"00000000000001000000",	-- 0x31	LHU
		"00000000011110000000",
		"01111001000000000000",
		"10000000000000000000",
		"00000000000001000000",	-- 0x35	SB
		"00000000010010000000",
		"01000110000000000000",
		"00000000000000000000",
		"00000000000001000000",	-- 0x39	SH
		"00000000010010000000",
		"01000101000000000000",
		"00000000000000000000",
		"00000000000001000000",	-- 0x3d	SW
		"00000000010010000000",
		"01000100000000000000",
		"00000000000000000000",
		"00000000000001000000",	-- 0x41	ADDUI/...	
		"00000000011010000000",
		"01100000000000000000",
		"10000000000000000000"
	);
	
	signal cw1 : std_logic_vector(CWRD_SIZE-1 downto 0):=(CW_S1_LATCH=>'1', others=>'0');
	signal cw2 : std_logic_vector(CWRD_SIZE-1 downto 0);
	signal cw3 : std_logic_vector(CWRD_SIZE-1 downto 0);
	signal cw4 : std_logic_vector(CWRD_SIZE-1 downto 0);
	signal cw5 : std_logic_vector(CWRD_SIZE-1 downto 0);
	signal cw_temp : std_logic_vector(CWRD_SIZE-1 downto 0);
	signal cw_mask : std_logic_vector(CWRD_SIZE-1 downto 0);

	signal upc2 : integer range 0 to 131072:=0;
	signal upc3 : integer range 0 to 131072:=0;
	signal upc4 : integer range 0 to 131072:=0;
	signal upc5 : integer range 0 to 131072:=0;
	signal i_count : integer range 0 to PIPELINE_STAGE;
	signal relc : std_logic_vector(OPCD_SIZE+1 downto 0);
	
	signal calu2 : std_logic_vector(CALU_SIZE-1 downto 0);
	
	signal taken_flag: std_logic_vector(CWRD_SIZE-1 downto 0);
  
begin
	cw1 <= (CW_S1_LATCH=>'1', others=>'0');
	cw2 <= ucode_mem(upc2);
	cw3 <= ucode_mem(upc3);
	cw4 <= ucode_mem(upc4);
	cw5 <= ucode_mem(upc5);
	
	
	stall1 <= stall_flag(4);
	stall2 <= stall_flag(3);
	stall3 <= stall_flag(2);
	stall4 <= stall_flag(1);
	stall5 <= stall_flag(0);
	cw_mask(CW_S1_LATCH downto 0) <= (others=> (not stall1));
	cw_mask(CW_S2_LATCH downto CW_S1_LATCH+1) <= (others=> (not stall2));
	cw_mask(CW_S3_LATCH downto CW_S2_LATCH+1) <= (others=> (not stall3));
	cw_mask(CW_S4_LATCH downto CW_S3_LATCH+1) <= (others=> (not stall4));
	cw_mask(CWRD_SIZE-1 downto CW_S4_LATCH+1) <= (others=> (not stall5));
	taken_flag <= (CW_S2_JUMP => taken, others=>'0');
	cw_temp <= (cw1 or cw2 or cw3 or cw4 or cw5 or taken_flag);
	cw <= cw_temp and cw_mask;
	
	relc <= reloc_mem(to_integer(unsigned(opcd)));
	
	P_CALU: process (opcd, func)
	begin
		calu2 <= (others => '0');
		if (opcd = OPCD_R) then
			if (func=FUNC_ADD) or (func=FUNC_ADDU) then		-- ADD
				calu2 <= OP_ADD;
			elsif (func=FUNC_AND) then						-- AND
				calu2 <= OP_AND;
			elsif (func=FUNC_OR) then						-- OR
				calu2 <= OP_OR;
			elsif (func=FUNC_XOR) then						-- AND
				calu2 <= OP_XOR;
			elsif (func=FUNC_SLL) then						-- SLL
				calu2 <= OP_SLL;
			elsif (func=FUNC_SRL) then						-- SRL
				calu2 <= OP_SRL;
			elsif (func=FUNC_SRA) then						-- SRA
				calu2 <= OP_SRA;
			elsif (func=FUNC_SUB) or (func=FUNC_SUBU) then	-- SUB
				calu2 <= OP_SUB;
			elsif (func = FUNC_SGT) then					-- SGT
				calu2 <= OP_SGT;
			elsif (func = FUNC_SGE) then					-- SGE
				calu2 <= OP_SGE;
			elsif (func = FUNC_SLT) then					-- SLT
				calu2 <= OP_SLT;
			elsif (func = FUNC_SLE) then					-- SLE
				calu2 <= OP_SLE;
			elsif (func = FUNC_SGTU) then					-- SGTU
				calu2 <= OP_SGTU;
			elsif (func = FUNC_SGEU) then					-- SGEU
				calu2 <= OP_SGEU;
			elsif (func = FUNC_SLTU) then					-- SLTU
				calu2 <= OP_SLTU;
			elsif (func = FUNC_SLEU) then					-- SLEU
				calu2 <= OP_SLEU;
			elsif (func = FUNC_SEQ) then					-- SEQ
				calu2 <= OP_SEQ;
			elsif (func = FUNC_SNE) then					-- SNE
				calu2 <= OP_SNE;
			else
				calu2 <= OP_ADD;
			end if;
		elsif (opcd=OPCD_F) then
			if (func=FUNC_MULTU) then						-- MULTU
				calu2 <= OP_MULTU;
			elsif (func=FUNC_MULT) then						-- MULT
				calu2 <= OP_MULT;
			elsif (func=FUNC_DIVU) then						-- DIVU
				calu2 <= OP_DIVU;
			elsif (func=FUNC_DIV) then						-- DIV
				calu2 <= OP_DIV;
			end if;
		elsif (opcd=OPCD_ADDI) or (opcd=OPCD_ADDUI) then	-- ADD
			calu2 <= OP_ADD;
		elsif (opcd=OPCD_SUBI) or (opcd=OPCD_SUBUI) then	-- SUB
			calu2 <= OP_SUB;
		elsif opcd=OPCD_ANDI then							-- AND
			calu2 <= OP_AND;
		elsif opcd=OPCD_ORI then							-- OR
			calu2 <= OP_OR;
		elsif opcd=OPCD_XORI then							-- XOR
			calu2 <= OP_XOR;
		elsif opcd=OPCD_SLLI then							-- SLL
			calu2 <= OP_SLL;
		elsif opcd=OPCD_SRLI then							-- SRL
			calu2 <= OP_SRL;
		elsif opcd=OPCD_SRAI then							-- SRA
			calu2 <= OP_SRA;
		elsif opcd=OPCD_SEQI then							-- SEQ
			calu2 <= OP_SEQ;
		elsif opcd=OPCD_SNEI then							-- SNE
			calu2 <= OP_SNE;
		elsif opcd=OPCD_SLTI then							-- SLT
			calu2 <= OP_SLT;
		elsif opcd=OPCD_SGTI then							-- SGT
			calu2 <= OP_SGT;
		elsif opcd=OPCD_SLEI then							-- SLE
			calu2 <= OP_SLE;
		elsif opcd=OPCD_SGEI then							-- SGE
			calu2 <= OP_SGE;
		elsif opcd=OPCD_SLTUI then							-- SLTU
			calu2 <= OP_SLTU;
		elsif opcd=OPCD_SGTUI then							-- SGTU
			calu2 <= OP_SGTU;
		elsif opcd=OPCD_SLEUI then							-- SLEU
			calu2 <= OP_SLEU;
		elsif opcd=OPCD_SGEUI then							-- SGEU
			calu2 <= OP_SGEU;
		else
			calu2 <= OP_ADD;
		end if;
	end process;

	upc2 <= to_integer(unsigned(relc)) when (stall2='0') else 0 when (rst='0');
	P_CW: process (clk, rst)
	begin
		if rst = '0' then
--			upc2 <= 0;
			upc3 <= 0;
			upc4 <= 0;
			upc5 <= 0;
		elsif clk'event and clk = '1' then
--			if stall2='0' then
--				upc2 <= to_integer(unsigned(relc));
--			end if;
			if (upc2 /= 0) and (stall3='0') then
				upc3 <= upc2+1;
				calu <= calu2;
			end if;
			if (upc3 /= 0) and (stall4='0') then
				upc4 <= upc3+1;
			end if;
			if (upc4 /= 0) and (stall5='0') then
				upc5 <= upc4+1;
			end if;
		end if;
	end process;
	
end cw_generator_arch;
