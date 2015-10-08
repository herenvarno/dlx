--------------------------------------------------------------------------------
-- FILE: BoothMul
-- DESC: Booth's Multiplier
--
-- Author:
-- Create: 2015-08-14
-- Update: 2015-09-28
-- Status: TESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity BoothMul is
	generic (
		DATA_SIZE	: integer := C_SYS_DATA_SIZE/2;
		STAGE		: integer := C_MUL_STAGE
	);
	port (
		rst: in std_logic;
		clk: in std_logic;
		en: in std_logic;
		lock: in std_logic;
		sign: in std_logic;
		a : in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');	-- Data A
		b : in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');	-- Data B
		o : out std_logic_vector(DATA_SIZE*2-1 downto 0):=(others=>'0')	-- Data Out
	);
end BoothMul;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture booth_mul_arch of BoothMul is
	component BoothEncoder is
		port(
			din: in std_logic_vector(2 downto 0);
			sel: out std_logic_vector(2 downto 0)
		);
	end component;
	component BoothGenerator is
		generic(
			DATA_SIZE : integer := C_SYS_DATA_SIZE/2;
			STAGE : integer := C_MUL_STAGE
		);
		port(
			a: in std_logic_vector(DATA_SIZE*2-1 downto 0);
			ya, y2a: out std_logic_vector(DATA_SIZE*2-1 downto 0)
		);
	end component;
	component Mux is
		generic(
			DATA_SIZE: integer := C_SYS_DATA_SIZE/2
		);
		port(
			sel: in std_logic;
			din0: in std_logic_vector(DATA_SIZE-1 downto 0);
			din1: in std_logic_vector(DATA_SIZE-1 downto 0);
			dout: out std_logic_vector(DATA_SIZE-1 downto 0)
		);
	end component;
	component Adder is
		generic(
			DATA_SIZE : integer := C_SYS_DATA_SIZE
		);
		port(
			cin: in std_logic;
			a, b: in std_logic_vector(DATA_SIZE-1 downto 0);
			s : out std_logic_vector(DATA_SIZE-1 downto 0);
			cout: out std_logic
		);
	end component;
	component AddSub is
		generic(
			DATA_SIZE : integer := C_SYS_DATA_SIZE/2
		);
		port(
			as: in std_logic;									-- Add(Active High)/Sub(Active Low)
			a, b: in std_logic_vector(DATA_SIZE-1 downto 0);	-- Operands
			re: out std_logic_vector(DATA_SIZE-1 downto 0);	-- Return value
			cout: out std_logic								-- Carry
		);
	end component;
	component Reg is
		generic(
			DATA_SIZE: integer := C_SYS_DATA_SIZE
		);
		port(
			rst: in std_logic;
			en : in std_logic;
			clk: in std_logic;
			din: in std_logic_vector(DATA_SIZE-1 downto 0);
			dout: out std_logic_vector(DATA_SIZE-1 downto 0)
		);
	end component;

	signal sel:std_logic_vector(2 downto 0);
	signal ya, y2a : std_logic_vector(DATA_SIZE*2-1 downto 0);
	signal e_a, e_a_dir, a_mux: std_logic_vector(DATA_SIZE*2-1 downto 0);
	signal e_b, e_b_dir, b_mux: std_logic_vector(DATA_SIZE downto 0);
	signal mux_out, zero_out, add_out, add_out_reg:std_logic_vector(DATA_SIZE*2-1 downto 0);
	signal c_state, n_state : integer:=0;
	
	signal en_input, sel_ab, local_rst, en_o, reg_rst : std_logic;
	signal adj_sum : std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
	signal adj_cout : std_logic:='0';
	signal adj_final, adj_final_mod : std_logic_vector(DATA_SIZE*2-1 downto 0):=(others=>'0');
	signal adj_mid_h : std_logic_vector(1 downto 0):=(others=>'0');
	signal adj_mid_l : std_logic_vector(DATA_SIZE*2-3 downto 0):=(others=>'0');
	signal a_m, b_m: std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');	-- Operands
