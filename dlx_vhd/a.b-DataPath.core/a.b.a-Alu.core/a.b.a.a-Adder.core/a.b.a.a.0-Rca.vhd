--------------------------------------------------------------------------------
-- FILE: Rca
-- DESC: N bits Ripple Carry Adder
--
-- Author:
-- Create: 2015-05-25
-- Update: 2015-05-25
-- Status: TESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity Rca is
	generic(
		DATA_SIZE : integer := C_SYS_DATA_SIZE
	);
	port(
		ci: in std_logic;
		a: in std_logic_vector(DATA_SIZE-1 downto 0);
		b: in std_logic_vector(DATA_SIZE-1 downto 0);
		s: out std_logic_vector(DATA_SIZE-1 downto 0);
		co: out std_logic
	);
end Rca;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture rca_arch of Rca is
	component FullAdder is
		port(
			ci: in std_logic;
			a: in std_logic;
			b: in std_logic;
			s: out std_logic;
			co: out std_logic
		);
	end component;
	signal carry: std_logic_vector(DATA_SIZE downto 0);
begin
	GE: for i in 0 to DATA_SIZE-1 generate
		GE1:if i=0 generate
			FA1: FullAdder port map (ci, a(i), b(i), s(i), carry(i+1));
		end generate;
		GE3:if i>0 generate
			FA3: FullAdder port map (carry(i), a(i), b(i), s(i), carry(i+1));
		end generate;
	end generate;
	co <= carry(DATA_SIZE);
end rca_arch;
