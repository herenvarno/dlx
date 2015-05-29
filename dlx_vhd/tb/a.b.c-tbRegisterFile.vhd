library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Consts.all;
use work.Funcs.all;

entity tbRegisterFile is
end tbRegisterFile;

architecture tb_register_file_arch of tbRegisterFile is
       signal clk: std_logic := '0';
       signal rst: std_logic;
       signal en: std_logic;
       signal rd1_en: std_logic;
       signal rd2_en: std_logic;
       signal wr_en: std_logic;
       signal rd1_addr: std_logic_vector(4 downto 0);
       signal rd2_addr: std_logic_vector(4 downto 0);
       signal wr_addr: std_logic_vector(4 downto 0);
       signal d_out1: std_logic_vector(31 downto 0);
       signal d_out2: std_logic_vector(31 downto 0);
       signal d_in: std_logic_vector(31 downto 0);

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

begin 

	RG:RegisterFile
	generic map(32, 32)
	port map (clk, rst, en, rd1_en, rd2_en, wr_en, rd1_addr, rd2_addr, wr_addr, d_out1, d_out2, d_in);
	
	rst <= '0','1' after 5 ns;
	en <= '0','1' after 3 ns;
	wr_en <= '0','1' after 6 ns, '0' after 7 ns, '1' after 10 ns, '0' after 20 ns;
	rd1_en <= '1','0' after 5 ns, '1' after 13 ns, '0' after 20 ns; 
	rd2_en <= '0','1' after 17 ns;
	wr_addr <= "10110", "01000" after 9 ns, "00000" after 19 ns;
	rd1_addr <="10110", "01000" after 9 ns, "00000" after 19 ns;
	rd2_addr <= "11100", "01000" after 9 ns;
	d_in<=(others => '0'),(others => '1') after 8 ns;



	PCLOCK : process(clk)
	begin
		clk <= not(clk) after 0.5 ns;	
	end process;

end tb_register_file_arch;

configuration tb_register_file_cfg of tbRegisterFile is
  for tb_register_file_arch
  end for;
end tb_register_file_cfg;