begin
	
	P0: process(clk, en, en_input, lock)
	begin
		if rising_edge(clk) then
			if en='1' and en_input='1' then
				e_a <= e_a_dir;
				e_b <= e_b_dir;
				adj_final_mod <= adj_final;
			else
				e_b(DATA_SIZE-2 downto 0)<=e_b(DATA_SIZE downto 2);
				e_b(DATA_SIZE downto DATA_SIZE-1)<=(others=>'0');
				e_a(DATA_SIZE*2-1 downto 2)<=e_a(DATA_SIZE*2-3 downto 0);
				e_a(1 downto 0)<=(others=>'0');
			end if;
		end if;
	end process;
	
	e_a_dir(DATA_SIZE-1) <= a(DATA_SIZE-1) and sign;
	e_a_dir(DATA_SIZE-2 downto 0)<=a(DATA_SIZE-2 downto 0);
	e_a_dir(DATA_SIZE*2-1 downto DATA_SIZE)<=(others=>(a(DATA_SIZE-1) and sign));
	e_b_dir(DATA_SIZE) <= b(DATA_SIZE-1) and sign;
	e_b_dir(DATA_SIZE-1 downto 1)<=b(DATA_SIZE-2 downto 0);
	e_b_dir(0) <= '0';
	
	a_m <= a when b(DATA_SIZE-1)='1' else (others=>'0');
	b_m <= b when a(DATA_SIZE-1)='1' else (others=>'0');
	
	ADJUST0: Adder
	generic map(DATA_SIZE)
	port map('0', a_m, b_m, adj_sum, adj_cout);
	
	adj_mid_h <= adj_cout & adj_sum(DATA_SIZE-1) when (a(DATA_SIZE-1) and b(DATA_SIZE-1))='0' else (adj_cout and adj_sum(DATA_SIZE-1)) & (not adj_sum(DATA_SIZE-1));
	adj_mid_l(DATA_SIZE*2-3 downto DATA_SIZE-1) <= adj_sum(DATA_SIZE-2 downto 0);
	adj_mid_l(DATA_SIZE-2 downto 0) <= (others=>'0');
	
	adj_final <= adj_mid_h & adj_mid_l when sign='0' else (others=>'0');

	a_mux <= e_a;
	b_mux <= e_b;
	
	BEC0: BoothEncoder
	port map(e_b(2 downto 0), sel);
	
	ya <= a_mux;
	y2a(DATA_SIZE*2-1 downto 1) <= a_mux(DATA_SIZE*2-2 downto 0);
	y2a(0) <= '0';
	
	MUX0: Mux
	generic map(DATA_SIZE*2)
	port map(sel(0), ya, y2a, mux_out);
	
	zero_out <= mux_out when sel(2)='1' else (others=>'0');
	
	ADDSUBn: AddSub
	generic map(DATA_SIZE*2)
	port map(sel(1), add_out_reg, zero_out, add_out, open);
	
	reg_rst <= rst and local_rst;
	
	REG0: Reg
	generic map(DATA_SIZE*2)
	port map(reg_rst, en_o, clk, add_out, add_out_reg);
	
	ADJUST1: Adder
	generic map(DATA_SIZE*2)
	port map('0', add_out_reg, adj_final_mod, o, open);
	
	-- FSM
	-- NEXT STATE GENERATOR
	P_NSG1: process(en, c_state, lock)	
	begin
		if en='1' and lock='1' then
			n_state<=SG_ST0;
		else
			if en='1' and c_state = SG_ST0 and lock='0' then
				n_state<=SG_ST1;
			else
				if c_state = SG_ST0 or c_state >= STAGE-1 then
					n_state <= SG_ST0;
				else
					n_state <= c_state + 1;
				end if;
			end if;
		end if;
	end process;
	
	-- OUTPUT GENERATOR
	P_OUT1: process(c_state)
	begin
		if c_state=SG_ST1 then
			en_input <= '0';
			sel_ab <= '0';
			en_o <= '1';
			local_rst <= '1';
		elsif c_state>SG_ST1 and c_state<STAGE then
			en_input <= '0';
			sel_ab <= '1';
			en_o <= '1';
			local_rst <= '1';
		else
			en_input <= '1';
			sel_ab <= '1';
			en_o <= '0';
			local_rst <= '0';
		end if;
	end process;

	-- NEXT STATE REGISTER
	P_REG1: process(rst, clk)
	begin
		if rst='0' then
			c_state <= SG_ST0;
		else
			if rising_edge(clk) then
				c_state <= n_state;
			end if;
		end if;
	end process;
	
end booth_mul_arch;
