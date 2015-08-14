--------------------------------------------------------------------------------
-- FILE: Shifter
-- DESC: Shift A by B bits
--
-- Author:
-- Create: 2015-05-25
-- Update: 2015-05-27
-- Status: TESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Consts.all;
use work.Funcs.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity Shifter is
	generic (
		DATA_SIZE : integer := C_SYS_DATA_SIZE
	);
	port (
		l_r : in std_logic;	-- LEFT/RIGHT
		l_a : in std_logic;	-- LOGIC/ARITHMETIC
		s_r : in std_logic;	-- SHIFT/ROTATE
		a : in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
		b : in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
		o : out std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0')
	);
end Shifter;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture shifter_arch of Shifter is
	constant B_SIZE : integer := MyLog2Ceil(DATA_SIZE);
begin
	P0: process (a, b, l_r, l_a, s_r) is
	begin
		if s_r = '1' then

			if l_r = '1' then
				o <= to_StdLogicVector((to_bitvector(a)) ror (to_integer(unsigned(b(B_SIZE-1 downto 0)))));
			else
				o <= to_StdLogicVector((to_bitvector(a)) rol (to_integer(unsigned(b(B_SIZE-1 downto 0)))));
			end if;
		else

			if l_r = '1' then

				if l_a = '1' then
					o <= to_StdLogicVector((to_bitvector(a)) sra (to_integer(unsigned(b(B_SIZE-1 downto 0)))));
				else
					o <= to_StdLogicVector((to_bitvector(a)) srl (to_integer(unsigned(b(B_SIZE-1 downto 0)))));
				end if;				
			else

				if l_a = '1' then
					o <= to_StdLogicVector((to_bitvector(a)) sla (to_integer(unsigned(b(B_SIZE-1 downto 0)))));
				else
					o <= to_StdLogicVector((to_bitvector(a)) sll (to_integer(unsigned(b(B_SIZE-1 downto 0)))));
				end if;
			end if;
		end if;
	end process;
end shifter_arch;
