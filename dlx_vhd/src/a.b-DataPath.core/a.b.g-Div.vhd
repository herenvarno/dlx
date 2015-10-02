--------------------------------------------------------------------------------
-- FILE: Div
-- DESC: Divider
--
-- Author:
-- Create: 2015-09-09
-- Update: 2015-10-03
-- Status: TESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity Div is
	generic (
		DATA_SIZE	: integer := C_SYS_DATA_SIZE;
		DIV_STAGE	: integer := C_DIV_STAGE;
		SQRT_STAGE	: integer := C_SQRT_STAGE
	);
	port (
		rst: in std_logic;
		clk: in std_logic;
		en: in std_logic:='0';
		lock: in std_logic:='0';
		sign: in std_logic:='0';									-- 0 UNSIGNED, 1 SIGNED
		func: in std_logic:='0';									-- 0 DIV, 1 SQRT
		a : in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');	-- Data A
		b : in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');	-- Data B
		o : out std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0')	-- Data Out
	);
end Div;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture div_arch of Div is
	component AddSub is
		generic(
			DATA_SIZE	: integer := C_SYS_DATA_SIZE
		);
		port(
			as: in std_logic;									-- Add(Active High)/Sub(Active Low)
			a, b: in std_logic_vector(DATA_SIZE-1 downto 0);	-- Operands
			re: out std_logic_vector(DATA_SIZE-1 downto 0);		-- Return value
			cout: out std_logic									-- Carry
		);
	end component;
	component Sipo is
		generic(
			DATA_SIZE: integer := C_SYS_DATA_SIZE
		);
		port(
			rst: in std_logic;
			en : in std_logic;
			clk: in std_logic;
			din: in std_logic;
			dout: out std_logic_vector(DATA_SIZE-1 downto 0)
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
	component Mux is
		generic(
			DATA_SIZE: integer := C_SYS_DATA_SIZE
		);
		port(
			sel: in std_logic;
			din0: in std_logic_vector(DATA_SIZE-1 downto 0);
			din1: in std_logic_vector(DATA_SIZE-1 downto 0);
			dout: out std_logic_vector(DATA_SIZE-1 downto 0)
		);
	end component;
	
	signal a_adj, b_adj: std_logic_vector(DATA_SIZE-1 downto 0);
	signal a_mod_dir, b_mod_dir, b_mod, a_mod: std_logic_vector(DATA_SIZE*2-1 downto 0);
	signal a_mux, b_mux: std_logic_vector(DATA_SIZE*2-1 downto 0);
	signal a_shf_div, a_shf_sqrt, a_shf : std_logic_vector(DATA_SIZE*2-1 downto 0);
	signal b_shf_div, b_shf_sqrt, b_shf : std_logic_vector(DATA_SIZE*2-1 downto 0);
	
	signal r_es : std_logic_vector(DATA_SIZE*2-1 downto 0);
	signal r: std_logic_vector(DATA_SIZE*2-1 downto 0);
	signal q : std_logic_vector(DATA_SIZE-1 downto 0);
	signal not_r_es_sign, not_r_sign: std_logic;
	signal en_input, sel_r, en_r, en_q : std_logic:='0';
	signal c_state, n_state : integer:=0;
	signal inv_a_flag, inv_b_flag, inv_q_flag, inv_q_flag_mod : std_logic:='0';
--	signal o_div, o_sqrt: std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
	signal local_rst, reg_rst : std_logic:='1';
	
begin
	-- Datapath
	-- INPUT ADJUST
	P0: process(clk, en_input)
	begin
		if rising_edge(clk) and en_input='1' then
			a_mod <= a_mod_dir;
			b_mod <= b_mod_dir;
			inv_q_flag_mod <= inv_q_flag;
		end if;
	end process;
	
	inv_a_flag <= sign and a(DATA_SIZE-1) and (not func);
	inv_b_flag <= sign and b(DATA_SIZE-1) and (not func);
	inv_q_flag <= sign and (a(DATA_SIZE-1) xor b(DATA_SIZE-1)) and (not func);
	
	ADJUST0a: AddSub
	generic map(DATA_SIZE)
	port map(inv_a_flag, (a'range=>'0'), a, a_adj, open);
	ADJUST0b: AddSub
	generic map(DATA_SIZE)
	port map(inv_b_flag, (b'range=>'0'), b, b_adj, open);

	a_mod_dir(DATA_SIZE-1 downto 0) <= a_adj;
	a_mod_dir(DATA_SIZE*2-1 downto DATA_SIZE) <= (others=>'0');
	b_mod_dir(DATA_SIZE-1 downto 0) <= (others=>'0');
	b_mod_dir(DATA_SIZE*2-1 downto DATA_SIZE) <= b_adj;
	
	
	-- DIV & SQRT CALCULATION
	MUXa: Mux
	generic map(DATA_SIZE*2)
	port map(sel_r, a_mod, r, a_mux);
	
	b_mux <= b_mod;
	not_r_sign <= not a_mux(DATA_SIZE*2-1);
	
	a_shf_div(DATA_SIZE*2-1 downto 1) <= a_mux(DATA_SIZE*2-2 downto 0);
	a_shf_div(0) <= '0';
	a_shf_sqrt(DATA_SIZE*2-1 downto 2) <= a_mux(DATA_SIZE*2-3 downto 0);
	a_shf_sqrt(1 downto 0) <= "00";
	a_shf <= a_shf_sqrt when func='1' else a_shf_div;
	
	b_shf_div <= b_mux;
	b_shf_sqrt(DATA_SIZE*2-1 downto DATA_SIZE+2) <= q(DATA_SIZE-3 downto 0);
	b_shf_sqrt(DATA_SIZE+1 downto DATA_SIZE) <= "01" when not_r_sign='1' else "11";
	b_shf_sqrt(DATA_SIZE-1 downto 0) <= (others=>'0');
	b_shf <= b_shf_sqrt when func='1' else b_shf_div;
	
	ADD0: AddSub
	generic map(DATA_SIZE*2)
	port map(not_r_sign, a_shf, b_shf, r_es, open);
	
	reg_rst <= rst and local_rst;
	
	REG_R: Reg
	generic map(DATA_SIZE*2)
	port map(reg_rst, en_r, clk, r_es, r);
	
	not_r_es_sign <= not r_es(DATA_SIZE*2-1);
	
	REG_Q: Sipo
	generic map(DATA_SIZE)
	port map(reg_rst, en_q, clk, not_r_es_sign, q);

	-- OUTPUT ADJUST	
	-- NEG q IF NEEDED (FOR DIV)
	ADJUST: AddSub
	generic map(DATA_SIZE)
	port map(inv_q_flag_mod, (q'range=>'0'), q, o, open);
	-- MASK HIGH 16 bits to '0' (FOR SQRT)
--	o_sqrt <= q and x"0000ffff";
	-- CHOOSE OUTPUT BASED ON func
--	o <= o_sqrt when func='1' else o_div;
	

	-- Control Logic (FSM)
	-- NEXT STATE GENERATOR
	P_NSG1: process(en, c_state, lock)	
	begin
		if en='1' and lock='1' then
			n_state<=SG_ST0;
		else
			if en='1' and c_state = SG_ST0 and lock='0' then
				n_state<=SG_ST1;
			else
				if c_state = SG_ST0 or (c_state>=DIV_STAGE-1 and func='0') or (c_state>=SQRT_STAGE-1 and func='1') then
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
			sel_r <= '0';
			en_r <= '1';
			en_q <= '1';
			local_rst <= '1';
		elsif c_state>SG_ST1 and ((c_state<DIV_STAGE and func='0') or (c_state<SQRT_STAGE and func='1'))then
			en_input <= '0';
			sel_r <= '1';
			en_r <= '1';
			en_q <= '1';
			local_rst <= '1';
		else
			en_input <= '1';
			sel_r <= '0';
			en_r <= '0';
			en_q <= '0';
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

end div_arch;
