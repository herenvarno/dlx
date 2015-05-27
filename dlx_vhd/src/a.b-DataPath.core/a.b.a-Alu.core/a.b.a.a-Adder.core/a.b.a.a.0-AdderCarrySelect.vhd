--------------------------------------------------------------------------------
-- FILE: AdderCarrySelect
-- DESC: Carry Select Part of Adder, typically used in P4 Adder
--
-- Author:
-- Create: 2015-05-27
-- Update: 2015-05-27
-- Status: TESTED
-------------------------------------------------------------------------------- 

library ieee;
use ieee.std_logic_1164.all;
use work.Consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity AdderCarrySelect is
	generic(
		DATA_SIZE : integer := C_SYS_DATA_SIZE
	);
	port(
		a, b: in std_logic_vector(DATA_SIZE-1 downto 0);
		sel: in std_logic;
		sum: out std_logic_vector(DATA_SIZE-1 downto 0)
	);
end AdderCarrySelect;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture adder_carry_select_arch of AdderCarrySelect is
	component Rca is
		generic(
			DATA_SIZE: integer := C_SYS_DATA_SIZE
		);
		port(
			ci: in std_logic;
			a: in std_logic_vector(DATA_SIZE-1 downto 0);
			b: in std_logic_vector(DATA_SIZE-1 downto 0);
			s: out std_logic_vector(DATA_SIZE-1 downto 0);
			co: out std_logic
		);
	end component;
	component Mux is
		generic(
			DATA_SIZE: integer := C_SYS_DATA_SIZE
		);
		port(
			sel: in std_logic;
			din0: in std_logic_vector(DATA_SIZE-1 downto 0);
			din1: in std_logic_vector(DATA_SIZE-1 downto 0);
			dout: out std_logic_vector(DATA_SIZE-1 downto 0)
		);
	end component;
	signal sum0, sum1: std_logic_vector(DATA_SIZE-1 downto 0);
begin
	RCA0: Rca
	generic map(DATA_SIZE)
	port map('0', a, b, sum0, open);
	
	RCA1: Rca
	generic map(DATA_SIZE)
	port map('1', a, b, sum1, open);
	
	MUX0: Mux
	generic map(DATA_SIZE)
	port map(sel, sum0, sum1, sum);
end adder_carry_select_arch;
	
