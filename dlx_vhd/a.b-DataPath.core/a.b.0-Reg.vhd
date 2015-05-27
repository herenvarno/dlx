--------------------------------------------------------------------------------
-- FILE: Reg
-- DESC: Generic asyncronous register, with RESET and ENABLE
--
-- Author:
-- Create: 2015-05-27
-- Update: 2015-05-27
-- Status: UNTESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity Reg is
	generic(
		DATA_SIZE: integer := C_SYS_DATA_SIZE
	);
	port(
		rst: in std_logic;
		en : in std_logic;
		clk: in std_logic;
		din: in std_logic_vector(DATA_SIZE-1 downto 0);
		dout: out std_logic_vector(DATA_SIZE-1 downto 0)
	);
end Reg;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture reg_arch of Reg is	-- Asyncronous
begin
	PROC2: process(clk, rst)
	begin
		if rst='0' then							-- Reset active low
			dout <= (others => '0');
		elsif rising_edge(clk) and en='1' then	-- Enable active high
			dout <= din;
		end if;
	end process;
end reg_arch;
