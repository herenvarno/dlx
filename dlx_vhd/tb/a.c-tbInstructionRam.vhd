library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;
use work.Consts.all;
use work.Funcs.all;

entity tbInstructionRam is
end tbInstructionRam;

architecture tb_instruction_ram_arch of tbInstructionRam is
	constant ADDR_SIZE : integer := C_SYS_ADDR_SIZE;
	constant ISTR_SIZE : integer := C_SYS_ISTR_SIZE;
	
	component InstructionRam
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
	
	signal rst			: std_logic;
	signal addr			: std_logic_vector(ADDR_SIZE-1 downto 0);
	signal iout			: std_logic_vector(ISTR_SIZE-1 downto 0);
	
begin
	IRAM: InstructionRam
	port map(rst, addr, iout);

	rst <= '0', '1' after 1 ns;
	addr <= x"00000000", x"00000001" after 2 ns, x"00000002" after 3 ns, x"00000003" after 4 ns, x"00000004" after 5 ns;
end tb_instruction_ram_arch;

configuration tb_instruction_ram_cfg of tbInstructionRam is
	for tb_instruction_ram_arch
	end for;
end tb_instruction_ram_cfg;
