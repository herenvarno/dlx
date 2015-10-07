--------------------------------------------------------------------------------
-- FILE: tbDlx
-- DESC: Testbench for DLX
-- 
-- Author: 
-- Create: 2015-05-24
-- Update: 2015-05-24
-- Status: UNTESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity tbDlx is
end tbDlx;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture tb_dlx_arch of tbDlx is
	signal clk: std_logic := '0';
	signal rst: std_logic := '0';

	component Dlx
		generic (
			ADDR_SIZE : integer := C_SYS_ADDR_SIZE;
			DATA_SIZE : integer := C_SYS_DATA_SIZE;
			ISTR_SIZE : integer := C_SYS_ISTR_SIZE;
			DRCW_SIZE : integer := C_CTR_DRCW_SIZE
		);
		port (
			clk : in std_logic := '0';
			rst : in std_logic := '0';	-- Active Low
		
			en_iram: out std_logic:='1';
			pc_bus : out std_logic_vector(ADDR_SIZE-1 downto 0):=(others=>'0');
			ir_bus : in  std_logic_vector(ISTR_SIZE-1 downto 0):=(others=>'0');
		
			en_dram  : out std_logic:='1';
			addr_bus : out std_logic_vector(ADDR_SIZE-1 downto 0):=(others=>'0');
			di_bus   : out std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
			do_bus   : in  std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
			dr_cw    : out std_logic_vector(DRCW_SIZE-1 downto 0):=(others=>'0')
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
	constant ADDR_SIZE : integer := C_SYS_ADDR_SIZE;
	constant DATA_SIZE : integer := C_SYS_DATA_SIZE;
	constant ISTR_SIZE : integer := C_SYS_ISTR_SIZE;
	constant DRCW_SIZE : integer := C_CTR_DRCW_SIZE;
	signal ir_bus	: std_logic_vector(ISTR_SIZE-1 downto 0):=(others=>'0');
	signal pc_bus	: std_logic_vector(ADDR_SIZE-1 downto 0):=(others=>'0');
	signal di_bus	: std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
	signal do_bus	: std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
	signal addr_bus : std_logic_vector(ADDR_SIZE-1 downto 0):=(others=>'0');
	signal dr_cw	: std_logic_vector(DRCW_SIZE-1 downto 0):=(others=>'0');
	signal en_iram  : std_logic:='1';
	signal en_dram  : std_logic:='1';
begin
	-- DLX Processor
	DLX0: Dlx
	generic map(ADDR_SIZE,DATA_SIZE,ISTR_SIZE,DRCW_SIZE)
	port map (clk, rst, en_iram, pc_bus, ir_bus, en_dram, addr_bus, di_bus, do_bus, dr_cw);
	
	-- Clock generator
	PCLOCK : process(clk)
	begin
		clk <= not(clk) after 0.5 ns;
	end process;
	
	-- Reset test
	rst <= '0', '1' after 2 ns;
	
	IR0: InstructionRam
	generic map(ADDR_SIZE, ISTR_SIZE)
	port map(rst, clk, en_iram, pc_bus, ir_bus);
	
	DR0: DataRam
	generic map(DRCW_SIZE, ADDR_SIZE, DATA_SIZE)
	port map(rst, clk, en_dram, addr_bus, di_bus, do_bus, dr_cw);
end tb_dlx_arch;

--------------------------------------------------------------------------------
-- CONFIGURATION
--------------------------------------------------------------------------------
configuration tb_dlx_cfg of tbDlx  is
	for tb_dlx_arch
	end for;
end tb_dlx_cfg;

