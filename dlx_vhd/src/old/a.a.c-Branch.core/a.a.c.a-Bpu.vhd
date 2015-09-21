--------------------------------------------------------------------------------
-- FILE: Bpu
-- DESC: The branch prediction unit
--
-- Author:
-- Create: 2015-08-18
-- Update: 2015-08-18
-- Status: UNFINISHED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity Bpu is
	generic (
		BPU_ADDR_SIZE	: C_BPU_ADDR_SIZE
	);
	port (
		rst		: in std_logic;
		clk		: in std_logic;
		en		: in std_logic;
		addr	: in std_logic_vector(BPU_ADDR_SIZE-1 downto 0);
		sig_bal	: in std_logic;
	  	sig_bpw	: in std_logic;
	  	sig_brt	: out std_logic
	);
end Bpu;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture bpu_arch of Bpu is
	signal sig_bal_delay: std_logic:='0';
	signal sig_brt_delay: std_logic:='0';
	signal addr_delay: std_logic_vector(BPU_ADDR_SIZE-1 downto 0):=(others=>'0');
begin
	P_OUT: process(sig_bal, addr)
	begin
		if sig_bal='1' then
			index <= to_integer(unsigned(addr));
			history <= bht(index);
			sig_brt <= history(1);
			sig_brt_tmp <= history(1);
		end if;
	end process;
	
	P_UPD: process(sig_bal_delay, sig_bpw)
	begin
		if sig_bal_delay='1' then
			if sig_bpw='1' then
				history 
		
