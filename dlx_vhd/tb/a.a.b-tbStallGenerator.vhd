library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;
use work.Consts.all;
use work.Funcs.all;

entity tbStallGenerator is
end tbStallGenerator;

architecture tb_stall_generator_arch of tbStallGenerator is
	constant CWRD_SIZE : integer := C_SYS_CWRD_SIZE;
	
	component StallGenerator is
		generic(
			CWRD_SIZE : integer := C_SYS_CWRD_SIZE
		);
		port(
			rst				: in std_logic;
			clk				: in std_logic;
			s2_branch_taken	: in std_logic := '0';
			s2_branch_wait	: in std_logic := '0';
			s3_reg_a_wait	: in std_logic := '0';
			s3_reg_b_wait	: in std_logic := '0';
			stall_flag		: out std_logic_vector(4 downto 0)
		);
	end component;

	signal rst			: std_logic;
	signal clk			: std_logic:='1';
	signal s2_branch_taken	: std_logic := '0';
	signal s2_branch_wait	: std_logic := '0';
	signal s3_reg_a_wait	: std_logic := '0';
	signal s3_reg_b_wait	: std_logic := '0';
	signal stall_flag		: std_logic_vector(4 downto 0);
	
begin
	SG0: StallGenerator
	generic map(CWRD_SIZE)
	port map(rst, clk, s2_branch_taken, s2_branch_wait, s3_reg_a_wait, s3_reg_b_wait, stall_flag);

	CLK0: process(clk)
	begin
		clk <= not (clk) after 0.5 ns;
	end process;
	
	rst <= '0', '1' after 1 ns;
	s3_reg_a_wait <= '0', '1' after 3 ns, '0' after 4 ns;
	s3_reg_b_wait <= '0', '1' after 8 ns, '0' after 9 ns;
	s2_branch_wait <= '0', '1' after 15 ns, '0' after 16 ns;
	
end tb_stall_generator_arch;

configuration tb_stall_generator_cfg of tbStallGenerator is
	for tb_stall_generator_arch
	end for;
end tb_stall_generator_cfg;

