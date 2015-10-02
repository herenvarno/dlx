--------------------------------------------------------------------------------
-- FILE: InstructionRam
-- DESC: Instruction Ram, combinational
--
-- Author:
-- Create: 2015-05-24
-- Update: 2015-10-03
-- Status: TESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
--use ieee.std_logic_textio.all;
use work.std_logic_textio.all;
use work.Types.all;
use work.Consts.all;
use work.Funcs.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity InstructionRam is
	generic (
		ADDR_SIZE : integer := C_SYS_ADDR_SIZE;
		ISTR_SIZE : integer := C_SYS_ISTR_SIZE
	);
	port (
		rst  : in std_logic;
		clk  : in std_logic;
		en   : in std_logic;
		addr : in std_logic_vector(ADDR_SIZE-1 downto 0):=(others=>'0');
		iout : out std_logic_vector(ISTR_SIZE-1 downto 0):=(others=>'0')
	);
end InstructionRam;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture instruction_ram_arch of InstructionRam is
	constant IRAM_SIZE : integer := C_RAM_IRAM_SIZE;
	type IRam_t is array (0 to IRAM_SIZE-1) of std_logic_vector(7 downto 0);
	signal data_area : IRam_t:=(others=>"00000000");
begin
	-- Fill the memory with text input file while RESET	
	FILL_MEM_P: process (rst)
		file mem_fp: text;
		variable file_line : line;
		variable index : integer := 0;
		variable tmp_data_u : std_logic_vector(ISTR_SIZE-1 downto 0);
		variable istr: std_logic_vector(ISTR_SIZE-1 downto 0);
	begin  -- process FILL_MEM_P
		if (rst = '0') then
			index := 0;
			file_open(mem_fp,"test.asm.mem",READ_MODE);
			while (not endfile(mem_fp)) loop
				readline(mem_fp,file_line);
				hread(file_line,tmp_data_u);
				istr := std_logic_vector(unsigned(tmp_data_u));
				data_area(index) <= istr(7 downto 0);
				index := index + 1;
				data_area(index) <= istr(15 downto 8);
				index := index + 1;
				data_area(index) <= istr(23 downto 16);
				index := index + 1;
				data_area(index) <= istr(31 downto 24);
				index := index + 1;
			end loop;
		end if;
	end process FILL_MEM_P;
	
	READ_MEM_P: process (rst, clk)
		variable index : integer := 0;
	begin
		if rst = '0' then
			iout <= (others=>'0');
		else
			if rising_edge(clk) and en='1' then
				index := to_integer(unsigned(addr));
				if index >= IRAM_SIZE then
					index := IRAM_SIZE-4;
				end if;
				iout <= data_area(index+3)&data_area(index+2)&data_area(index+1)&data_area(index);
			end if;
		end if;
	end process READ_MEM_P;
end instruction_ram_arch;
