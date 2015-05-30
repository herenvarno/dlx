--------------------------------------------------------------------------------
-- FILE: DataPath
-- DESC: Datapath of DLX
--
-- Author:
-- Create: 2015-05-24
-- Update: 2015-05-30
-- Status: TESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Types.all;
use work.Consts.all;
use work.Funcs.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity DataPath is
	generic (
		ADDR_SIZE : integer := C_SYS_ADDR_SIZE;
		DATA_SIZE : integer := C_SYS_DATA_SIZE;
		ISTR_SIZE : integer := C_SYS_ISTR_SIZE;
		OPCD_SIZE : integer := C_SYS_OPCD_SIZE;
		IMME_SIZE : integer := C_SYS_IMME_SIZE;
		CWRD_SIZE : integer := C_SYS_CWRD_SIZE;	-- Datapath Contrl Word
		CALU_SIZE : integer := C_CTR_CALU_SIZE;	
		DRCW_SIZE : integer := C_CTR_DRCW_SIZE
	);
  	port (
  		clk			: in std_logic;
  		rst			: in std_logic;
  		istr_addr	: out std_logic_vector(ADDR_SIZE-1 downto 0);
  		istr_val	: in std_logic_vector(ISTR_SIZE-1 downto 0);
  		ir_out		: out std_logic_vector(ISTR_SIZE-1 downto 0);
  		reg_a_out	: out std_logic_vector(DATA_SIZE-1 downto 0);
  		data_addr	: out std_logic_vector(ADDR_SIZE-1 downto 0);
  		data_i_val	: in std_logic_vector(DATA_SIZE-1 downto 0);
  		data_o_val	: out std_logic_vector(DATA_SIZE-1 downto 0);
  		cw			: in std_logic_vector(CWRD_SIZE-1 downto 0);
  		dr_cw		: out std_logic_vector(DRCW_SIZE-1 downto 0);
  		calu		: in std_logic_vector(CALU_SIZE-1 downto 0)
  	);
end DataPath;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture data_path_arch of DataPath is
	component Mux is
		generic(
			DATA_SIZE: integer := C_SYS_DATA_SIZE
		);
		port(
			sel: in std_logic;
			din0: in std_logic_vector(DATA_SIZE-1 downto 0);
			din1: in std_logic_vector(DATA_SIZE-1 downto 0);
			dout: out std_logic_vector(DATA_SIZE-1 downto 0)
		);
	end component;
	component Mux4 is
		generic(
			DATA_SIZE: integer := C_SYS_DATA_SIZE
		);
		port(
			sel: in std_logic_vector(1 downto 0);
			din0: in std_logic_vector(DATA_SIZE-1 downto 0);
			din1: in std_logic_vector(DATA_SIZE-1 downto 0);
			din2: in std_logic_vector(DATA_SIZE-1 downto 0);
			din3: in std_logic_vector(DATA_SIZE-1 downto 0);
			dout: out std_logic_vector(DATA_SIZE-1 downto 0)
		);
	end component;

	component Reg is
		generic(
			DATA_SIZE: integer := C_SYS_DATA_SIZE
		);
		port(
			rst: in std_logic;
			en : in std_logic;
			clk: in std_logic;
			din: in std_logic_vector(DATA_SIZE-1 downto 0);
			dout: out std_logic_vector(DATA_SIZE-1 downto 0)
		);
	end component;
	
	component Adder is
		generic(
			DATA_SIZE : integer := C_SYS_DATA_SIZE
		);
		port(
			cin: in std_logic;
			a, b: in std_logic_vector(DATA_SIZE-1 downto 0);
			s : out std_logic_vector(DATA_SIZE-1 downto 0);
			cout: out std_logic
		);
	end component;
	
	component RegisterFile is
		generic(
			DATA_SIZE : integer := C_SYS_DATA_SIZE;
			REG_NUM : integer := C_REG_NUM
		);
		port(
			clk		: in std_logic;											-- clock
			rst		: in std_logic;											-- reset
			en		: in std_logic;											-- enable
			rd1_en	: in std_logic;											-- read port 1
			rd2_en	: in std_logic;											-- read port 2
			wr_en	: in std_logic;											-- write port
			rd1_addr: in std_logic_vector(MyLog2Ceil(REG_NUM)-1 downto 0);	-- address of read port 1
			rd2_addr: in std_logic_vector(MyLog2Ceil(REG_NUM)-1 downto 0);	-- address of read port 2
			wr_addr	: in std_logic_vector(MyLog2Ceil(REG_NUM)-1 downto 0);	-- address of write port
			d_out1	: out std_logic_vector(DATA_SIZE-1 downto 0);			-- data out 1 bus
			d_out2	: out std_logic_vector(DATA_SIZE-1 downto 0);			-- data out 2 bus
			d_in	: in std_logic_vector(DATA_SIZE-1 downto 0)				-- data in bus
		);
	end component;
	
	component Alu is
		generic (
			DATA_SIZE : integer := C_SYS_DATA_SIZE
		);
		port (
			f : in std_logic_vector(4 downto 0);			-- Function
			a : in std_logic_vector(DATA_SIZE-1 downto 0);	-- Data A
			b : in std_logic_vector(DATA_SIZE-1 downto 0);	-- Data B
			o : out std_logic_vector(DATA_SIZE-1 downto 0)	-- Data Out
		);
	end component;
	component Extender is
		generic(
			SRC_SIZE : integer := 1;
			DEST_SIZE: integer := C_SYS_DATA_SIZE;
			METHOD : std_logic := '0'				-- 0 for "Extend with 0s", 1 for "Extend with MSB" 
		);
		port(
			i : in std_logic_vector(SRC_SIZE-1 downto 0);
			o : out std_logic_vector(DEST_SIZE-1 downto 0)
		);
	end component;

	constant REG_ADDR_SIZE : integer := MyLog2Ceil(DATA_SIZE);
	constant REG_NUM : integer := C_REG_NUM;
	signal s1_pc, s2_pc, s1_jpc, s2_jpc : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal s1_4 : std_logic_vector(DATA_SIZE-1 downto 0) := (2 => '1', others => '0');
	signal s1_npc, s2_npc : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal s1_istr, s2_istr : std_logic_vector(ISTR_SIZE-1 downto 0);
	signal s2_rf_en : std_logic;
	signal s2_rd1_addr, s2_rd2_addr, s2_wr_addr, s2_wr_addr_r, s2_wr_addr_i, s3_wr_addr, s4_wr_addr, s5_wr_addr : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal s2_wr_addr_sel: std_logic;
	signal s2_a, s2_b, s3_a, s3_b, s4_b : std_logic_vector(DATA_SIZE-1 downto 0);
	signal s2_imm_i : std_logic_vector(IMME_SIZE-1 downto 0);
	signal s2_imm_j : std_logic_vector(ISTR_SIZE-OPCD_SIZE-1 downto 0);
	signal s2_imm_i_ext, s2_imm_j_ext, s3_imm_i_ext : std_logic_vector(DATA_SIZE-1 downto 0);
	signal s2_addr_relative, s2_addr_abs : std_logic_vector(ISTR_SIZE-1 downto 0);
	signal s3_a_sel, s3_b_sel, s4_b_sel : std_logic_vector(DATA_SIZE-1 downto 0);
	signal s3_alu_out, s4_alu_out : std_logic_vector(DATA_SIZE-1 downto 0);
	signal s4_mem_out : std_logic_vector(DATA_SIZE-1 downto 0);
	signal s4_result, s5_result : std_logic_vector(DATA_SIZE-1 downto 0);
	signal zeros_opcd : std_logic_vector(OPCD_SIZE-1 downto 0):=(others=>'0');
	
