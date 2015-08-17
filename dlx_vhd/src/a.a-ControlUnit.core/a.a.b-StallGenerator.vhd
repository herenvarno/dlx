--------------------------------------------------------------------------------
-- FILE: StallGenerator
-- DESC: Generate stall for each stage
--
-- Author:
-- Create: 2015-07-29
-- Update: 2015-08-14
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
		sig_ral			: in std_logic := '0';		-- from DataPath
		sig_bpw			: in std_logic := '0';		-- from Branch
		sig_jral		: in std_logic := '0';		-- from DataPath
		sig_mul			: in std_logic := '0';		-- from CwGenerator
		sig_div			: in std_logic := '0';		-- from CwGenerator
		stall_flag		: out std_logic_vector(4 downto 0):=(others=>'0')
	);
end StallGenerator;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture stall_generator_arch of StallGenerator is
	signal s_ral : std_logic_vector(4 downto 0) := "00000";
	signal s_bpw : std_logic_vector(4 downto 0) := "00000";
	signal s_jral: std_logic_vector(4 downto 0) := "00000"; 
	signal s_mul : std_logic_vector(4 downto 0) := "00000";
	signal s_div : std_logic_vector(4 downto 0) := "00000";
	signal s_stu : std_logic_vector(4 downto 0) := "11111";
	
	signal c_state_ral, n_state_ral : integer := SG_ST0;
	signal c_state_bpw, n_state_bpw : integer := SG_ST0;
	signal c_state_jral, n_state_jral : integer := SG_ST0;
	signal c_state_mul, n_state_mul : integer := SG_ST0;
	signal c_state_div, n_state_div : integer := SG_ST0;
	signal c_state_stu, n_state_stu : integer := SG_ST0;
begin
	-- A OR B WAIT SIGNAL
	-- NEXT STATE GENERATOR
	P_NSG1: process(sig_ral, c_state_ral)	
	begin
		if (sig_ral='1') then
			n_state_ral<=SG_ST1;
		else
			if c_state_ral = SG_ST0 or c_state_ral >= SG_ST2 then
				n_state_ral <= SG_ST0;
			else
				n_state_ral <= c_state_ral + 1;
			end if;
		end if;
	end process;
	
	-- OUTPUT GENERATOR
	P_OUT1: process(c_state_ral)
	begin
		case c_state_ral is
			when SG_ST0 => s_ral <= "00000";
			when SG_ST1 => s_ral <= "00010";
			when SG_ST2 => s_ral <= "00001";
			when others => s_ral <= "00000";
		end case;
	end process;

	-- NEXT STATE REGISTER
	P_REG1: process(rst, clk)
	begin
		if rst='0' then
			c_state_ral <= SG_ST0;
		else
			if rising_edge(clk) then
				c_state_ral <= n_state_ral;
			end if;
		end if;
	end process;
	
	
	-- BRANCH PREDICT ERROR
	-- NEXT STATE GENERATOR
	P_NSG2: process(sig_bpw, c_state_bpw)
		
	begin
		if (sig_bpw='1') then
			n_state_bpw<=SG_ST1;
		else
			if c_state_bpw = SG_ST0 or c_state_bpw >= SG_ST2 then
				n_state_bpw <= SG_ST0;
			else
				n_state_bpw <= c_state_bpw + 1;
			end if;
		end if;
	end process;
	
	-- OUTPUT GENERATOR
	P_OUT2: process(c_state_bpw)
	begin
		case c_state_bpw is
			when SG_ST0 => s_bpw <= "00000";
			when SG_ST1 => s_bpw <= "00010";
			when SG_ST2 => s_bpw <= "00001";
			when others => s_bpw <= "00000";
		end case;
	end process;

	-- NEXT STATE REGISTER
	P_REG2: process(rst, clk)
	begin
		if rst='0' then
			c_state_bpw <= SG_ST0;
		else
			if rising_edge(clk) then
				c_state_bpw <= n_state_bpw;
			end if;
		end if;
	end process;


	-- JR WAIT SIGNAL
	-- NEXT STATE GENERATOR
	P_NSG3: process(sig_jral, c_state_jral)	
	begin
		if (sig_jral='1') then
			n_state_jral<=SG_ST1;
		else
			if c_state_jral = SG_ST0 or c_state_jral >= SG_ST3 then
				n_state_jral <= SG_ST0;
			else
				n_state_jral <= c_state_jral + 1;
			end if;
		end if;
	end process;
	
