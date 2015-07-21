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
		reg_a	: in std_logic_vector(DATA_SIZE-1 downto 0);
		opcd	: in std_logic_vector(OPCD_SIZE-1 downto 0);
		taken	: out std_logic := '0'
	);
end Branch;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture branch_arch of Branch is
begin
	P0: process(reg_a, opcd)
	begin
		if (reg_a=(reg_a'range=>'0') and opcd=OPCD_BEQZ) or (reg_a/=(reg_a'range=>'0') and opcd=OPCD_BNEZ) then
			taken <= '1';
		else
			taken <= '0';
		end if;
	end process;
end branch_arch;
