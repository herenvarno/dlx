--------------------------------------------------------------------------------
-- FILE: Dlx
-- DESC: Toplevel of DLX micro-processor
-- 
-- Author:
-- Create: 2015-05-24
-- Update: 2015-05-24
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
entity Dlx is
	port(
		clk	: in std_logic;
		rst : in std_logic	-- active low
	);
end Dlx;

architecture dlx_arch of Dlx is
	-- Control Unit
	component ControlUnit
		generic (
			MCDB_SIZE	: integer := C_SYS_MCDB_SIZE;	-- Microcode Database Size
			FUNC_SIZE	: integer := C_SYS_FUNC_SIZE;	-- Func Field Size for R-Type Ops
			OPCD_SIZE	: integer := C_SYS_OPCD_SIZE;	-- Operation Code Size
			ISTR_SIZE	: integer := C_SYS_ISTR_SIZE;	-- Instruction Register Size    
			CWRD_SIZE	: integer := C_SYS_CWRD_SIZE	-- Control Word Size
		);
		port (
			clk		: in std_logic;
			rst		: in std_logic;	-- Active-Low
			ir_in	: in std_logic_vector(ISTR_SIZE-1 downto 0);
			cw		: out std_logic_vector(CWRD_SIZE-1 downto 0)
		);
	end component;
	
	-- Instruction RAM
	component InstructionRam
		generic (
			ADDR_SIZE : integer := C_SYS_ADDR_SIZE;
			ISTR_SIZE : integer := C_SYS_ISTR_SIZE
		);
		port (
			rst  : in std_logic;
			addr : in std_logic_vector(ADDR_SIZE-1 downto 0);
			iout : out std_logic_vector(ISTR_SIZE-1 downto 0)
		);
	end component;
	
	-- Data RAM 
	component DataRam
		generic (
			DRCW_SIZE : integer := C_SYS_DRCW_SIZE;	-- Data RAM Control Word: R/W
			ADDR_SIZE : integer := C_SYS_ADDR_SIZE;
			DATA_SIZE : integer := C_SYS_DATA_SIZE
		);
		port (
			rst		: in std_logic;
			addr	: in std_logic_vector(ADDR_SIZE-1 downto 0);
			din		: in std_logic_vector(DATA_SIZE-1 downto 0);
			dout	: out std_logic_vector(DATA_SIZE-1 downto 0);
			dr_cw	: in std_logic_vector(DRCW_SIZE-1 downto 0)
		);
	end component;
	
	-- Datapath (MISSING!You must include it in your final project!)
	component DataPath
		generic (
			ADDR_SIZE : integer := C_SYS_ADDR_SIZE;
			DATA_SIZE : integer := C_SYS_DATA_SIZE;
			ISTR_SIZE : integer := C_SYS_ISTR_SIZE;
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
  	end component;

	-- CONSTANTS
	MCDB_SIZE : integer := C_SYS_MCDB_SIZE;
	FUNC_SIZE : integer := C_SYS_FUNC_SIZE;
	OPCD_SIZE : integer := C_SYS_OPCD_SIZE;
	ADDR_SIZE : integer := C_SYS_ADDR_SIZE;
	DATA_SIZE : integer := C_SYS_DATA_SIZE;
	ISTR_SIZE : integer := C_SYS_ISTR_SIZE;
	CWRD_SIZE : integer := C_SYS_CWRD_SIZE;
	DRCW_SIZE : integer := C_SYS_DRCW_SIZE;

	-- SIGNALS
	signal ir_bus	: std_logic_vector(ISTR_SIZE-1 downto 0);
	signal pc_bus	: std_logic_vector(ADDR_SIZE-1 downto 0);
	signal di_bus	: std_logic_vector(DATA_SIZE-1 downto 0);
	signal do_bus	: std_logic_vector(DATA_SIZE-1 downto 0);
	signal addr_bus : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal ir		: std_logic_vector(ISTR_SIZE-1 downto 0);
	signal cw		: std_logic_vector(CWRD_SIZE-1 downto 0);
	signal dr_cw	: std_logic_vector(DRCW_SIZE-1 downto 0);
	signal dp_cw	: std_logic_vector(DPCW_SIZE-1 downto 0);
	
begin
	CU0: ControlUnit
	generic(MCDB_SIZE, FUNC_SIZE, OPCD_SIZE, ISTR_SIZE, CWRD_SIZE)
	port(clk, rst, ir, cw);
	
	IR0: InstructionRam
	generic(ADDR_SIZE, ISTR_SIZE)
	port(rst, pc_bus, ir_bus);
	
	DR0: DataRam
	generic(DRCW_SIZE, ADDR_SIZE, DATA_SIZE)
	port(rst, addr_bus, di_bus, do_bus, dr_cw);
	
	DP0: DataPath
	generic(ADDR_SIZE, DATA_SIZE, ISTR_SIZE, CWRD_SIZE)
	prot(clk, rst, pc_bus, ir_bus, ir, addr_bus, di_bus, do_bus, cw, dr_cw);
end dlx_arch;
