--------------------------------------------------------------------------------
-- FILE: StallGenerator
-- DESC: Generate stall for each stage
--
-- Author:
-- Create: 2015-06-02
-- Update: 2015-06-02
-- Status: UNTESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity StallGenerator is
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
		stall1			: out std_logic := '1';
		stall2			: out std_logic := '1';
		stall3			: out std_logic := '1';
		stall4			: out std_logic := '1';
		stall5			: out std_logic := '1'
	);
end StallGenerator;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture stall_generator_arch of StallGenerator is
	signal s1 : std_logic:='0';
	signal s2 : std_logic:='0';
	signal s3 : std_logic:='1';
	signal s4 : std_logic:='1';
	signal s5 : std_logic:='1';
	signal l1 : std_logic:='0';
	signal l2 : std_logic:='0';
	signal l3 : std_logic:='0';
	signal l4 : std_logic:='0';
	signal l5 : std_logic:='0';
begin
	l1 <= s2_branch_taken or s2_branch_wait or s3_reg_a_wait or s3_reg_b_wait;
	l2 <= s2_branch_wait or s3_reg_a_wait or s3_reg_b_wait;
	l3 <= s3_reg_a_wait or s3_reg_b_wait;
	P_SH: process(rst, clk)
	begin
		if rst='0' then
			s1<='0';
			s2<='0';
			s3<='1';
			s4<='1';
			s5<='1';
		else
			if clk'event and clk='1' then
				s1 <= '0';
				if (l1 and (not l2))='1' then
					s2 <= '1';
				else
					s2 <= s1;
				end if;
				if (l2 and (not l3))='1' then
					s3 <= '1';
				else
					s3 <= s2;
				end if;
				if (l3 and (not l4))='1' then
					s4 <= '1';
				else
					s4 <= s3;
				end if;
				if (l4 and (not l5))='1' then
					s5 <= '1';
				else
					s5 <= s4;
				end if;
			end if;
		end if;
	end process;
	
	stall1 <= s1 or l1;
	stall2 <= s2 or l2;
	stall3 <= s3 or l3;
	stall4 <= s4 or l4;
	stall5 <= s5 or l5;
end stall_generator_arch;
