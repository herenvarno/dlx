--------------------------------------------------------------------------------
-- FILE: DataPath
-- DESC: Datapath of DLX
--
-- Author:
-- Create: 2015-05-24
-- Update: 2015-06-01
-- Status: UNTESTED
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
  		istr_val	: in std_logic_vector(ISTR_SIZE-1 downto 0):=(others=>'0');
  		ir_out		: out std_logic_vector(ISTR_SIZE-1 downto 0);
  		reg_a_out	: out std_logic_vector(DATA_SIZE-1 downto 0);
  		data_addr	: out std_logic_vector(ADDR_SIZE-1 downto 0);
  		data_i_val	: in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
  		data_o_val	: out std_logic_vector(DATA_SIZE-1 downto 0);
  		cw			: in std_logic_vector(CWRD_SIZE-1 downto 0):=(others=>'0');
  		dr_cw		: out std_logic_vector(DRCW_SIZE-1 downto 0);
  		calu		: in std_logic_vector(CALU_SIZE-1 downto 0):=(others=>'0');
  		branch_wait	: out std_logic:='0';
  		reg_a_wait	: out std_logic:='0';
  		reg_b_wait	: out std_logic:='0'
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
			link_en	: in std_logic;	
			rd1_addr: in std_logic_vector(MyLog2Ceil(REG_NUM)-1 downto 0);	-- address of read port 1
			rd2_addr: in std_logic_vector(MyLog2Ceil(REG_NUM)-1 downto 0);	-- address of read port 2
			wr_addr	: in std_logic_vector(MyLog2Ceil(REG_NUM)-1 downto 0);	-- address of write port
			d_out1	: out std_logic_vector(DATA_SIZE-1 downto 0);			-- data out 1 bus
			d_out2	: out std_logic_vector(DATA_SIZE-1 downto 0);			-- data out 2 bus
			d_in	: in std_logic_vector(DATA_SIZE-1 downto 0);			-- data in bus
			d_link	: in std_logic_vector(DATA_SIZE-1 downto 0)
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
			DEST_SIZE: integer := C_SYS_DATA_SIZE
		);
		port(
			s : std_logic := '0';
			i : in std_logic_vector(SRC_SIZE-1 downto 0);
			o : out std_logic_vector(DEST_SIZE-1 downto 0)
		);
	end component;
	
	component FwdMux1 is
		generic (
			DATA_SIZE : integer := C_SYS_DATA_SIZE;
			REG_ADDR_SIZE : integer := MyLog2Ceil(C_REG_NUM)
		);
		port(
			reg_c	: in std_logic_vector(DATA_SIZE-1 downto 0);
			reg_f	: in std_logic_vector(DATA_SIZE-1 downto 0);
			addr_c	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
			addr_f	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
			valid_f	: in std_logic;
			dirty_f	: in std_logic;
			output	: out std_logic_vector(DATA_SIZE-1 downto 0);
			match_dirty_f: out std_logic
		);
	end component;
	component FwdMux2 is
	generic (
			DATA_SIZE : integer := C_SYS_DATA_SIZE;
			REG_ADDR_SIZE : integer := MyLog2Ceil(C_REG_NUM)
		);
		port(
			reg_c	: in std_logic_vector(DATA_SIZE-1 downto 0);
			reg_f	: in std_logic_vector(DATA_SIZE-1 downto 0);
			reg_ff	: in std_logic_vector(DATA_SIZE-1 downto 0);
			addr_c	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
			addr_f	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
			addr_ff	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
			valid_f	: in std_logic;
			valid_ff: in std_logic;
			dirty_f	: in std_logic;
			dirty_ff: in std_logic;
			en		: in std_logic:='1';
			output	: out std_logic_vector(DATA_SIZE-1 downto 0);
			match_dirty_f	: out std_logic;
			match_dirty_ff	: out std_logic
		);
	end component;
	
	constant REG_NUM : integer := C_REG_NUM;
	constant REG_ADDR_SIZE : integer := MyLog2Ceil(REG_NUM);
	
	signal s1_pc, s2_pc, s1_jpc, s2_jpc : std_logic_vector(ADDR_SIZE-1 downto 0):= (others=>'0');
	signal s1_4 : std_logic_vector(DATA_SIZE-1 downto 0) := (2 => '1', others => '0');
	signal s1_npc, s2_npc : std_logic_vector(ADDR_SIZE-1 downto 0):= (others=>'0');
	signal s1_istr, s2_istr : std_logic_vector(ISTR_SIZE-1 downto 0):= (others=>'0');
	signal s2_rf_en : std_logic:='0';
	signal s2_rd1_addr, s3_rd1_addr, s2_rd2_addr, s3_rd2_addr, s4_rd2_addr, s2_wr_addr, s2_wr_addr_r, s2_wr_addr_i, s3_wr_addr, s4_wr_addr, s5_wr_addr : std_logic_vector(REG_ADDR_SIZE-1 downto 0):=(others=>'0');
	signal s2_wr_addr_sel: std_logic:='0';
	signal s2_a, s2_b, s3_a, s3_b, s4_b : std_logic_vector(DATA_SIZE-1 downto 0);
	signal s2_imm_i : std_logic_vector(IMME_SIZE-1 downto 0);
	signal s2_imm_j : std_logic_vector(ISTR_SIZE-OPCD_SIZE-1 downto 0);
	signal s2_imm_i_ext, s2_imm_j_ext, s3_imm_i_ext : std_logic_vector(DATA_SIZE-1 downto 0);
	signal s2_addr_relative, s2_addr_abs : std_logic_vector(ISTR_SIZE-1 downto 0);
	signal s3_fwd_valid : std_logic;
	signal s3_a_keep, s3_b_keep, s3_a_sel, s3_b_fwd, s3_b_sel, s4_b_sel : std_logic_vector(DATA_SIZE-1 downto 0);
	signal s3_alu_out, s4_alu_out : std_logic_vector(DATA_SIZE-1 downto 0);
	signal s4_mem_in, s4_mem_out : std_logic_vector(DATA_SIZE-1 downto 0);
	signal s4_result, s5_result : std_logic_vector(DATA_SIZE-1 downto 0);
	signal zeros_opcd : std_logic_vector(OPCD_SIZE-1 downto 0):=(others=>'0');
	signal s2_jump_wait, s3_reg_a_wait, s3_reg_b_wait: std_logic:='0';
	
	signal s2_addr_cal:std_logic_vector(ADDR_SIZE-1 downto 0);
	signal s2_a_final, s3_a_final: std_logic_vector(DATA_SIZE-1 downto 0);
	signal s2_branch_flag: std_logic;
	signal s2_a_final_f_en: std_logic;
	signal s3_jump_wait: std_logic;
	signal s4_reg_a_wait, s4_reg_b_wait: std_logic;
	signal s3_b_sel_f_en:std_logic;
	
	
