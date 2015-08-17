--------------------------------------------------------------------------------
-- FILE: Branch
-- DESC: The branch unit, decide whether a branch instruction should be taken or not
--
-- Author:
-- Create: 2015-06-03
-- Update: 2015-06-03
-- Status: UNTESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity Branch is
	generic (
		DATA_SIZE : integer := C_SYS_DATA_SIZE;
		OPCD_SIZE : integer := C_SYS_OPCD_SIZE
	);
	port (
		rst		: in std_logic;
		clk		: in std_logic;
		reg_a	: in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
		ld_a	: in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
		opcd	: in std_logic_vector(OPCD_SIZE-1 downto 0):=(others=>'0');
		sig_bal	: in std_logic:='0';
	  	sig_bpw	: out std_logic :='0';
		sig_brt	: out std_logic :='0'
	);
end Branch;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture branch_arch of Branch is
	signal sig_brt_tmp, sig_brt_delay, sig_bal_delay: std_logic:='0';
	signal opcd_delay: std_logic_vector(OPCD_SIZE-1 downto 0):=(others=>'0');
begin
	P0: process(rst, reg_a, opcd)
	begin
		if rst='0' then
			sig_brt <= '0';
			sig_brt_tmp <= '0';
		else
			if sig_bal='1' then
				sig_brt <= '0';
				sig_brt_tmp <= '0';			-- Static prediction NOT TAKEN
			else
				if ((reg_a=(reg_a'range=>'0')) and (opcd=OPCD_BEQZ)) or ((reg_a/=(reg_a'range=>'0')) and (opcd=OPCD_BNEZ)) then
					sig_brt <= '1';
					sig_brt_tmp <= '1';
				else
					sig_brt <= '0';
					sig_brt_tmp <= '0';
				end if;
			end if;
		end if;
		
	end process;
	
	P1: process(rst, ld_a, opcd_delay)
	begin
		if rst='0' then
			sig_bpw <= '0';
		else
			if sig_bal_delay='1' then
				if (ld_a=(ld_a'range=>'0') and opcd_delay=OPCD_BEQZ and sig_brt_delay='1') or (ld_a/=(reg_a'range=>'0') and opcd_delay=OPCD_BNEZ and sig_brt_delay='1') then
					sig_bpw <= '0';
				else
					sig_bpw <= '1';
				end if;
			else
				sig_bpw <= '0';
			end if;
		end if;
	end process;
	
	P2: process(rst, clk)
	begin
		if rst='0' then
			sig_bal_delay <= '0';
			sig_brt_delay <= '0';
			opcd_delay <= (others=>'0');
		else
			if clk'event and clk='1' then
				sig_bal_delay <= sig_bal;
				sig_brt_delay <= sig_brt_tmp;
				opcd_delay <= opcd;
			end if;
		end if;
	end process;
			
end branch_arch;
