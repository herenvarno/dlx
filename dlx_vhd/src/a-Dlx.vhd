--------------------------------------------------------------------------------
-- FILE: Dlx
-- DESC: Toplevel of DLX micro-processor
-- 
-- Author:
-- Create: 2015-05-24
-- Update: 2015-10-03
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
entity Dlx is
	port (
		clk : in std_logic := '0';
		rst : in std_logic := '0'	-- Active Low
	);
end Dlx;

architecture dlx_arch of Dlx is
	-- Control Unit
	component ControlUnit is
		generic(
			ISTR_SIZE	: integer := C_SYS_ISTR_SIZE;			-- Instruction Register Size
			DATA_SIZE	: integer := C_SYS_DATA_SIZE;			-- Data Size
			OPCD_SIZE	: integer := C_SYS_OPCD_SIZE;			-- Op Code Size
			FUNC_SIZE	: integer := C_SYS_FUNC_SIZE;			-- Func Field Size for R-Type Ops
			CWRD_SIZE	: integer := C_SYS_CWRD_SIZE;			-- Control Word Size
			CALU_SIZE	: integer := C_CTR_CALU_SIZE;			-- ALU Op Code Word Size
			ADDR_SIZE	: integer := C_SYS_ADDR_SIZE			-- Address size
		);
		port(
			clk		: in  std_logic;
			rst		: in  std_logic;
			ir		: in std_logic_vector(ISTR_SIZE-1 downto 0):=(others=>'0');
			pc		: in std_logic_vector(ADDR_SIZE-1 downto 0):=(others=>'0');
			reg_a	: in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
			ld_a	: in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
	  		sig_bal	: in std_logic:='0';
	  		sig_bpw	: out std_logic:='0';
	  		sig_jral: in std_logic:='0';
			sig_ral	: in std_logic;
			sig_mul	: in std_logic;
			sig_div	: in std_logic;
			sig_sqrt: in std_logic;
			cw		: out std_logic_vector(CWRD_SIZE-1 downto 0);
			calu	: out std_logic_vector(CALU_SIZE-1 downto 0)
		);
	end component;
	
	-- Instruction RAM
	component InstructionRam is
		generic (
			ADDR_SIZE : integer := C_SYS_ADDR_SIZE;
			ISTR_SIZE : integer := C_SYS_ISTR_SIZE
		);
		port (
			rst  : in std_logic;
			clk  : in std_logic;
			en   : in std_logic;
			addr : in std_logic_vector(ADDR_SIZE-1 downto 0):=(others=>'0');
			iout : out std_logic_vector(ISTR_SIZE-1 downto 0)
		);
	end component;
	
	-- Data RAM 
	component DataRam is
		generic (
			DRCW_SIZE : integer := C_CTR_DRCW_SIZE;	-- Data RAM Control Word: R/W
			ADDR_SIZE : integer := C_SYS_ADDR_SIZE;
			DATA_SIZE : integer := C_SYS_DATA_SIZE
		);
		port (
			rst		: in std_logic;
			clk		: in std_logic;
			en		: in std_logic;
			addr	: in std_logic_vector(ADDR_SIZE-1 downto 0):=(others=>'0');
			din		: in std_logic_vector(DATA_SIZE-1 downto 0);
			dout	: out std_logic_vector(DATA_SIZE-1 downto 0);
			dr_cw	: in std_logic_vector(DRCW_SIZE-1 downto 0)
		);
	end component;
	
	-- Datapath (MISSING!You must include it in your final project!)
	component DataPath is
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
	  		ir_out		: out std_logic_vector(ISTR_SIZE-1 downto 0):=(others=>'0');
	  		pc_out		: out std_logic_vector(ADDR_SIZE-1 downto 0):=(others=>'0');
	  		reg_a_out	: out std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
	  		ld_a_out	: out std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
	  		data_addr	: out std_logic_vector(ADDR_SIZE-1 downto 0):=(others=>'0');
	  		data_i_val	: in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
	  		data_o_val	: out std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
	  		cw			: in std_logic_vector(CWRD_SIZE-1 downto 0):=(others=>'0');
	  		dr_cw		: out std_logic_vector(DRCW_SIZE-1 downto 0):=(others=>'0');
	  		calu		: in std_logic_vector(CALU_SIZE-1 downto 0):=(others=>'0');
	  		sig_bal		: out std_logic:='0';
	  		sig_bpw		: in std_logic:='0';
	  		sig_jral	: out std_logic:='0';
	  		sig_ral		: out std_logic:='0';
	  		sig_mul		: out std_logic:='0';
	  		sig_div		: out std_logic:='0';
	  		sig_sqrt	: out std_logic:='0'
	  	);
	end component;

	-- CONSTANTS
	constant FUNC_SIZE : integer := C_SYS_FUNC_SIZE;
	constant OPCD_SIZE : integer := C_SYS_OPCD_SIZE;
	constant ADDR_SIZE : integer := C_SYS_ADDR_SIZE;
	constant DATA_SIZE : integer := C_SYS_DATA_SIZE;
	constant ISTR_SIZE : integer := C_SYS_ISTR_SIZE;
	constant CWRD_SIZE : integer := C_SYS_CWRD_SIZE;
	constant DRCW_SIZE : integer := C_CTR_DRCW_SIZE;
	constant CALU_SIZE : integer := C_CTR_CALU_SIZE;
	constant IMME_SIZE : integer := C_SYS_IMME_SIZE;

	-- SIGNALS
	signal ir_bus	: std_logic_vector(ISTR_SIZE-1 downto 0);
	signal pc_bus	: std_logic_vector(ADDR_SIZE-1 downto 0);
	signal di_bus	: std_logic_vector(DATA_SIZE-1 downto 0);
	signal do_bus	: std_logic_vector(DATA_SIZE-1 downto 0);
	signal addr_bus : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal ir		: std_logic_vector(ISTR_SIZE-1 downto 0);
	signal pc		: std_logic_vector(ADDR_SIZE-1 downto 0);
	signal cw		: std_logic_vector(CWRD_SIZE-1 downto 0);
	signal dr_cw	: std_logic_vector(DRCW_SIZE-1 downto 0);
	signal calu		: std_logic_vector(CALU_SIZE-1 downto 0);
	signal reg_a_val: std_logic_vector(DATA_SIZE-1 downto 0);
	signal ld_a_val	: std_logic_vector(DATA_SIZE-1 downto 0);
	signal sig_bal	: std_logic:='0';
	signal sig_bpw	: std_logic:='0';
	signal sig_jral	: std_logic:='0';
	signal sig_ral	: std_logic:='0';
	signal sig_mul	: std_logic:='0';
	signal sig_div	: std_logic:='0';
	signal sig_sqrt	: std_logic:='0';
	
