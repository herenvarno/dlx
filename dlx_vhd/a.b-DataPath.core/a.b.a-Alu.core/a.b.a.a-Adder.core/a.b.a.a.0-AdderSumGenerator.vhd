--------------------------------------------------------------------------------
-- FILE: AdderSumGenerator
-- DESC: The sum generator part of a Adder, typically used in P4 Adder
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
entity AdderSumGenerator is
	generic (
		DATA_SIZE : integer := C_SYS_DATA_SIZE;
		SPARSITY  : integer := C_ADD_SPARSITY
	);
	port (
		a, b: in std_logic_vector(DATA_SIZE-1 downto 0);
		cin: in std_logic_vector(DATA_SIZE/SPARSITY-1 downto 0);
		sum: out std_logic_vector(DATA_SIZE-1 downto 0)
	);
end AdderSumGenerator;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture adder_sum_generator_arch of AdderSumGenerator is
	component AdderCarrySelect is
		generic(
			DATA_SIZE : integer := C_SYS_DATA_SIZE
		);
		port(
			a, b: in std_logic_vector(DATA_SIZE-1 downto 0);
			sel: in std_logic;
			sum: out std_logic_vector(DATA_SIZE-1 downto 0)
		);
	end component;
begin
	GE0: for i in 0 to DATA_SIZE/SPARSITY-1 generate
	begin
		ACSi: AdderCarrySelect
		generic map(SPARSITY)
		port map(a((i+1)*SPARSITY-1 downto i*SPARSITY), b((i+1)*SPARSITY-1 downto i*SPARSITY), cin(i), sum((i+1)*SPARSITY-1 downto i*SPARSITY));
	end generate;
end adder_sum_generator_arch;
