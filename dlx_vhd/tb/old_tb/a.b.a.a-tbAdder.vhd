library ieee;
use ieee.std_logic_1164.all;
use work.Consts.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity tbAdder is
end tbAdder;

architecture tb_adder_arch of tbAdder is
	constant N: integer:=32;
	signal a, b, s1: std_logic_vector(N-1 downto 0):=x"00000000";
	signal cin, cout1: std_logic:='0';
	
	component Adder is
		generic(
			DATA_SIZE : integer := C_SYS_DATA_SIZE
		);
		port(
			cin : in std_logic;
			a, b : in std_logic_vector(DATA_SIZE-1 downto 0);
			s : out std_logic_vector(DATA_SIZE-1 downto 0);
			cout : out std_logic
		);
	end component;
begin
	ADDER1 : Adder
	generic map(N)
	port map(cin, a, b, s1, cout1);
	
	a <= x"ffffffff", x"04532434" after 1 ns, x"2234e826" after 2 ns, x"a323f443" after 3 ns, x"8b651a8b" after 4 ns, x"ffffffff" after 5 ns;
	b <= x"00000001", x"05335f28" after 1.5 ns, x"23323424" after 2.5 ns, x"11645030" after 3.5 ns, x"030035a6" after 4.5 ns, x"00000001" after 5.5 ns, x"12334224" after 7 ns;
	cin <= '0', '1' after 3.3 ns, '0' after 4.6 ns, '1' after 6 ns;
end tb_adder_arch;

configuration tb_adder_cfg of tbAdder is
	for tb_adder_arch
	end for;
end tb_adder_cfg;
