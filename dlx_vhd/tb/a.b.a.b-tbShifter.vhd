library ieee;
use ieee.std_logic_1164.all;
use work.Consts.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity tbShifter is
end tbShifter;

architecture tb_shifter_arch of tbShifter is
	constant N: integer:=32;
	signal a, b : std_logic_vector(N-1 downto 0):=x"00000000";
	signal o_sll, o_srl, o_sla, o_sra, o_slr_0, o_srr_0, o_slr_1, o_srr_1: std_logic_vector(N-1 downto 0):=x"00000000";
	
	component Shifter is
		generic (
			DATA_SIZE : integer := C_SYS_DATA_SIZE
		);
		port (
			l_r : in std_logic;	-- LEFT/RIGHT
			l_a : in std_logic;	-- LOGIC/ARITHMETIC
			s_r : in std_logic;	-- SHIFT/ROTATE
			a : in std_logic_vector(DATA_SIZE-1 downto 0);
			b : in std_logic_vector(DATA_SIZE-1 downto 0);
			o : out std_logic_vector(DATA_SIZE-1 downto 0)
		);
	end component;
begin
	SH0 : Shifter
	generic map(N)
	port map('0', '0', '0', a, b, o_sll);
	SH1 : Shifter
	generic map(N)
	port map('1', '0', '0', a, b, o_srl);	
	SH2 : Shifter
	generic map(N)
	port map('0', '1', '0', a, b, o_sla);
	SH3 : Shifter
	generic map(N)
	port map('1', '1', '0', a, b, o_sra);
	SH4 : Shifter
	generic map(N)
	port map('0', '0', '1', a, b, o_slr_0);
	SH5 : Shifter
	generic map(N)
	port map('1', '0', '1', a, b, o_srr_0);
	SH6 : Shifter
	generic map(N)
	port map('0', '1', '1', a, b, o_slr_1);
	SH7 : Shifter
	generic map(N)
	port map('1', '1', '1', a, b, o_srr_1);
	
	a <= x"ffffffff", x"04532434" after 1 ns, x"2234e826" after 2 ns, x"a323f443" after 3 ns, x"8b651a8b" after 4 ns, x"ffffffff" after 5 ns;
	b <= x"00000001", x"05335f28" after 1.5 ns, x"23323424" after 2.5 ns, x"11645030" after 3.5 ns, x"030035a6" after 4.5 ns, x"00000001" after 5.5 ns, x"12334224" after 7 ns;
end tb_shifter_arch;

configuration tb_shifter_cfg of tbShifter is
	for tb_shifter_arch
	end for;
end tb_shifter_cfg;
