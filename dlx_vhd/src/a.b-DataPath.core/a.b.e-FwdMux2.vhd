--------------------------------------------------------------------------------
-- FILE: FwdMux2
-- DESC: Forward Multiplexer with 2 stage forward.
--
-- Author:
-- Create: 2015-06-01
-- Update: 2015-06-01
-- Status: UNTESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Consts.all;
use work.Funcs.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity FwdMux2 is
	generic (
		DATA_SIZE : integer := C_SYS_DATA_SIZE;
		REG_ADDR_SIZE : integer := MyLog2Ceil(C_REG_NUM)
	);
	port(
		reg_c	: in std_logic_vector(DATA_SIZE-1 downto 0);
		reg_f	: in std_logic_vector(DATA_SIZE-1 downto 0);
		reg_ff	: in std_logic_vector(DATA_SIZE-1 downto 0);
		addr_c	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		addr_f	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		addr_ff	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		valid_f	: in std_logic;
		valid_ff: in std_logic;
		dirty_f	: in std_logic;
		dirty_ff: in std_logic;
		en		: in std_logic:='1';
		output	: out std_logic_vector(DATA_SIZE-1 downto 0);
		match_dirty_f	: out std_logic;
		match_dirty_ff	: out std_logic
	);
end FwdMux2;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture fwd_mux_2_arch of FwdMux2 is
begin
	P0: process(en, reg_c, reg_f, reg_ff, addr_c, addr_f, addr_ff, valid_f, valid_ff, dirty_f, dirty_ff)
		variable dmatchf: std_logic:='0';
		variable dmatchff: std_logic:='0';
	begin
		dmatchf:='0';
		dmatchff:='0';
		if en='1' then
			if addr_c=(addr_c'range=>'0') then
				output <= reg_c;
			else
				if (addr_c=addr_f) and (valid_f='1') then
					if dirty_f='1' then
						dmatchf := '1';
					end if;
					output <= reg_f;
				elsif addr_c=addr_ff and (valid_ff='1') then
					if dirty_ff='1' then
						dmatchff := '1';
					end if;
					output <= reg_ff;
				else
					output <= reg_c;
				end if;
			end if;
		
			match_dirty_f <= dmatchf;
			match_dirty_ff <= dmatchff;
		end if;
	end process;
end fwd_mux_2_arch;
