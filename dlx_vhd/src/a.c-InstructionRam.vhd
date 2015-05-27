--------------------------------------------------------------------------------
-- FILE: InstructionRam
-- DESC: Instruction Ram, combinational
--
-- Author:
-- Create: 2015-05-24
-- Update: 2015-05-24
-- Status: UNTESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.Types.all;
use work.Consts.all;
use work.Funcs.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity InstructionRam
	generic (
		ADDR_SIZE : integer := C_SYS_ADDR_SIZE;
		ISTR_SIZE : integer := C_SYS_ISTR_SIZE
	);
	port (
		rst  : in std_logic;
		addr : in std_logic_vector(ADDR_SIZE-1 downto 0);
		iout : out std_logic_vector(ISTR_SIZE-1 downto 0)
	);
end component;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture instruction_ram_arch of InstructionRam is
	constant IRAM_SIZE : integer := C_RAM_IRAM_SIZE;
	type IRam_t is range(0 to IRAM_SIZE-1) of integer;
	signal data_area : DRam_t;
begin
	iout <= std_logic_vector(to_unsigned(data_area(to_integer(unsigned(Addr))),ISTR_SIZE));

	-- Fill the memory with text input file while RESET	
	FILL_MEM_P: process (rst)
		file mem_fp: text;
		variable file_line : line;
		variable index : integer := 0;
		variable tmp_data_u : std_logic_vector(ISTR_SIZE-1 downto 0);
	begin  -- process FILL_MEM_P
		if (rst = '0') then
			file_open(mem_fp,"test.asm.mem",READ_MODE);
			while (not endfile(mem_fp)) loop
				readline(mem_fp,file_line);
				hread(file_line,tmp_data_u);
				data_area(index) <= to_integer(unsigned(tmp_data_u));       
				index := index + 1;
			end loop;
		end if;
	end process FILL_MEM_P;
end instruction_ram_arch;
