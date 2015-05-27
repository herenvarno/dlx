
library ieee;
use ieee.std_logic_1164.all;
use work.Types.all;
use work.Consts.all;
use work.Funcs.all;

entity ControlUnit is
	generic(
		istr_width : integer := C_SYS_ISTR_WIDTH;
		opcd_width : integer := C_CTR_OPCD_WIDTH;
		func_width : integer := C_CTR_FUNC_WIDTH;
		ctrl_width : integer := C_CTR_CTRL_WIDTH
	);
	port(
		opcd : in std_logic_vector(istr_width-1 downto 0);
		func : in std_logic_vector(func_width-1 downto 0);
		ctrl : out std_logic_vector(ctrl_width-1 downto 0)
	);
end ControlUnit;

architecture control_unit_arch_behav of ControlUnit is
	type ctrl_table_t is array(2**opcd_width-1 downto 0) of std_logic_vector(ctrl_width-1 downto 0);
	ctrl_table : ctrl_table_t := (
		"0000000" 
begin
end control_unit_arch_behav;
