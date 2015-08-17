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
		ld_a	: in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
	  	sig_bal	: in std_logic:='0';
	  	sig_bpw	: out std_logic:='0';
	  	sig_jral: in std_logic:='0';
		sig_ral	: in std_logic;
		sig_mul	: in std_logic;
		sig_div	: in std_logic;
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
			stall_flag	: in std_logic_vector(4 downto 0);
			taken	: in std_logic;
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
			sig_ral			: in std_logic := '0';		-- from DataPath
			sig_bpw			: in std_logic := '0';		-- from Branch
			sig_jral		: in std_logic := '0';		-- from DataPath
			sig_mul			: in std_logic := '0';		-- from CwGenerator
			sig_div			: in std_logic := '0';		-- from CwGenerator
			stall_flag		: out std_logic_vector(4 downto 0):=(others=>'0')
		);
	end component;
	component Branch is
		generic (
			DATA_SIZE : integer := C_SYS_DATA_SIZE;
			OPCD_SIZE : integer := C_SYS_OPCD_SIZE
		);
		port (
			rst		: in std_logic;
			clk		: in std_logic;
			reg_a	: in std_logic_vector(DATA_SIZE-1 downto 0);
			ld_a	: in std_logic_vector(DATA_SIZE-1 downto 0);
			opcd	: in std_logic_vector(OPCD_SIZE-1 downto 0);
			sig_bal	: in std_logic:='0';
	  		sig_bpw	: out std_logic :='0';
			sig_brt	: out std_logic :='0'
		);
	end component;
	
	signal stall_flag : std_logic_vector(4 downto 0);
	signal sig_brt : std_logic;
	signal en_branch : std_logic;
	signal sig_bpw_tmp: std_logic;
	
begin
	CW_GEN: CwGenerator
	generic map(DATA_SIZE, OPCD_SIZE, FUNC_SIZE, CWRD_SIZE, CALU_SIZE)
	port map(clk, rst, ir(ISTR_SIZE-1 downto ISTR_SIZE-OPCD_SIZE), ir(FUNC_SIZE-1 downto 0), stall_flag, sig_brt, cw, calu);
	
	S_GEN: StallGenerator
	generic map(CWRD_SIZE)
	port map(rst, clk, sig_ral, sig_bpw_tmp, sig_jral, sig_mul, sig_div, stall_flag);
	
	BR	: Branch
	generic map(DATA_SIZE, OPCD_SIZE)
	port map(rst, clk, reg_a, ld_a, ir(ISTR_SIZE-1 downto ISTR_SIZE-OPCD_SIZE), sig_bal, sig_bpw_tmp, sig_brt);
	
	sig_bpw <= sig_bpw_tmp;
	
end control_unit_arch;
