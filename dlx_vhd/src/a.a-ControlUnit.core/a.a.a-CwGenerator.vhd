--------------------------------------------------------------------------------
-- FILE: CwGenerator
-- DESC: Generate Control Word
--
-- Author:
-- Create: 2015-05-30
-- Update: 2015-05-30
-- Status: UNTESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity CwGenerator is
	generic (
		OPCD_SIZE	: integer := 6;			-- Op Code Size
		CALU_SIZE	: integer := 2;			-- ALU Op Code Word Size
		ISTR_SIZE	: integer := 32;		-- Instruction Register Size
		FUNC_SIZE	: integer := 11;		-- Func Field Size for R-Type Ops
		CWRD_SIZE	: integer := 15;			-- Control Word Size
		REG_ADDR_SIZE : integer := MyLog2Ceil(C_REG_NUM)			-- Control Word Size
	);
	port (
		clk		: in  std_logic;
		rst		: in  std_logic;
		ir		: in std_logic_vector(ISTR_SIZE-1 downto 0);
		reg_a	: in std_logic_vector(DATA_SIZE-1 downto 0);
		alu_o	: in std_logic_vector(DATA_SIZE-1 downto 0);
		wb_o	: in std_logic_vector(DATA_SIZE-1 downto 0);
		cw		: out std_logic_vector(CWRD_SIZE-1 downto 0);
		calu	: out std_logic_vector(CALU_SIZE-1 downto 0);
		reg4_addr_in : in std_logic_vector(REG_ADDR_SIZE downto 0);
		reg5_addr_in : in std_logic_vector(REG_ADDR_SIZE downto 0)
	);
end CwGenerator;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture cw_generator_arch of CwGenerator is
	constant PIPELINE_STATGE: integer := 5;
	--constant UCODE_MEM_SIZE : integer := 2**OPCD_SIZE;
	constant UCODE_MEM_SIZE : integer := 4*100;
	constant RELOC_MEM_SIZE : integer := 2**6;
	type ucode_mem_t is array (0 to UCODE_MEM_SIZE-1) of std_logic_vector(CWRD_SIZE-1 downto 0);
	type reloc_mem_t is array (0 to RELOC_MEM_SIZE-1) of std_logic_vector(OPCD_SIZE+1 downto 0);	-- Mul by 4, since each instruction need 4 stages, IF stage do not count. 

	signal reloc_mem : reloc_mem_t := (
		x"01",	-- 0x00 R
		x"00",	-- 0x01 UNUSED 
		x"05",	-- 0x02 J
		x"09",	-- 0x03 JAL
		x"0d",	-- 0x04 BEQZ
		x"0d",	-- 0x05 BNEZ
		x"00",	-- 0x06 UNUSED
		x"00",	-- 0x07	UNUSED
		x"11",	-- 0x08 ADDI
		x"11",	-- 0x09 ADDUI
		x"11",	-- 0x0a SUBI
		x"11",	-- 0x0b SUBUI
		x"11",	-- 0x0c ANDI
		x"11",	-- 0x0d ORI
		x"11",	-- 0x0e XORI
		x"00",	-- 0x0f UNUSED
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
		x"00",	-- 0x20	UNUSED
		x"00",	-- 0x21 UNUSED
		x"00",	-- 0x22	UNUSED
		x"00",	-- 0x23 UNUSED
		x"00",	-- 0x24 UNUSED
		x"00",	-- 0x25 UNUSED
		x"00",	-- 0x26 UNUSED
		x"00",	-- 0x27	UNUSED
		x"00",	-- 0x28 UNUSED
		x"00",	-- 0x29 UNUSED
		x"00",	-- 0x2a UNUSED
		x"00",	-- 0x2b UNUSED
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
		x"11",	-- 0x3a SLTUI
		x"11",	-- 0x3b SGTUI
		x"11",	-- 0x3c SLEUI
		x"11",	-- 0x3d SGEUI
		x"00",	-- 0x3e UNUSED
		x"00", 	-- 0x3f UNUSED
		
	);
	signal ucode_mem : ucode_mem_t := (
		"000000000000000",	-- 0x00 RESET
		"000000000000000",  -- 0x01 R	[ID]	
		"000000000000000",  --		R	[EXE]
		"001010110000000",  --		R	[MEM]
		"000000111000100",  --		R	[WB]
		"000000000000101",  -- 0x05	J
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",  -- 0x09	JAL
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",	-- 0x0d	BEQZ/BENZ
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",	-- 0x11	ADDI/ADDUI/...	
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",	-- 0x15	JR
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",	-- 0x19	JALR
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",	-- 0x1d	NOP
		"000000000000000",
		"000000000000000",
		"000000000000000"
	);

	signal cw1 : std_logic_vector(CWRD_SIZE-1 downto 0)=(CWRD_SIZE-1=>'1', others=>'0');
	signal cw2 : std_logic_vector(CWRD_SIZE-1 downto 0);
	signal cw3 : std_logic_vector(CWRD_SIZE-1 downto 0);
	signal cw4 : std_logic_vector(CWRD_SIZE-1 downto 0);
	signal cw5 : std_logic_vector(CWRD_SIZE-1 downto 0);
	signal cw3_0: std_logic_vector(CWRD_SIZE-1 downto 0);
	signal cw4_0: std_logic_vector(CWRD_SIZE-1 downto 0);

	signal upc2 : integer range 0 to 131072;
	signal upc3 : integer range 0 to 131072;
	signal upc4 : integer range 0 to 131072;
	signal upc5 : integer range 0 to 131072;
	signal i_count : integer range 0 to PIPELINE_STAGE;
	signal opcd : std_logic_vector(OPCD_SIZE-1 downto 0);
	signal relc : std_logic_vector(OPCD_SIZE+1 downto 0);
	signal func : std_logic_vector(FUNC_SIZE-1 downto 0);
	
	constant REG_ADDR_SIZE : integer := MyLog2Ceil(C_REG_NUM);
	signal rega_addr : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal regb_addr : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal regc_addr : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal reg4_addr : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal reg5_addr : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal reg0_addr : std_logic_vector(REG_ADDR_SIZE-1 downto 0) := (others=>'0');
	signal load_flag : std_logic;
	signal load_flag_delay: std_logic;
  
