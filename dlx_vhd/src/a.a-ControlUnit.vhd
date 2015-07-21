--------------------------------------------------------------------------------
-- FILE: ControlUnit
-- DESC: Control unit of DLX
--
-- Author:
-- Create: 2015-06-01
-- Update: 2015-06-02
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
entity ControlUnit is
	generic(
		ISTR_SIZE	: integer := C_SYS_ISTR_SIZE;			-- Instruction Register Size
		DATA_SIZE	: integer := C_SYS_DATA_SIZE;			-- Data Size
		OPCD_SIZE	: integer := C_SYS_OPCD_SIZE;			-- Op Code Size
		FUNC_SIZE	: integer := C_SYS_FUNC_SIZE;			-- Func Field Size for R-Type Ops
		CWRD_SIZE	: integer := C_SYS_CWRD_SIZE;			-- Control Word Size
		CALU_SIZE	: integer := C_CTR_CALU_SIZE			-- ALU Op Code Word Size
	);
	port(
		clk		: in  std_logic;
		rst		: in  std_logic;
		ir		: in std_logic_vector(ISTR_SIZE-1 downto 0):=(others=>'0');
		reg_a	: in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
		s2_branch_wait	: in std_logic;
		s3_reg_a_wait	: in std_logic;
		s3_reg_b_wait	: in std_logic;
		cw		: out std_logic_vector(CWRD_SIZE-1 downto 0);
		calu	: out std_logic_vector(CALU_SIZE-1 downto 0)
	);
end ControlUnit;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture control_unit_arch of ControlUnit is
	component CwGenerator is
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
			opcd	: in std_logic_vector(OPCD_SIZE-1 downto 0);
			func	: in std_logic_vector(FUNC_SIZE-1 downto 0);
			stall1	: in std_logic;
			stall2	: in std_logic;
			stall3	: in std_logic;
			stall4	: in std_logic;
			stall5	: in std_logic;
			cw		: out std_logic_vector(CWRD_SIZE-1 downto 0);
			calu	: out std_logic_vector(CALU_SIZE-1 downto 0)
		);
	end component;
	component StallGenerator is
		generic(
			CWRD_SIZE : integer := C_SYS_CWRD_SIZE
		);
		port(
			rst				: in std_logic;
			clk				: in std_logic;
			s2_branch_taken	: in std_logic := '0';
			s2_branch_wait	: in std_logic := '0';
			s3_reg_a_wait	: in std_logic := '0';
			s3_reg_b_wait	: in std_logic := '0';
			stall1			: out std_logic := '0';
			stall2			: out std_logic := '0';
			stall3			: out std_logic := '1';
			stall4			: out std_logic := '1';
			stall5			: out std_logic := '1'
		);
	end component;
	component Branch is
		generic (
			DATA_SIZE : integer := C_SYS_DATA_SIZE;
			OPCD_SIZE : integer := C_SYS_OPCD_SIZE
		);
		port (
			reg_a	: in std_logic_vector(DATA_SIZE-1 downto 0);
			opcd	: in std_logic_vector(OPCD_SIZE-1 downto 0);
			taken	: out std_logic := '0'
		);
	end component;
	
	signal stall1 : std_logic;
	signal stall2 : std_logic;
	signal stall3 : std_logic;
	signal stall4 : std_logic;
	signal stall5 : std_logic;
	signal s2_branch_taken : std_logic;
	
begin
	CW_GEN: CwGenerator
	generic map(DATA_SIZE, OPCD_SIZE, FUNC_SIZE, CWRD_SIZE, CALU_SIZE)
	port map(clk, rst, ir(ISTR_SIZE-1 downto ISTR_SIZE-OPCD_SIZE), ir(FUNC_SIZE-1 downto 0), stall1, stall2, stall3, stall4, stall5, cw, calu);
	
	S_GEN: StallGenerator
	generic map(CWRD_SIZE)
	port map(rst, clk, s2_branch_taken, s2_branch_wait, s3_reg_a_wait, s3_reg_b_wait, stall1, stall2, stall3, stall4, stall5);
	
	BR	: Branch
	generic map(DATA_SIZE, OPCD_SIZE)
	port map(reg_a, ir(ISTR_SIZE-1 downto ISTR_SIZE-OPCD_SIZE), s2_branch_taken);
	
end control_unit_arch;