begin
	-- PIPELINE STATE 1 : [IF]
	s1_istr <= istr_val;	-- from IRAM
	
	-- NPC=PC+4
	ADD_4: Adder
	generic map (ADDR_SIZE)
	port map ('0', s1_pc, s1_4, s1_npc, open);
	
	-- Choose from NPC and JUMP ADDRESS in case of JUMP.
	MUX_PC: Mux
	generic map (ADDR_SIZE)
	port map (cw(CW_S2_JUMP), s1_npc, s2_jpc, s1_pc);
	
	-- REGISTERS : [IF]||[ID]
	REG_PC: Reg
	generic map (ADDR_SIZE)
	port map (rst, cw(CW_S1_LATCH), clk, s1_pc, s2_pc);
	
	REG_IR: Reg
	generic map (ISTR_SIZE)
	port map (rst, cw(CW_S1_LATCH), clk, s1_istr, s2_istr);
	
	REG_NPC: Reg
	generic map (ADDR_SIZE)
	port map (rst, cw(CW_S1_LATCH), clk, s1_npc, s2_npc);
	
	-- PIPELINE STAGE 2: [ID]
	istr_addr <= s2_pc;	-- to IRAM
	ir_out <= s2_istr;	-- to Control Unit
	
	s2_rd1_addr <= s2_istr(ISTR_SIZE-OPCD_SIZE-1 downto ISTR_SIZE-OPCD_SIZE-REG_ADDR_SIZE);
	s2_rd2_addr <= s2_istr(ISTR_SIZE-OPCD_SIZE-REG_ADDR_SIZE-1 downto ISTR_SIZE-OPCD_SIZE-2*REG_ADDR_SIZE);
	s2_wr_addr_r <= s2_istr(ISTR_SIZE-OPCD_SIZE-2*REG_ADDR_SIZE-1 downto ISTR_SIZE-OPCD_SIZE-3*REG_ADDR_SIZE);
	s2_wr_addr_i <= s2_istr(ISTR_SIZE-OPCD_SIZE-REG_ADDR_SIZE-1 downto ISTR_SIZE-OPCD_SIZE-2*REG_ADDR_SIZE);
	s2_imm_i <= s2_istr(IMME_SIZE-1 downto 0);
	s2_imm_j <= s2_istr(ISTR_SIZE-OPCD_SIZE-1 downto 0);
	P0:process(s2_istr(ISTR_SIZE-1 downto OPCD_SIZE))
	begin
		if s2_istr(ISTR_SIZE-1 downto OPCD_SIZE)=zeros_opcd then
			s2_wr_addr_sel <= '0';
		else
			s2_wr_addr_sel <= '1';
		end if;
	end process;
	
	reg_a_out <= s2_a;
	
	EXT_I: Extender
	generic map(IMME_SIZE, DATA_SIZE, '1')
	port map(s2_imm_i, s2_imm_i_ext);
	
	EXT_J: Extender
	generic map(ISTR_SIZE-OPCD_SIZE, DATA_SIZE, '0')
	port map(s2_imm_j, s2_imm_j_ext);
	
	s2_rf_en <= (cw(CW_S2_LATCH) or cw(CW_S5_EN_WB));
	RF0: RegisterFile
	generic map(DATA_SIZE, REG_NUM)
	port map(clk, rst, s2_rf_en, cw(CW_S2_LATCH), cw(CW_S2_LATCH), cw(CW_S5_EN_WB), s2_rd1_addr, s2_rd2_addr, s5_wr_addr, s2_a, s2_b, s5_result);
	
	MUX_JPC: Mux
	generic map (ADDR_SIZE)
	port map (cw(CW_S2_J_ABS), s2_addr_relative, s2_addr_abs, s1_jpc);
	
	ADDER_ADDR: Adder
	generic map(DATA_SIZE)
	port map('0', s2_npc, s2_imm_j_ext, s2_addr_relative, open);
	
	MUX_WB_ADDR: Mux
	generic map (REG_ADDR_SIZE)
	port map (s2_wr_addr_sel, s2_wr_addr_r, s2_wr_addr_i, s2_wr_addr);
	
	-- REGISTERS : [ID]||[EXE]	
	REG_A: Reg
	generic map(DATA_SIZE)
	port map(rst, cw(CW_S2_LATCH), clk, s2_a, s3_a);
	
	REG_B: Reg
	generic map(DATA_SIZE)
	port map(rst, cw(CW_S2_LATCH), clk, s2_b, s3_b);
	
	REG_I: Reg
	generic map(DATA_SIZE)
	port map(rst, cw(CW_S2_LATCH), clk, s2_imm_i_ext, s3_imm_i_ext);
	
	REG_WR2: Reg
	generic map(REG_ADDR_SIZE)
	port map(rst, cw(CW_S2_LATCH), clk, s2_wr_addr, s3_wr_addr);
	
	-- PIPELIE STAGE 3 : [EXE]
	MUX_A: Mux4
	generic map(DATA_SIZE)
	port map(cw(CW_S3_SEL_A_1 downto CW_S3_SEL_A_0), s3_a, (others => '0'), s4_alu_out, s5_result, s3_a_sel);
	
	MUX_B: Mux4
	generic map(DATA_SIZE)
	port map(cw(CW_S3_SEL_B_1 downto CW_S3_SEL_B_0), s3_b, s3_imm_i_ext, s4_alu_out, s5_result, s3_b_sel);
	
	ALU0: Alu
	generic map(DATA_SIZE)
	port map(calu, s3_a, s3_b_sel, s3_alu_out);
	
	-- REGISTERS : [EXE]||[MEM]
	REG_ALU: Reg
	generic map(DATA_SIZE)
	port map(rst, cw(CW_S3_LATCH), clk, s3_alu_out, s4_alu_out);
	
	REG_BB: Reg
	generic map(DATA_SIZE)
	port map(rst, cw(CW_S3_LATCH), clk, s3_b_sel, s4_b_sel);
	
	REG_WR3: Reg
	generic map(REG_ADDR_SIZE)
	port map(rst, cw(CW_S3_LATCH), clk, s3_wr_addr, s4_wr_addr);
	
	-- PIPELINE STAGE 4 : [MEM]
	-- Signals to Data RAM
	data_addr <= s3_alu_out;	-- to DRAM
	data_o_val <= s4_b;			-- to DRAM
	s4_mem_out <= data_i_val;	-- from DRAM
	dr_cw(0) <= cw(CW_S4_WR_DRAM);	-- to DRAM
	
	MUX_RESULT: Mux
	generic map(DATA_SIZE)
	port map(cw(CW_S4_SEL_WB), s4_alu_out, s4_mem_out, s4_result);
	
	-- REGISTERS : [MEM]||[WB]
	REG_RESULT: Reg
	generic map(DATA_SIZE)
	port map(rst, cw(CW_S4_LATCH), clk, s4_result, s5_result);
	
	REG_WR4: Reg
	generic map(REG_ADDR_SIZE)
	port map(rst, cw(CW_S4_LATCH), clk, s4_wr_addr, s5_wr_addr);
	
	-- PIPELINE STAGE 5 : [WB]
	-- No component needed in pipeline 5, cause every operation happens in Register File.
	
end data_path_arch;
