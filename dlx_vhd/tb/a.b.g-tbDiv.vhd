--------------------------------------------------------------------------------
-- FILE: tbDiv
-- DESC: Testbench for Divider
-- 
-- Author: 
-- Create: 2015-09-10
-- Update: 2015-09-10
-- Status: UNTESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity tbDiv is
end tbDiv;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture behav of tbDiv is
	constant N: integer :=32;
	constant S: integer :=10;
	signal clk: std_logic := '0';
	signal rst: std_logic := '1';
	signal en: std_logic:='0';
	signal ia: std_logic_vector(N-1 downto 0):=x"00000000";
	signal ib: std_logic_vector(N-1 downto 0):=x"00000000";
	signal oy: std_logic_vector(N-1 downto 0):=x"00000000";
	component Div is
		generic (
			DATA_SIZE	: integer := C_SYS_DATA_SIZE;
			STAGE		: integer := C_DIV_STAGE
		);
		port (
			rst: in std_logic;
			clk: in std_logic;
			en: in std_logic:='0';
			a : in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');	-- Data A
			b : in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');	-- Data B
			o : out std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0')	-- Data Out
		);
	end component;
begin
	DIV0: Div
	generic map (N, S)
	port map (rst, clk, en, ia, ib, oy);

	-- Clock generator
	PCLOCK : process(clk)
	begin
		clk <= not(clk) after 0.5 ns;	
	end process;
	
	-- Reset test
	rst <= '0', '1' after 2 ns;
	en <= '0', '1' after 3 ns, '0' after 15 ns;
	ia<=x"00000000", x"ff05070e" after 1 ns;
	ib<=x"00000001", x"244398fe" after 1 ns;
end behav;

configuration tb_div_cfg of tbDiv is
	for behav
	end for;
end tb_div_cfg;
