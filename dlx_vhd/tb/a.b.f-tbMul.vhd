--------------------------------------------------------------------------------
-- FILE: tbMul
-- DESC: Testbench for Multiplier
-- 
-- Author: 
-- Create: 2015-05-24
-- Update: 2015-05-24
-- Status: UNTESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity tbMul is
end tbMul;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture behav of tbMul is
	constant N: integer :=16;
	constant S: integer :=4;
	signal clk: std_logic := '0';
	signal rst: std_logic := '1';
	signal ia: std_logic_vector(N-1 downto 0):=x"0000";
	signal ib: std_logic_vector(N-1 downto 0):=x"0000";
	signal oy: std_logic_vector(2*N-1 downto 0):=x"00000000";
	component Mul is
		generic (
			DATA_SIZE	: integer := C_SYS_DATA_SIZE/2;
			STAGE		: integer := C_MUL_STAGE
		);
		port (
			rst: in std_logic;
			clk: in std_logic;
			a : in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');	-- Data A
			b : in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');	-- Data B
			o : out std_logic_vector(DATA_SIZE*2-1 downto 0):=(others=>'0')	-- Data Out
		);
	end component;
begin
	MUL0: Mul
	generic map (N, S)
	port map (rst, clk, ia, ib, oy);

	-- Clock generator
	PCLOCK : process(clk)
	begin
		clk <= not(clk) after 0.5 ns;	
	end process;
	
	-- Reset test
	rst <= '0', '1' after 2 ns;
	
	ia<=x"0000", x"0001" after 1 ns, x"f010" after 2 ns, x"84d2" after 3 ns, x"3952" after 4 ns, x"ffff" after 5 ns, x"efff" after 6 ns;
	ib<=x"0000", x"0001" after 1 ns, x"00e0" after 2 ns, x"5a25" after 3 ns, x"a7ff" after 4 ns, x"ffff" after 5 ns, x"efff" after 6 ns;
end behav;

configuration tb_mul_cfg of tbMul is
	for behav
	end for;
end tb_mul_cfg;
