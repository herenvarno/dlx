--------------------------------------------------------------------------------
-- FILE: DataPath
-- DESC: Datapath of DLX
--
-- Author:
-- Create: 2015-05-24
-- Update: 2015-05-24
-- Status: UNFINISHED
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
		CWRD_SIZE : integer := C_SYS_CWRD_SIZE	-- Datapath Contrl Word
	);
  	port (
  		clk			: in std_logic;
  		rst			: in std_logic;
  		istr_addr	: out std_logic_vector(ADDR_SIZE-1 downto 0);
  		istr_val	: in std_logic_vector(ISTR_SIZE-1 downto 0);
  		ir_out		: out std_logic_vector(ISTR_SIZE-1 downto 0);
  		data_addr	: out std_logic_vector(ADDR_SIZE-1 downto 0);
  		data_i_val	: in std_logic_vector(DATA_SIZE-1 downto 0);
  		data_o_val	: out std_logic_vector(DATA_SIZE-1 downto 0);
  		cw			: in std_logic_vector(CWRD_SIZE-1 downto 0);
  		dr_cw		: out std_logic_vector(DRCW_SIZE-1 downto 0)
  	);
end DataPath;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture data_path_arch of DataPath is
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
	end Adder;

	signal s1_pc_in, s1_pc_out : std_logic_vector(DATA_SIZE-1 downto 0);
	signal s1_4 : std_logic_vector(DATA_SIZE-1 downto 0) := (2 => '1' others => '0');
	signal s1_npc, s2_npc : std_logic_vector(DATA_SIZE-1 downto 0);
begin
	-- PIPELINE STATE 1 : [IF]
	istr_addr <= s1_pc_out;
	
	ADD_4: Adder
	generic(ADDR_SIZE)
	port('0', s1_pc_out, s1_4, s1_npc, open);
	
	MUX_PC: Mux
	generic(ADDR_SIZE)
	port(cw(CW_S4_JUMP), s1_npc, s4_jpc, s1_pc_in);
	
	-- REGISTERS : [IF]||[ID]
	REG_PC: Reg
	generic(ADDR_SIZE)
	port(rst, cw(CW_S1_LATCH), clk, s1_pc_in, s1_pc_out);
	
	REG_IR: Reg
	generic(ISTR_SIZE)
	port(rst, cw(CW_S1_LATCH), clk, istr_val, s2_ir);
	
	REG_NPC1: Reg
	generic(ADDR_SIZE)
	port(rst, cw(CW_S1_LATCH), clk, s1_npc, s2_npc);
	
	-- PIPELINE STAGE 2: [ID]
	ir_out <= s2_ir;	-- to Control Unit
	
	EXT_I: Extender
	generic(IMME_SIZE, DATA_SIZE)
	port(s2_ir(ISTR_SIZE-IMME_SIZE-1 downto 0), s2_immi_in);
	
	EXT_J: Extender
	generic(ISTR_SIZE-OPCD_SIZE, DATA_SIZE)
	port(s2_ir(OPCD_SIZE-1 downto 0), s2_immj_in);
	
	RF0: RegisterFile
	generic()
	port();
	
	B0: Branch
	generic()
	port(rst, s3_alu_out, s2_ir(OPCD_SIZE-1 downto 0), )
	
	-- REGISTERS : [ID]||[EXE]
	REG_NPC2: Reg
	generic(ADDR_SIZE)
	port(rst, cw(CW_S2_LATCH), clk, s2_npc, s3_npc);
	
	REG_A: Reg
	generic(DATA_SIZE)
	port(rst, cw(CW_S2_LATCH), clk, s2_a, s3_a);
	
	REG_B: Reg
	generic(DATA_SIZE)
	port(rst, cw(CW_S2_LATCH), clk, s2_b, s3_b);
	
	REG_I: Reg
	generic(DATA_SIZE)
	port(rst, cw(CW_S2_LATCH), clk, s2_i, s3_i);
	
	REG_RD: Reg
	generic(REGA_SIZE)
	port(rst, cw(CW_S2_LATCH), clk, s2_j, s3_j);
	
	-- PIPELIE STAGE 3 : [EXE]
	MUX_A: Mux
	generic()
	port();
	
	MUX_B: Mux
	generic()
	port();
	
	ALU0: Alu
	generic()
	port();
	
	-- REGISTERS : [EXE]||[MEM]
	REG_ALU: Reg
	generic()
	port();
	
	REG_BB: Reg
	generic()
	port();
	
	-- PIPELINE STAGE 4 : [MEM]
	-- Signals to Data RAM
	data_addr <= s3_alu_out;
	data_i_val <= s4_b;
	s4_mem_out <= data_o_val;
	dr_cw <= cw(S4_RW_DRAM);
	
	-- REGISTERS : [MEM]||[WB]
	REG_ALU_5: Reg
	generic()
	port();
	
	REG_MEM_5: Reg
	generic()
	port();
	
	REG_RD_5: Reg
	generic()
	port();
	
	-- PIPELINE STAGE 5 : [WB]
	MUX_WB: Mux
	generic()
	port();
	
end data_path_arch;
