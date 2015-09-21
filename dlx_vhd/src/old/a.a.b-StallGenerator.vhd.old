--------------------------------------------------------------------------------
-- FILE: StallGenerator
-- DESC: Generate stall for each stage
--
-- Author:
-- Create: 2015-07-29
-- Update: 2015-08-07
-- Status: UNFINISHED
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
		stall_flag		: out std_logic_vector(4 downto 0):=(others=>'0')
	);
end StallGenerator;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture stall_generator_arch of StallGenerator is
	signal s_ab : std_logic_vector(4 downto 0) := "00000";
	signal s_br : std_logic_vector(4 downto 0) := "00000";
	signal s_tk : std_logic_vector(4 downto 0) := "00000";
	signal s_st : std_logic_vector(4 downto 0) := "00000";
	
	signal c_state_ab, n_state_ab : integer := SG_ST0;
	signal c_state_br, n_state_br : integer := SG_ST0;
	signal c_state_tk, n_state_tk : integer := SG_ST0;
	signal c_state_st, n_state_st : integer := SG_ST0;
	
	signal stall_flag_tmp : std_logic_vector(4 downto 0);
begin
	-- A OR B WAIT SIGNAL
	-- NEXT STATE GENERATOR
	P_NSG1: process(s3_reg_a_wait, s3_reg_b_wait, c_state_ab)
		
	begin
		if ((s3_reg_a_wait or s3_reg_b_wait)='1') then
			n_state_ab<=SG_ST1;
		else
			if c_state_ab = SG_ST0 or c_state_ab >= SG_ST2 then
				n_state_ab <= SG_ST0;
			else
				n_state_ab <= c_state_ab + 1;
			end if;
		end if;
	end process;
	
	-- OUTPUT GENERATOR
	P_OUT1: process(c_state_ab)
	begin
		case c_state_ab is
			when SG_ST0 => s_ab <= "00000";
			when SG_ST1 => s_ab <= "00010";
			when SG_ST2 => s_ab <= "00001";
			when others => s_ab <= "00000";
		end case;
	end process;

	-- NEXT STATE REGISTER
	P_REG1: process(rst, clk)
	begin
		if rst='0' then
			c_state_ab <= SG_ST0;
		else
			if rising_edge(clk) then
				c_state_ab <= n_state_ab;
			end if;
		end if;
	end process;
	
	
	-- BRANCH WAIT SIGNAL
	-- NEXT STATE GENERATOR
	P_NSG2: process(s2_branch_wait, c_state_ab)
		
	begin
		if (s2_branch_wait='1') then
			n_state_br<=SG_ST1;
		else
			if c_state_br = SG_ST0 or c_state_br >= SG_ST3 then
				n_state_br <= SG_ST0;
			else
				n_state_br <= c_state_br + 1;
			end if;
		end if;
	end process;
	
	-- OUTPUT GENERATOR
	P_OUT2: process(c_state_br)
	begin
		case c_state_br is
			when SG_ST0 => s_br <= "00000";
			when SG_ST1 => s_br <= "00100";
			when SG_ST2 => s_br <= "00010";
			when SG_ST3 => s_br <= "00001";
			when others => s_br <= "00000";
		end case;
	end process;

	-- NEXT STATE REGISTER
	P_REG2: process(rst, clk)
	begin
		if rst='0' then
			c_state_br <= SG_ST0;
		else
			if rising_edge(clk) then
				c_state_br <= n_state_br;
			end if;
		end if;
	end process;


	-- BRANCH TAKEN
	-- NEXT STATE GENERATOR
	P_NSG3: process(s2_branch_taken, c_state_ab)
		
	begin
		if (s2_branch_taken='1') then
			n_state_tk<=SG_ST1;
		else
			if c_state_tk = SG_ST0 or c_state_tk >= SG_ST5 then
				n_state_tk <= SG_ST0;
			else
				n_state_tk <= c_state_tk + 1;
			end if;
		end if;
	end process;
	
	-- OUTPUT GENERATOR
	P_OUT3: process(c_state_tk)
	begin
		case c_state_tk is
			when SG_ST0 => s_tk <= "00000";
			when SG_ST1 => s_tk <= "00000";
			when SG_ST2 => s_tk <= "00000";
			when SG_ST3 => s_tk <= "00000";
			when SG_ST4 => s_tk <= "00000";
			when SG_ST5 => s_tk <= "00000";
			when others => s_tk <= "00000";
		end case;
	end process;

	-- NEXT STATE REGISTER
	P_REG3: process(rst, clk)
	begin
		if rst='0' then
			c_state_tk <= SG_ST0;
		else
			if rising_edge(clk) then
				c_state_tk <= n_state_tk;
			end if;
		end if;
	end process;
	
	-- START UP
	-- NEXT STATE GENERATOR
	P_NSG4: process(c_state_st)
	begin
		if c_state_st >= SG_ST4 then
			n_state_st <= SG_ST4;
		else
			n_state_st <= c_state_st + 1;
		end if;
	end process;
	
	-- OUTPUT GENERATOR
	P_OUT4: process(c_state_st)
	begin
		case c_state_st is
			when SG_ST0 => s_st <= "00000";
			when SG_ST1 => s_st <= "00000";
			when SG_ST2 => s_st <= "00000";
			when SG_ST3 => s_st <= "00000";
			when SG_ST4 => s_st <= "00000";
			when others => s_st <= "00000";
		end case;
	end process;

	-- NEXT STATE REGISTER
	P_REG4: process(rst, clk)
	begin
		if rst='0' then
			c_state_st <= SG_ST0;
		else
			if rising_edge(clk) then
				c_state_st <= n_state_st;
			end if;
		end if;
	end process;

	stall_flag_tmp <= s_ab or s_br or s_tk or s_st;
	
	P_FIN: process(s3_reg_a_wait, s3_reg_b_wait, s2_branch_wait, stall_flag_tmp)
	begin
		if ((s3_reg_a_wait or s3_reg_b_wait)='1') then
			stall_flag <= stall_flag_tmp or "11100";
		elsif((s2_branch_wait)='1') then
			stall_flag <= stall_flag_tmp or "11000";
		else
			stall_flag <= stall_flag_tmp;
		end if;
	end process;
end stall_generator_arch;
