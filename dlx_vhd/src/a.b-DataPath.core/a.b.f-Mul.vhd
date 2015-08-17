--------------------------------------------------------------------------------
-- FILE: Mul
-- DESC: Multiplier
--
-- Author:
-- Create: 2015-08-14
-- Update: 2015-08-14
-- Status: UNFINISHED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity Mul is
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
end Mul;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture mul_arch_struct of Mul is
	component BoothMul is
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
	BM0: BoothMul
	generic map (DATA_SIZE, STAGE)
	port map (rst, clk, a, b, o);
end mul_arch_struct;
