--------------------------------------------------------------------------------
-- FILE: DataRam
-- DESC: Data Ram, Combinational structure
--
-- Author:
-- Create: 2015-05-24
-- Update: 2015-05-24
-- Status: UNTESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;
use work.Consts.all;
use work.Funcs.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity DataRam is
	generic (
		DRCW_SIZE : integer := C_SYS_DRCW_SIZE;	-- Data RAM Control Word: R/W
		ADDR_SIZE : integer := C_SYS_ADDR_SIZE;
		DATA_SIZE : integer := C_SYS_DATA_SIZE
	);
	port (
		rst		: in std_logic;
		addr	: in std_logic_vector(ADDR_SIZE-1 downto 0);
		din		: in std_logic_vector(DATA_SIZE-1 downto 0);
		dout	: out std_logic_vector(DATA_SIZE-1 downto 0);
		dr_cw	: in std_logic_vector(DRCW_SIZE-1 downto 0)
	);
end DataRam;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture data_ram_arch of DataRam is
	constant DRAM_SIZE : integer := C_RAM_DRAM_SIZE;
	type DRam_t is range(0 to DRAM_SIZE-1) of std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_area : DRam_t;
begin
	PROC: process(rst, addr, din, dr_cw)
	begin
		if rst='0' then
			for i in 0 to DRAM_SIZE-1 loop
				data_area(i) <= (others=>'0');
			end loop;
		else
			if dr_cw(0)='0'	then	-- READ
				dout <= data_area(to_integer(unsigned(addr)));
			else	-- WRITE
				data_area(to_integer(unsigned(addr))) <= din;
			end if;
		end if;
	end process;
end data_ram_arch;
