--------------------------------------------------------------------------------
-- FILE: tbDlx
-- DESC: Testbench for DLX
-- 
-- Author: 
-- Create: 2015-05-24
-- Update: 2015-05-24
-- Status: UNTESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity tbDlx is
end tbDlx;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture tb_dlx_arch of tbDlx is
	signal clk: std_logic := '0';
	signal rst: std_logic := '1';

	component Dlx
		port (
			clk : in std_logic;
			rst : in std_logic	-- Active Low
		);
    end component;
begin
	-- DLX Processor
	DLX0: Dlx
	port Map (clk, rst);
	
	-- Clock generator
	PCLOCK : process(clk)
	begin
		clk <= not(clk) after 0.5 ns;	
	end process;
	
	-- Reset test
	rst <= '0', '1' after 6 ns, '0' after 11 ns, '1' after 15 ns;
end tb_dlx_arch;

--------------------------------------------------------------------------------
-- CONFIGURATION
--------------------------------------------------------------------------------
configuration tb_dlx_cfg of tbDlx  is
	for tb_dlx_arch
	end for;
end tb_dlx_cfg;

