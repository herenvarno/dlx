library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;
use work.Consts.all;
use work.Funcs.all;

entity tbControlUnit is
end tbControlUnit;

architecture tb_control_unit_arch of tbControlUnit is
	constant ISTR_SIZE : integer := C_SYS_ISTR_SIZE;
	constant DATA_SIZE : integer := C_SYS_DATA_SIZE;
	constant OPCD_SIZE : integer := C_SYS_OPCD_SIZE;
	constant FUNC_SIZE : integer := C_SYS_FUNC_SIZE;
	constant CWRD_SIZE : integer := C_SYS_CWRD_SIZE;
	constant CALU_SIZE : integer := C_CTR_CALU_SIZE;
	constant REG_ADDR_SIZE : integer := MyLog2Ceil(C_REG_NUM);
	
	component ControlUnit
		generic(
			ISTR_SIZE	: integer := C_SYS_ISTR_SIZE;			-- Instruction Register Size
			DATA_SIZE	: integer := C_SYS_DATA_SIZE;			-- Data Size
			OPCD_SIZE	: integer := C_SYS_OPCD_SIZE;			-- Op Code Size
			FUNC_SIZE	: integer := C_SYS_FUNC_SIZE;			-- Func Field Size for R-Type Ops
			CWRD_SIZE	: integer := C_SYS_CWRD_SIZE;			-- Control Word Size
			CALU_SIZE	: integer := C_CTR_CALU_SIZE;			-- ALU Op Code Word Size
			REG_ADDR_SIZE : integer := MyLog2Ceil(C_REG_NUM)	-- Control Word Size
		);
		port(
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
	end component;

	signal rst			: std_logic;
	signal clk			: std_logic;
	signal ir			: std_logic_vector(ISTR_SIZE-1 downto 0);
	signal reg_a		: std_logic_vector(DATA_SIZE-1 downto 0);
	signal alu_o		: std_logic_vector(DATA_SIZE-1 downto 0);
	signal wb_o			: std_logic_vector(DATA_SIZE-1 downto 0);
	signal cw			: std_logic_vector(CWRD_SIZE-1 downto 0);
	signal calu			: std_logic_vector(CALU_SIZE-1 downto 0);
	signal reg4_addr_in : std_logic_vector(REG_ADDR_SIZE downto 0);
	signal reg5_addr_in : std_logic_vector(REG_ADDR_SIZE downto 0)
	
begin
	CU0: ControlUnit
	generic map(ISTR_SIZE, DATA_SIZE, OPCD_SIZE, FUNC_SIZE, CWRD_SIZE, CALU_SIZE, REG_ADDR_SIZE)
	port map(clk, rst, ir, reg_a, alu_o, wb_o, cw, calu, reg4_addr_in, reg5_addr_in);

	CLK0: process(clk)
	begin
		clk = not (clk);
	end process;
	
	rst <= '0', '1' after 1 ns;
end tb_control_unit_arch;

configuration tb_control_unit_cfg of tbControlUnit is
	for tb_control_unit_arch
	end for;
end tb_control_unit_cfg;

