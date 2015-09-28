--------------------------------------------------------------------------------
-- FILE: Sipo
-- DESC: Generic Serial in paralle out, with RESET and ENABLE
--
-- Author:
-- Create: 2015-09-09
-- Update: 2015-09-09
-- Status: UNTESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity Sipo is
	generic(
		DATA_SIZE: integer := C_SYS_DATA_SIZE
	);
	port(
		rst: in std_logic;
		en : in std_logic;
		clk: in std_logic;
		din: in std_logic;
		dout: out std_logic_vector(DATA_SIZE-1 downto 0)
	);
end Sipo;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture sipo_arch of Sipo is	-- Asyncronous
	signal data: std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
begin
	PROC0: process(clk, rst)
	begin
		if rst='0' then							-- Reset active low
			dout <= (others => '0');
		elsif rising_edge(clk) and en='1' then	-- Enable active high
			dout <= data;
		end if;
	end process;
	
	data(0) <= din and rst;
	GE0: for i in 0 to DATA_SIZE-2 generate
	begin
		PROC1: process(rst, en, clk, data(i))
		begin
			if rising_edge(clk) then
				if en='1' and rst='1' then
					data(i+1) <= data(i);
				elsif rst='0' then
					data(i+1) <= '0';
				end if;
			end if;
		end process;
	end generate;
end sipo_arch;