begin
	-- PIPELINE STATE 1 : [IF]
	s1_istr <= istr_val;	-- from IRAM
	
	-- NPC=PC+4
	ADD_4: Adder
	generic map (ADDR_SIZE)
	port map ('0', s2_pc, s1_4, s1_npc, open);
	
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
		if s2_istr(ISTR_SIZE-1 downto ISTR_SIZE-OPCD_SIZE)=zeros_opcd then
			s2_wr_addr_sel <= '0';
		else
			s2_wr_addr_sel <= '1';
		end if;
	end process;
	
	reg_a_out <= s2_a;
	
	EXT_I: Extender
	generic map(IMME_SIZE, DATA_SIZE)
	port map(cw(CW_S2_EXT_S), s2_imm_i, s2_imm_i_ext);
	
	EXT_J: Extender
	generic map(ISTR_SIZE-OPCD_SIZE, DATA_SIZE)
	port map('0', s2_imm_j, s2_imm_j_ext);
	
	s2_rf_en <= (cw(CW_S2_LATCH) or cw(CW_S5_EN_WB));
	RF0: RegisterFile
	generic map(DATA_SIZE, REG_NUM)
	port map(clk, rst, s2_rf_en, cw(CW_S2_LATCH), cw(CW_S2_LATCH), cw(CW_S5_EN_WB), cw(CW_S2_LINK), s2_rd1_addr, s2_rd2_addr, s5_wr_addr, s2_a, s2_b, s5_result, s2_npc);
	
	MUX_JPC0: Mux
	generic map (ADDR_SIZE)
	port map (cw(CW_S2_SEL_JA_0), s2_addr_relative, s2_addr_abs, s2_addr_cal);
	
	MUX_JPC1: Mux
	generic map (ADDR_SIZE)
	port map (cw(CW_S2_SEL_JA_1), s2_addr_cal, s2_a_final, s1_jpc);
	
	ADDER_ADDR: Adder
	generic map(DATA_SIZE)
	port map('0', s2_npc, s2_imm_j_ext, s2_addr_relative, open);
	
	MUX_WB_ADDR: Mux
	generic map (REG_ADDR_SIZE)
	port map (s2_wr_addr_sel, s2_wr_addr_r, s2_wr_addr_i, s2_wr_addr);
	
	
	PROG: process(s2_istr)
	begin
		if (s2_istr(ISTR_SIZE-1 downto ISTR_SIZE-OPCD_SIZE)=OPCD_BEQZ) or (s2_istr(ISTR_SIZE-1 downto ISTR_SIZE-OPCD_SIZE)=OPCD_BNEZ) then
			s2_branch_flag <= '1';
		else
			s2_branch_flag <= '0';
		end if;
	end process;
	
	s2_a_final_f_en <= cw(CW_S3_WB_FLAG) and (cw(CW_S2_SEL_A1) or s2_branch_flag);
	
	FWDMUX_2A: FwdMux2
	generic map(DATA_SIZE, REG_ADDR_SIZE)
	port map(s2_a, s3_alu_out, s4_result, s2_rd1_addr, s3_wr_addr, s4_wr_addr, s2_a_final_f_en, cw(CW_S4_WB_FLAG), cw(CW_S3_LD_FLAG), '0', cw(CW_S2_LATCH), s3_a_final, s3_jump_wait, open);
	
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
	
	REG_A_ADDR_2: Reg
	generic map(REG_ADDR_SIZE)
	port map(rst, cw(CW_S2_LATCH), clk, s2_rd1_addr, s3_rd1_addr);
	
	REG_B_ADDR_2: Reg
	generic map(REG_ADDR_SIZE)
	port map(rst, cw(CW_S2_LATCH), clk, s2_rd2_addr, s3_rd2_addr);
	
	-- PIPELIE STAGE 3 : [EXE]
	MUX_KEEP_A:Mux
	generic map(DATA_SIZE)
	port map(s4_reg_b_wait, s3_a, s3_a_sel, s3_a_keep);

	MUX_KEEP_B:Mux
	generic map(DATA_SIZE)
	port map(s4_reg_a_wait, s3_b, s3_b_fwd, s3_b_keep);
	
	FWDMUX_A: FwdMux2
	generic map(DATA_SIZE, REG_ADDR_SIZE)
	port map(s3_a_keep, s4_alu_out, s5_result, s3_rd1_addr, s4_wr_addr, s5_wr_addr, cw(CW_S4_WB_FLAG), cw(CW_S5_EN_WB), cw(CW_S4_LD_FLAG), '0', cw(CW_S3_LATCH), s3_a_sel, s3_reg_a_wait, open);
	
	s3_b_sel_f_en <= cw(CW_S4_WB_FLAG) and (not cw(CW_S3_SEL_B));
	FWDMUX_B: FwdMux2
	generic map(DATA_SIZE, REG_ADDR_SIZE)
	port map(s3_b_keep, s4_alu_out, s5_result, s3_rd2_addr, s4_wr_addr, s5_wr_addr, s3_b_sel_f_en, cw(CW_S5_EN_WB), cw(CW_S4_LD_FLAG), '0', cw(CW_S3_LATCH), s3_b_fwd, s3_reg_b_wait, open);

	MUXB: Mux
	generic map(DATA_SIZE)
	port map(cw(CW_S3_SEL_B), s3_b_fwd, s3_imm_i_ext, s3_b_sel);

	ALU0: Alu
	generic map(DATA_SIZE)
	port map(calu, s3_a_sel, s3_b_sel, s3_alu_out);
	
	-- REGISTERS : [EXE]||[MEM]
	REG_ALU: Reg
	generic map(DATA_SIZE)
	port map(rst, cw(CW_S3_LATCH), clk, s3_alu_out, s4_alu_out);
	
	REG_BB: Reg
	generic map(DATA_SIZE)
	port map(rst, cw(CW_S3_LATCH), clk, s3_b_sel, s4_b_sel);
	
	REG_B_ADDR_3: Reg
	generic map(REG_ADDR_SIZE)
	port map(rst, cw(CW_S3_LATCH), clk, s3_rd2_addr, s4_rd2_addr);
	
	REG_WR3: Reg
	generic map(REG_ADDR_SIZE)
	port map(rst, cw(CW_S3_LATCH), clk, s3_wr_addr, s4_wr_addr);
	
	----------------------------------------------------------------------------
	-- FIXME
	-- COMP: REG_OPRD_A_WAIT, REG_OPRD_B_WAIT
	-- DESC: Registers for keeping the operand A and B to PIPELINE STATGE 4 [MEM].
	--			When A causes a STALL, due to forward value is not ready (Load After Read)
	--			in stage 4, and B uses the value of double-forward (from stage 5)
	--			which is valid. We need to keep the value of B because once the
	--			STALL complete, the valid value of B in stage 5 will be stored in Register File.
	--			At this moment, other instruction occupies the stage 2, so we cannot
	--			get the value of B for the instruction in stage 3. Therefore, we
	--			need this two registers to store the value of A and B.
	----------------------------------------------------------------------------
	REG_OPRD_A_WAIT: Reg
	generic map(DATA_SIZE)
	port map(rst, cw(CW_S3_LATCH), clk, s3_oprd_a, s4_oprd_a);
	
	REG_OPRD_B_WAIT: Reg
	generic map(DATA_SIZE)
	port map(rst, cw(CW_S3_LATCH), clk, s3_oprd_b, s4_oprd_b);
	
	----------------------------------------------------------------------------
	-- FIXME
	-- COMP: REG_OPRD_A_WAIT, REG_OPRD_B_WAIT
	-- DESC: Registers for keeping the operand A and B to PIPELINE STATGE 4 [MEM].
	--			When A causes a STALL, due to forward value is not ready (Load After Read)
	--			in stage 4, and B uses the value of double-forward (from stage 5)
	--			which is valid. We need to keep the value of B because once the
	--			STALL complete, the valid value of B in stage 5 will be stored in Register File.
	--			At this moment, other instruction occupies the stage 2, so we cannot
	--			get the value of B for the instruction in stage 3. Therefore, we
	--			need this two registers to store the value of A and B.
	----------------------------------------------------------------------------
	
	
	-- PIPELINE STAGE 4 : [MEM]
	-- Signals to Data RAM
	data_addr <= s4_alu_out;	-- to DRAM
	data_o_val <= s4_mem_in;	-- to DRAM
	s4_mem_out <= data_i_val;	-- from DRAM
	dr_cw <= cw(CW_S4_DRAM_WR downto CW_S4_DRAM_T_0);	-- to DRAM
	
	FWDMUX_BB: FwdMux1
	generic map(DATA_SIZE, REG_ADDR_SIZE)
	port map(s4_b_sel, s5_result, s4_rd2_addr, s5_wr_addr, cw(CW_S5_EN_WB), '0', s4_mem_in, open);
	
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
