--------------------------------------------------------------------------------
-- FILE: FullAdder
-- DESC: 1 bit Full Adder
--
-- Author:
-- Create: 2015-05-25
-- Update: 2015-05-27
-- Status: TESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity FullAdder is
	port(
		ci: in std_logic;
		a: in std_logic;
		b: in std_logic;
		s: out std_logic;
		co: out std_logic
	);
end FullAdder;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture full_adder_arch of FullAdder is
begin
	s <= a xor b xor ci;
	co <= (a and b) or (ci and (a xor b));
end full_adder_arch;
