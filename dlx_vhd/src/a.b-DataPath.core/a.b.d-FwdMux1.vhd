--------------------------------------------------------------------------------
-- FILE: FwdMux1
-- DESC: Forward Multiplexer with 1 stage forward.
--
-- Author:
-- Create: 2015-06-01
-- Update: 2015-10-03
-- Status: TESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Consts.all;
use work.Funcs.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity FwdMux1 is
	generic (
		DATA_SIZE : integer := C_SYS_DATA_SIZE;
		REG_ADDR_SIZE : integer := MyLog2Ceil(C_REG_NUM)
	);
	port(
		reg_c	: in std_logic_vector(DATA_SIZE-1 downto 0);
		reg_f	: in std_logic_vector(DATA_SIZE-1 downto 0);
		addr_c	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		addr_f	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		valid_f	: in std_logic;
		dirty_f	: in std_logic;
		output	: out std_logic_vector(DATA_SIZE-1 downto 0);
		match_dirty_f: out std_logic
	);
end FwdMux1;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture fwd_mux_1_arch of FwdMux1 is
begin
	P0: process(reg_c, reg_f, addr_c, addr_f, valid_f, dirty_f)
		variable dmatchf: std_logic:='0';
	begin
		dmatchf := '0';
		if addr_c=(addr_c'range => '0') then
			output <= reg_c;
		else
			if (addr_c=addr_f) and (valid_f='1') then
				if dirty_f='1' then
					dmatchf := '1';
				else
					dmatchf := '0';
				end if;
				output <= reg_f;
			else
				match_dirty_f<='0';
				output <= reg_c;
			end if;
		end if;
		match_dirty_f <= dmatchf;
	end process;
end fwd_mux_1_arch;
