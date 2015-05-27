--------------------------------------------------------------------------------
-- FILE: Alu
-- DESC: ALU with multiple functions:
--			ADD/SUB/CMP
--			SHIFT
--			AND/OR/XOR
--
-- Author:
-- Create: 2015-05-25
-- Update: 2015-05-27
-- Status: TESTED
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Encode of FUNCTION (f) signal:
-- 00000 -- [ADD] Addition, or NOP
-- 00001 -- [AND]
-- 00010 -- [OR]
-- 00011 -- [XOR]
-- 00100 -- [SLL] Logic Shift LEFT
-- 00101 -- [SRL] Logic Shift RIGHT
-- 00110 -- NOT USED
-- 00111 -- [SRA] Arithmetic Shift RIGHT
-- 01000 -- NOT USED
-- 01001 -- NOT USED
-- 01010 -- NOT USED
-- 01011 -- NOT USED
-- 01100 -- NOT USED
-- 01101 -- NOT USED
-- 01110 -- NOT USED
-- 01111 -- NOT USED
-- 10000 -- [SUB] Substraction
-- 10001 -- [SGT] SET If GREAT, For SIGNED 
-- 10010 -- [SGE] SET If GREAT AND EQUAL, For SIGNED
-- 10011 -- [SLT] SET If LESS, For SIGNED
-- 10100 -- [SLE] SET If LESS AND EQUAL, For SIGNED
-- 10101 -- [SGTU] SET If GREAT, For UNSIGNED 
-- 10110 -- [SGEU] SET If GREAT AND EQUAL, For UNSIGNED 
-- 10111 -- [SLTU] SET If LESS, For UNSIGNED 
-- 11000 -- [SLEU] SET If LESS AND EQUAL, For UNSIGNED
-- 11001 -- [SEQ] SET If EQUAL
-- 11010 -- [SNE] SET If NOT EQUAL
-- 11011 -- NOT USED
-- 11100 -- NOT USED
-- 11101 -- NOT USED
-- 11110 -- NOT USED
-- 11111 -- NOT USED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity Alu is
	generic (
		DATA_SIZE : integer := C_SYS_DATA_SIZE
	);
	port (
		f : in std_logic_vector(4 downto 0);			-- Function
		a : in std_logic_vector(DATA_SIZE-1 downto 0);	-- Data A
		b : in std_logic_vector(DATA_SIZE-1 downto 0);	-- Data B
		o : out std_logic_vector(DATA_SIZE-1 downto 0)	-- Data Out
	);
end Alu;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture alu_arch of Alu is
	component Adder is
		generic(
			DATA_SIZE : integer := C_SYS_DATA_SIZE
		);
		port(
			cin : in std_logic;
			a, b : in std_logic_vector(DATA_SIZE-1 downto 0);
			s : out std_logic_vector(DATA_SIZE-1 downto 0);
			cout : out std_logic
		);
	end component;
	
	component Shifter is
		generic (
			DATA_SIZE : integer := C_SYS_DATA_SIZE
		);
		port (
			l_r : in std_logic;	-- LEFT/RIGHT
			l_a : in std_logic;	-- LOGIC/ARITHMETIC
			s_r : in std_logic;	-- SHIFT/ROTATE
			a : in std_logic_vector(DATA_SIZE-1 downto 0);
			b : in std_logic_vector(DATA_SIZE-1 downto 0);
			o : out std_logic_vector(DATA_SIZE-1 downto 0)
		);
	end component;

	constant FUNC_SIZE : integer := 5;
	constant FUNC_NUM : integer := 2**FUNC_SIZE;
	signal b_new : std_logic_vector(DATA_SIZE-1 downto 0);
	signal as_arr: std_logic_vector(DATA_SIZE-1 downto 0);
	signal ado : std_logic_vector(DATA_SIZE-1 downto 0);	-- adder output
	signal sho : std_logic_vector(DATA_SIZE-1 downto 0);	-- shifter output
	signal c_f, o_f, s_f, z_f, b_f : std_logic := '0';	-- Flags of ADDER outputs: Carry, Overflow, Sign, Zero, Borrow
	type OutMem_t is array (FUNC_NUM-1 downto 0) of std_logic_vector(DATA_SIZE-1 downto 0);
	signal outputs : OutMem_t;
	signal zeros : std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
begin
	as_arr <= (others=>f(FUNC_SIZE-1));
	b_new <= b xor as_arr;

	ADD0: Adder
	generic map (DATA_SIZE)
	port map (f(FUNC_SIZE-1), a, b_new, ado, c_f);
	
	SHF0: Shifter
	generic map (DATA_SIZE)
	port map (f(0), f(1), '0', a, b, sho);
	
	-- CAUTION: the concept of CF is different from the CF in 8086 structure, a
	--			BF is needed to determin the Borrow Bit of a substraction.
	b_f <= not c_f;
	s_f <= ado(DATA_SIZE-1);
	o_f <= (not (a(DATA_SIZE-1) xor b_new(DATA_SIZE-1))) and (a(DATA_SIZE-1) xor s_f);
	
	P0: process(ado)
	begin
		if ado = zeros then
			z_f <= '1';
		else
			z_f <= '0';
		end if;
	end process;
	
	outputs(0) <= ado;
	outputs(1) <= a and b;
	outputs(2) <= a or b;
	outputs(3) <= a xor b;
	outputs(4) <= sho;
	outputs(5) <= sho;
	outputs(7) <= sho;
	outputs(16) <= ado;
	outputs(17) <= (0 => (not z_f) and (not (s_f xor o_f)), others => '0');	-- ZF=0 & SF=OF
	outputs(18) <= (0 => (not (s_f xor o_f)), others => '0');				-- SF=OF
	outputs(19) <= (0 => (s_f xor o_f), others => '0');						-- SF!=OF
	outputs(20) <= (0 => (z_f or (s_f xor o_f)), others => '0');			-- ZF=1 | SF!=OF
	outputs(21) <= (0 => ((not b_f) and (not z_f)), others => '0');			-- BF=0 & ZF=0
	outputs(22) <= (0 => (not b_f), others => '0');							-- BF=0
	outputs(23) <= (0 => b_f, others => '0');								-- BF=1
	outputs(24) <= (0 => (b_f or z_f), others => '0');						-- BF=1 | ZF=1
	outputs(25) <= (0 => z_f, others => '0');								-- ZF=1
	outputs(26) <= (0 => (not z_f), others => '0');							-- ZF=0
	
	o <= outputs(to_integer(unsigned(f)));
	
end alu_arch;