begin
	CU0: ControlUnit
	generic map(ISTR_SIZE, DATA_SIZE, OPCD_SIZE, FUNC_SIZE, CWRD_SIZE, CALU_SIZE)
	port map(clk, rst, ir, pc, reg_a_val, ld_a_val, sig_bal, sig_bpw, sig_jral, sig_ral, sig_mul, sig_div, sig_sqrt, cw, calu);
	
	IR0: InstructionRam
	generic map(ADDR_SIZE, ISTR_SIZE)
	port map(rst, clk, cw(CW_S1_LATCH), pc_bus, ir_bus);
	
	DR0: DataRam
	generic map(DRCW_SIZE, ADDR_SIZE, DATA_SIZE)
	port map(rst, clk, '1', addr_bus, di_bus, do_bus, dr_cw);
	
	DP0: DataPath
	generic map(ADDR_SIZE, DATA_SIZE, ISTR_SIZE, OPCD_SIZE, IMME_SIZE, CWRD_SIZE, CALU_SIZE, DRCW_SIZE)
	port map(clk, rst, pc_bus, ir_bus, ir, pc, reg_a_val, ld_a_val, addr_bus, do_bus, di_bus, cw, dr_cw, calu, sig_bal, sig_bpw, sig_jral, sig_ral, sig_mul, sig_div, sig_sqrt);
	
end dlx_arch;
