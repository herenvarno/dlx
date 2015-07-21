library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;
use work.Consts.all;
use work.Funcs.all;

entity tbDataRam is
end tbDataRam;

architecture tb_data_ram_arch of tbDataRam is
	constant DRCW_SIZE : integer := C_CTR_DRCW_SIZE;
	constant ADDR_SIZE : integer := C_SYS_ADDR_SIZE;
	constant DATA_SIZE : integer := C_SYS_DATA_SIZE;
	
	component DataRam is
		generic (
			DRCW_SIZE : integer := C_CTR_DRCW_SIZE;	-- Data RAM Control Word: R/W
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
	
	signal rst			: std_logic;
	signal addr			: std_logic_vector(ADDR_SIZE-1 downto 0):=x"00000000";
	signal din			: std_logic_vector(DATA_SIZE-1 downto 0);
	signal dout0		: std_logic_vector(DATA_SIZE-1 downto 0);
	signal dout1		: std_logic_vector(DATA_SIZE-1 downto 0);
	signal dout2		: std_logic_vector(DATA_SIZE-1 downto 0);
	signal ctrl0		: std_logic_vector(DRCW_SIZE-1 downto 0);
	signal ctrl1		: std_logic_vector(DRCW_SIZE-1 downto 0);
	signal ctrl2		: std_logic_vector(DRCW_SIZE-1 downto 0);
begin
	DRAM0: DataRam
	port map(rst, addr, din, dout0, ctrl0);
	DRAM1: DataRam
	port map(rst, addr, din, dout1, ctrl1);
	DRAM2: DataRam
	port map(rst, addr, din, dout2, ctrl2);

	rst <= '0', '1' after 1 ns;
	ctrl0(2) <= '1', '0' after 6 ns;
	ctrl1(2) <= '1', '0' after 6 ns;
	ctrl2(2) <= '1', '0' after 6 ns;
	ctrl0(1 downto 0) <= "00";
	ctrl1(1 downto 0) <= "01";
	ctrl2(1 downto 0) <= "10";
	addr <= x"00000000", x"00000001" after 2 ns, x"00000002" after 3 ns, x"00000003" after 4 ns, x"00000004" after 5 ns, x"00000006" after 7 ns, x"00000007" after 8 ns, x"00000008" after 9 ns, x"00000009" after 10 ns;
	din <=  x"00805060", x"08010001" after 2 ns, x"12f67002" after 3 ns, x"02028003" after 4 ns, x"08900204" after 5 ns, x"34502005" after 6 ns, x"030b2003" after 7 ns, x"01034602" after 8 ns, x"0f0a4601" after 9 ns, x"04660040" after 10 ns, x"0000000a" after 11 ns; 
	
end tb_data_ram_arch;

configuration tb_data_ram_cfg of tbDataRam is
	for tb_data_ram_arch
	end for;
end tb_data_ram_cfg;