-- OUTPUT GENERATOR
	P_OUT3: process(c_state_jral)
	begin
		case c_state_jral is
			when SG_ST0 => s_jral <= "00000";
			when SG_ST1 => s_jral <= "00100";
			when SG_ST2 => s_jral <= "00010";
			when SG_ST3 => s_jral <= "00001";
			when others => s_jral <= "00000";
		end case;
	end process;

	-- NEXT STATE REGISTER
	P_REG3: process(rst, clk)
	begin
		if rst='0' then
			c_state_jral <= SG_ST0;
		else
			if rising_edge(clk) then
				c_state_jral <= n_state_jral;
			end if;
		end if;
	end process;

	-- MUL SIGNAL
	-- NEXT STATE GENERATOR
	P_NSG4: process(sig_mul, sig_ral, c_state_mul)
	begin
		if (sig_mul='1') and (sig_ral='0') and (c_state_mul=SG_ST0) then
			n_state_mul<=SG_ST1;
		else
			if c_state_mul = SG_ST0 or c_state_mul >= SG_ST4 then
				n_state_mul <= SG_ST0;
			else
				n_state_mul <= c_state_mul + 1;
			end if;
		end if;
	end process;
	
	-- OUTPUT GENERATOR
	P_OUT4: process(c_state_mul)
	begin
		case c_state_mul is
			when SG_ST0 => s_mul <= "00000";
			when SG_ST1 => s_mul <= "11110";
			when SG_ST2 => s_mul <= "11111";
			when SG_ST3 => s_mul <= "00011";
			when SG_ST4 => s_mul <= "00001";
			when others => s_mul <= "00000";
		end case;
	end process;

	-- NEXT STATE REGISTER
	P_REG4: process(rst, clk)
	begin
		if rst='0' then
			c_state_mul <= SG_ST0;
		else
			if rising_edge(clk) then
				c_state_mul <= n_state_mul;
			end if;
		end if;
	end process;
	
	-- START UP
	-- NEXT STATE GENERATOR
	P_NSG5: process(c_state_stu)
	begin
		if c_state_stu >= SG_ST5 then
			n_state_stu <= SG_ST5;
		else
			n_state_stu <= c_state_stu + 1;
		end if;
	end process;
	
	-- OUTPUT GENERATOR
	P_OUT5: process(c_state_stu)
	begin
		case c_state_stu is
			when SG_ST0 => s_stu <= "11111";
			when SG_ST1 => s_stu <= "01111";
			when SG_ST2 => s_stu <= "00111";
			when SG_ST3 => s_stu <= "00011";
			when SG_ST4 => s_stu <= "00001";
			when SG_ST5 => s_stu <= "00000";
			when others => s_stu <= "00000";
		end case;
	end process;

	-- NEXT STATE REGISTER
	P_REG5: process(rst, clk)
	begin
		if rst='0' then
			c_state_stu <= SG_ST0;
		else
			if rising_edge(clk) then
				c_state_stu <= n_state_stu;
			end if;
		end if;
	end process;
	
	P_FIN: process(s_ral, s_bpw, s_mul, s_div, sig_ral, sig_bpw, sig_jral, sig_mul, sig_div, c_state_mul)
		variable stall_flag_tmp: std_logic_vector(4 downto 0);
	begin
		stall_flag_tmp := s_ral or s_bpw or s_mul or s_div;
		if (sig_ral='1') then
			stall_flag_tmp := stall_flag_tmp or "11100";
		end if;
		
		if (sig_bpw='1') then
			stall_flag_tmp := stall_flag_tmp or "00100";
		end if;
		
		if (sig_jral='1') then
			stall_flag_tmp := stall_flag_tmp or "11000";
		end if;
		
		if (sig_mul='1') and (sig_ral='0') and (c_state_mul=SG_ST0) then
			stall_flag_tmp := stall_flag_tmp or "11100";
		end if;
		
		stall_flag <= stall_flag_tmp;
	end process;
end stall_generator_arch;
