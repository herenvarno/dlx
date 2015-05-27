--------------------------------------------------------------------------------
-- FILE: P4Adder
-- DESC: The Adder used in P4 micro-processor
--
-- Author:
-- Create: 2015-05-27
-- Update: 2015-05-27
-- Status: TESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity P4Adder is
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
end P4Adder;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture p4_adder_arch of P4Adder is
	component P4CarryGenerator is
		generic(
			DATA_SIZE: integer := C_SYS_DATA_SIZE;
			SPARSITY: integer := C_ADD_SPARSITY
		);
		port(
			a, b: in std_logic_vector(DATA_SIZE-1 downto 0);
			cin: in std_logic;
			cout: out std_logic_vector(DATA_SIZE/SPARSITY-1 downto 0)
		);
	end component;
	component AdderSumGenerator is
		generic (
			DATA_SIZE : integer := C_SYS_DATA_SIZE;
			SPARSITY  : integer := C_ADD_SPARSITY
		);
		port (
			a, b: in std_logic_vector(DATA_SIZE-1 downto 0);
			cin: in std_logic_vector(DATA_SIZE/SPARSITY-1 downto 0);
			sum: out std_logic_vector(DATA_SIZE-1 downto 0)
		);
	end component;
	signal carry : std_logic_vector(DATA_SIZE/SPARSITY downto 0);
begin
	carry(0) <= cin;
	
	CG0: P4CarryGenerator
	generic map (DATA_SIZE, SPARSITY)
	port map(a, b, cin, carry(DATA_SIZE/SPARSITY downto 1));
	
	SG0: AdderSumGenerator
	generic map (DATA_SIZE, SPARSITY)
	port map(a, b, carry(DATA_SIZE/SPARSITY-1 downto 0), s);
	
	cout <= carry(DATA_SIZE/SPARSITY);
end p4_adder_arch;
