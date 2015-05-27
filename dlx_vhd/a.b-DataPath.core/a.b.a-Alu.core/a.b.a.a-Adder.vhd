--------------------------------------------------------------------------------
-- FILE: Adder
-- DESC: N bits Generic Adder
--
-- Author:
-- Create: 2015-05-25
-- Update: 2015-05-27
-- Status: TESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity Adder is
	generic(
		DATA_SIZE : integer := C_SYS_DATA_SIZE
	);
	port(
		cin: in std_logic;
		a, b: in std_logic_vector(DATA_SIZE-1 downto 0);
		s : out std_logic_vector(DATA_SIZE-1 downto 0);
		cout: out std_logic
	);
end Adder;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture adder_arch of Adder is
	component P4Adder is
		generic(
			DATA_SIZE : integer := C_SYS_DATA_SIZE;
			SPARSITY  : integer := C_ADD_SPARSITY
		);
		port(
			cin : in std_logic;
			a, b : in std_logic_vector(DATA_SIZE-1 downto 0);
			s : out std_logic_vector(DATA_SIZE-1 downto 0);
			cout : out std_logic
		);
	end component;
	constant SPARSITY : integer := C_ADD_SPARSITY;
begin
	ADDER0: P4Adder
	generic map(DATA_SIZE, SPARSITY)
	port map(cin, a, b, s, cout);
end adder_arch;
