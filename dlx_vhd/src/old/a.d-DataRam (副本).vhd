--------------------------------------------------------------------------------
-- FILE: DataRam
-- DESC: Data Ram, Combinational structure
--
-- Author:
-- Create: 2015-05-24
-- Update: 2015-08-13
-- Status: UNTESTED
--
-- NOTE 1:
-- Control Word:
-- drcw(3)		: Write enable. 1--WRITE, 0--READ
-- drcw(2:1)	: Data type. 00--WORD(32), 01--HALF WORD(16), 10--BYTE(8)
-- drcw(0)		: Sign flag. 1--signed, 0--unsigned
--
-- NOTE 2:
-- Memory organized as BIG ENDIAN
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
		DRCW_SIZE : integer := C_CTR_DRCW_SIZE;	-- Data RAM Control Word: R/W
		ADDR_SIZE : integer := C_SYS_ADDR_SIZE;
		DATA_SIZE : integer := C_SYS_DATA_SIZE
	);
	port (
		rst		: in std_logic;
		en		: in std_logic;
		addr	: in std_logic_vector(ADDR_SIZE-1 downto 0):=(others=>'0');
		din		: in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
		dout	: out std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
		dr_cw	: in std_logic_vector(DRCW_SIZE-1 downto 0):=(others=>'0')
	);
end DataRam;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture data_ram_arch of DataRam is
	constant DRAM_SIZE : integer := C_RAM_DRAM_SIZE;
	type DRam_t is array (0 to DRAM_SIZE-1) of std_logic_vector(7 downto 0);
	signal data_area : DRam_t;
	
begin
	----------------------------------------------------------------------------
	-- FIXME BUG
	-- In the case LOAD AFTER STORE, If control word is slower than din, then the
	-- data area will be set to incorrect value.
	----------------------------------------------------------------------------
	PDR0: process(rst, addr, din, dr_cw)
		variable addr_ph : integer := 0;
	begin
		addr_ph := to_integer(unsigned(addr(MyLog2Ceil(DRAM_SIZE)-1 downto 0)));
		if addr_ph >= DRAM_SIZE then
			addr_ph := DRAM_SIZE-4;
		end if;
		
		if rst='0' then
			for i in 0 to DRAM_SIZE-1 loop
				data_area(i) <= (others=>'0');
			end loop;
			dout <= (others => '0');
		else
---			if en='1' then
				if dr_cw(3)='0' then	-- READ
					if dr_cw(2 downto 1)="01" then	-- HALF WORD
						dout(7 downto 0) <= data_area(addr_ph);
						dout(15 downto 8) <= data_area(addr_ph+1);
						if (dr_cw(0)='0') then
							dout(DATA_SIZE-1 downto 16) <= (others => '0');
						else
							dout(DATA_SIZE-1 downto 16) <= (others => data_area(addr_ph+1)(7));
						end if;
					elsif dr_cw(2 downto 1)="10" then	-- BYTE
						dout(7 downto 0) <= data_area(addr_ph);
						if (dr_cw(0)='0') then
							dout(DATA_SIZE-1 downto 8) <= (others => '0');
						else
							dout(DATA_SIZE-1 downto 8) <= (others => data_area(addr_ph)(7));
						end if;
					else	-- WORD
						dout(7 downto 0) <= data_area(addr_ph);
						dout(15 downto 8) <= data_area(addr_ph+1);
						dout(23 downto 16) <= data_area(addr_ph+2);
						dout(31 downto 24) <= data_area(addr_ph+3);
					end if;
				else	-- WRITE
					if dr_cw(2 downto 1)="01" then	-- HALF WORD
						data_area(addr_ph) <= din(7 downto 0);
						data_area(addr_ph+1) <= din(15 downto 8);
					elsif dr_cw(2 downto 1)="10" then	-- BYTE
						data_area(addr_ph) <= din(7 downto 0);
					else	-- WORD
						data_area(addr_ph) <= din(7 downto 0);
						data_area(addr_ph+1) <= din(15 downto 8);
						data_area(addr_ph+2) <= din(23 downto 16);
						data_area(addr_ph+3) <= din(31 downto 24);
					end if;
				end if;
--			end if;
		end if;
	end process;
end data_ram_arch;
