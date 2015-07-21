--------------------------------------------------------------------------------
-- FILE: InstructionRam
-- DESC: Instruction Ram, combinational
--
-- Author:
-- Create: 2015-05-24
-- Update: 2015-05-30
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
		addr : in std_logic_vector(ADDR_SIZE-1 downto 0):=(others=>'0');
		iout : out std_logic_vector(ISTR_SIZE-1 downto 0)
	);
end InstructionRam;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture instruction_ram_arch of InstructionRam is
	constant IRAM_SIZE : integer := C_RAM_IRAM_SIZE;
	type IRam_t is array (0 to IRAM_SIZE-1) of std_logic_vector(7 downto 0);
	signal data_area : IRam_t;

begin
	
	iout <= data_area(to_integer(unsigned(addr))+3)&data_area(to_integer(unsigned(addr))+2)&data_area(to_integer(unsigned(addr))+1)&data_area(to_integer(unsigned(addr)));

	-- Fill the memory with text input file while RESET	
	FILL_MEM_P: process (rst)
		file mem_fp: text;
		variable file_line : line;
		variable index : integer := 0;
		variable tmp_data_u : std_logic_vector(ISTR_SIZE-1 downto 0);
		variable istr: std_logic_vector(ISTR_SIZE-1 downto 0);
	begin  -- process FILL_MEM_P
		if (rst = '0') then
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
end instruction_ram_arch;
