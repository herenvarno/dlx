--------------------------------------------------------------------------------
-- FILE: RegisterFile
-- DESC: Register File with 2 read port and 1 write port.
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
use work.Funcs.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity RegisterFile is
	generic(
		DATA_SIZE : integer := C_SYS_DATA_SIZE;
		REG_NUM : integer := C_REG_NUM
	);
	port(
		clk		: in std_logic;											-- clock
		rst		: in std_logic;											-- reset
		en		: in std_logic;											-- enable
		rd1_en	: in std_logic;											-- read port 1
		rd2_en	: in std_logic;											-- read port 2
		wr_en	: in std_logic;											-- write port
		link_en	: in std_logic;											-- save link reg
		rd1_addr: in std_logic_vector(MyLog2Ceil(REG_NUM)-1 downto 0):=(others=>'0');	-- address of read port 1
		rd2_addr: in std_logic_vector(MyLog2Ceil(REG_NUM)-1 downto 0):=(others=>'0');	-- address of read port 2
		wr_addr	: in std_logic_vector(MyLog2Ceil(REG_NUM)-1 downto 0):=(others=>'0');	-- address of write port
		d_out1	: out std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');			-- data out 1 bus
		d_out2	: out std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');			-- data out 2 bus
		d_in	: in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');			-- data in bus
		d_link	: in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0')				-- link register input bus
	);
end RegisterFile;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture register_file_arch of RegisterFile is
	type RegArray_t is array(natural range 0 to REG_NUM-1) of std_logic_vector(DATA_SIZE-1 downto 0); 
	signal registers : RegArray_t;
	constant ADDR_SIZE: integer:= MyLog2Ceil(REG_NUM);
begin
	PROC: process(clk)
	begin
		if rst = '0' then
			LO0: for i in 0 to REG_NUM-1 loop
				registers(i) <= (others=>'0');
			end loop;
		else
			if falling_edge(clk) then
				if en = '1' then
					if rd1_en= '1' then
						if wr_en = '1' and wr_addr=rd1_addr then
							d_out1 <= d_in;
						else
							d_out1 <= registers(to_integer(unsigned(rd1_addr)));
						end if;
					end if;
					if rd2_en='1' then
						if wr_en = '1' and wr_addr=rd2_addr then
							d_out2 <= d_in;
						else
							d_out2 <= registers(to_integer(unsigned(rd2_addr)));
						end if;
					end if;
					if wr_en = '1' then
						if wr_addr /= (wr_addr'range => '0') then	-- Keep R0 always 0.
							registers(to_integer(unsigned(wr_addr))) <= d_in;
						end if;
					end if;
					if link_en = '1' then
						registers(REG_NUM-1) <= d_link;
					end if;
				end if;
			end if;
		end if;
	end process;
end register_file_arch;
