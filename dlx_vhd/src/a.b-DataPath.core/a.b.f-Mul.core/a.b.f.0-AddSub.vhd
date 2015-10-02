--------------------------------------------------------------------------------
-- FILE: BoothMul
-- DESC: Booth's Multiplier
--
-- Author:
-- Create: 2015-08-16
-- Update: 2015-08-16
-- Status: TESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity AddSub is
	generic(
		DATA_SIZE	: integer := C_SYS_DATA_SIZE
	);
	port(
		as: in std_logic;									-- Add(Active High)/Sub(Active Low)
		a, b: in std_logic_vector(DATA_SIZE-1 downto 0);	-- Operands
		re: out std_logic_vector(DATA_SIZE-1 downto 0);	-- Return value
		cout: out std_logic								-- Carry
	);
end AddSub;

--------------------------------------------------------------------------------
-- ARCHITECURE
--------------------------------------------------------------------------------
architecture add_sub_arch of AddSub is
	component Adder is
		generic(
			DATA_SIZE : integer := C_SYS_DATA_SIZE
		);
		port(
			cin: in std_logic;
			a, b: in std_logic_vector(DATA_SIZE-1 downto 0);
			s : out std_logic_vector(DATA_SIZE-1 downto 0);
			cout: out std_logic
		);
	end component;

	signal b_new : std_logic_vector(DATA_SIZE-1 downto 0);
	signal as_arr: std_logic_vector(DATA_SIZE-1 downto 0);
begin
	as_arr <= (others=>as);
	b_new <= b xor as_arr;
	
	ADDER0: Adder
	generic map(DATA_SIZE)
	port map(as, a, b_new, re, cout);
end add_sub_arch;