begin

	cw2 <= ucode_mem(upc2);
	cw3 <= ucode_mem(upc3);
	cw4 <= ucode_mem(upc4);
	cw5 <= ucode_mem(upc5);
	
	-- for forwarding
	cw4_fwd <= ucode_mem(upc4+1);
	cw5_fwd <= cw5;
	reg4_addr <= reg4_addr_in when cw4_fwd(CWRD-CW_S5_EN_WB-1)='1' and  else (others=>'0');
	reg5_addr <= reg5_addr_in when cw5_fwd(CWRD-CW_S5_EN_WB-1)='1' else (others=>'0');
	
	opcd <= std_logic_vector(ir(ISTR_SIZE-1 downto ISTR_SIZE-OPCD_SIZE));
	func <= std_logic_vector(ir(FUNC_SIZE-1 downto 0));
	relc <= reloc_mem(to_integer(unsigned(opcd)));
	

	rega_addr <= ir(ISTR_SIZE-OPCD_SIZE-1 downto ISTR_SIZE-OPCD_SIZE-REG_ADDR_SIZE);
	regb_addr <= ir(ISTR_SIZE-OPCD_SIZE-REG_ADDR_SIZE-1 downto ISTR_SIZE-OPCD_SIZE-2*REG_ADDR_SIZE);
	regc_addr <= ir(ISTR_SIZE-OPCD_SIZE-2*REG_ADDR_SIZE-1 downto ISTR_SIZE-OPCD_SIZE-3*REG_ADDR_SIZE);
	
	cw <= ((cw1 or cw2) or (cw3_0 or cw4_0)) or cw5;

	P_CALU: process (opcd, func)
	begin
		calu <= (others => '0');
		if (opcd = OPCD_R) then
			if (func=FUNC_ADD) or (func=FUNC_ADDU) then		-- ADD
				calu <= OP_ADD;
			elsif (func=FUNC_AND) then						-- AND
				calu <= OP_AND;
			elsif (func=FUNC_OR) then						-- OR
				calu <= OP_OR;
			elsif (func=FUNC_XOR) then						-- AND
				calu <= OP_XOR;
			elsif (func=FUNC_SLL) then						-- SLL
				calu <= OP_SLL;
			elsif (func=FUNC_SRL) then						-- SRL
				calu <= OP_SRL;
			elsif (func=FUNC_SRA) then						-- SRA
				calu <= OP_SRA;
			elsif (func=FUNC_SUB) or (func=FUNC_SUBU) then	-- SUB
				calu <= OP_SUB;
			elsif (func = FUNC_SGT) then					-- SGT
				calu <= OP_SGT;
			elsif (func = FUNC_SGE) then					-- SGE
				calu <= OP_SGE;
			elsif (func = FUNC_SLT) then					-- SLT
				calu <= OP_SLT;
			elsif (func = FUNC_SLE) then					-- SLE
				calu <= OP_SLE;
			elsif (func = FUNC_SGTU) then					-- SGTU
				calu <= OP_SGTU;
			elsif (func = FUNC_SGEU) then					-- SGEU
				calu <= OP_SGEU;
			elsif (func = FUNC_SLTU) then					-- SLTU
				calu <= OP_SLTU;
			elsif (func = FUNC_SLEU) then					-- SLEU
				calu <= OP_SLEU;
			elsif (func = FUNC_SEQ) then					-- SEQ
				calu <= OP_SEQ;
			elsif (func = FUNC_SNE) then					-- SNE
				calu <= OP_SNE;
			else
				calu <= OP_ADD;
			end if;
		elsif (opcd=OPCD_ADDI) or (opcd=OPCD_ADDIU) then	-- ADD
			calu <= OP_ADD;
		elsif (opcd=OPCD_SUBI) or (opcd=OPCD_SUBIU) then	-- SUB
			calu <= OP_SUB;
		elsif opcd=OPCD_ANDI then							-- AND
			calu <= OP_AND;
		elsif opcd=OPCD_ORI then							-- OR
			calu <= OP_OR;
		elsif opcd=OPCD_XORI then							-- XOR
			calu <= OP_XOR;
		elsif opcd=OPCD_SLLI then							-- SLL
			calu <= OP_SLL;
		elsif opcd=OPCD_SRLI then							-- SRL
			calu <= OP_SRL;
		elsif opcd=OPCD_SRAI then							-- SRA
			calu <= OP_SRA;
		elsif opcd=OPCD_SEQI then							-- SEQ
			calu <= OP_SEQ;
		elsif opcd=OPCD_SNEI then							-- SNE
			calu <= OP_SNE;
		elsif opcd=OPCD_SLTI then							-- SLT
			calu <= OP_SLT;
		elsif opcd=OPCD_SGTI then							-- SGT
			calu <= OP_SGT;
		elsif opcd=OPCD_SLEI then							-- SLE
			calu <= OP_SLE;
		elsif opcd=OPCD_SGEI then							-- SGE
			calu <= OP_SGE;
		elsif opcd=OPCD_SLTUI then							-- SLTU
			calu <= OP_SLTU;
		elsif opcd=OPCD_SGTUI then							-- SGTU
			calu <= OP_SGTU;
		elsif opcd=OPCD_SLEUI then							-- SLEU
			calu <= OP_SLEU;
		elsif opcd=OPCD_SGEUI then							-- SGEU
			calu <= OP_SGEU;
		else
			calu <= OP_ADD;
		end if;
	end process ALU_OP_CODE_P;

	P_CW: process (clk, rst)
	begin
		if rst = '0' then
			upc2 <= 0;
			upc3 <= 0;
			upc4 <= 0;
			upc5 <= 0;
			load_flag <= '0';
			load_flag_delay <= '0';
		elsif clk'event and clk = '1' then
			if not stall_2 then
				stall_2 <= stall_1;
				upc2 <= to_integer(unsigned(relc));
				if (opcd=OPCD_LB) or (opcd=OPCD_LH) or (opcd=OPCD_LW) or (opcd=LBU) or (opcd=LHU) or (opcd=LF) or (opcd=LD) then
					load_flag <= '1';
				else
					load_flag <= '0';
				end if;
			end if;
			if (upc2 /= 0) and (not stall_3) then
				stall_3 <= stall_2;
				upc3 <= upc2+1;
				load_flag_delay <= load_flag;
			end if;
			if (upc3 /= 0) and (not stall_4) then
				stall_4 <= stall_3;
				upc4 <= upc3+1;
			end if;
			if (upc4 /= 0) and (not stall_5) then
				stall_5 <= stall_4;
				upc5 <= upc4+1;
			end if;
	end process uPC_Proc;
	
	P_FWD:process(cw3, rega_addr, regb_addr, reg4_addr, reg5_addr)
	begin
		if (cw3(CWRD_SIZE-CW_S3_SEL_A_1-1 downto CWRD_SIZE-CW_S3_SEL_A_0)="00") and rega_addr/=reg0_addr then
			if rega_addr = reg4_addr then
				if load_flag_delay then
					stall_3 <= '1';
				else
					cw3_0(CWRD_SIZE-1 downto CW_S3_SEL_A_1) <= cw3(CWRD_SIZE-1 downto CW_S3_SEL_A_1);
					cw3_0(CWRD_SIZE-CW_S3_SEL_A_1-1 downto CWRD_SIZE-CW_S3_SEL_A_0)<="10"
					cw3_0(CWRD_SIZE-CW_S3_SEL_A_0-1 downto 0) <= cw3(CWRD_SIZE-CW_S3_SEL_A_0-1 downto 0);
				end if;
			elsif rega_addr = reg5_addr then
				cw3_0(CWRD_SIZE-1 downto CW_S3_SEL_A_1) <= cw3(CWRD_SIZE-1 downto CW_S3_SEL_A_1);
				cw3_0(CWRD_SIZE-CW_S3_SEL_A_1-1 downto CWRD_SIZE-CW_S3_SEL_A_0)<="11"
				cw3_0(CWRD_SIZE-CW_S3_SEL_A_0-1 downto 0) <= cw3(CWRD_SIZE-CW_S3_SEL_A_0-1 downto 0);
			else
				cw3_0 <= cw3;
			end if;
		end if;
		if (cw3(CWRD_SIZE-CW_S3_SEL_B_1-1 downto CWRD_SIZE-CW_S3_SEL_B_0)="00") and regb_addr/=reg0_addr then
			if regb_addr = reg4_addr then
				cw3_0(CWRD_SIZE-1 downto CW_S3_SEL_B_1) <= cw3(CWRD_SIZE-1 downto CW_S3_SEL_B_1);
				cw3_0(CWRD_SIZE-CW_S3_SEL_B_1-1 downto CWRD_SIZE-CW_S3_SEL_B_0)<="10";
				cw3_0(CWRD_SIZE-CW_S3_SEL_B_0-1 downto 0) <= cw3(CWRD_SIZE-CW_S3_SEL_B_0-1 downto 0);
			elsif regb_addr = reg5_addr then
				cw3_0(CWRD_SIZE-1 downto CW_S3_SEL_B_1) <= cw3(CWRD_SIZE-1 downto CW_S3_SEL_B_1);
				cw3_0(CWRD_SIZE-CW_S3_SEL_B_1-1 downto CWRD_SIZE-CW_S3_SEL_B_0)<="11";
				cw3_0(CWRD_SIZE-CW_S3_SEL_B_0-1 downto 0) <= cw3(CWRD_SIZE-CW_S3_SEL_B_0-1 downto 0);
			else
				cw3_0 <= cw3;
			end if;
		end if;
		if regb_addr/=reg0_addr then
			if regb_addr = reg5_addr then
				cw4_0(CWRD_SIZE-1 downto CW_S4_SEL_BB) <= cw3(CWRD_SIZE-1 downto CW_S4_SEL_BB);
				cw4_0(CWRD_SIZE-CW_S4_SEL_BB)<='1';
				cw4_0(CWRD_SIZE-CW_S4_SEL_BB-1 downto 0) <= cw3(CWRD_SIZE-CW_S4_SEL_BB-1 downto 0);
			else
				cw4_0 <= cw4;
			end if;
		end if;
	end if;
	
end cw_generator_arch;
