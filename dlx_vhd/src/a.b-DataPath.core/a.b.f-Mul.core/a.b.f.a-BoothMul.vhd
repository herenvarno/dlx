--------------------------------------------------------------------------------
-- FILE: BoothMul
-- DESC: Booth's Multiplier
--
-- Author:
-- Create: 2015-08-14
-- Update: 2015-08-14
-- Status: UNFINISHED
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

	constant layer : integer:=(DATA_SIZE/2)/STAGE;
	type Sels is array (layer-1 downto 0) of std_logic_vector(2 downto 0);
	type Gens is array (layer-1 downto 0) of std_logic_vector(DATA_SIZE*2-1 downto 0);
	type SelArray is array (STAGE-1 downto 0) of Sels;
	type GenArray is array (STAGE-1 downto 0) of Gens;
	type AArray is array (STAGE-1 downto 0) of std_logic_vector(DATA_SIZE*2-1 downto 0);
	type BArray is array (STAGE-1 downto 0) of std_logic_vector(DATA_SIZE downto 0);
	signal sel:SelArray;
	signal ya, y2a, muxout, zerosels, zeroselout, addout, regout:GenArray;
	signal e_a: AArray;
	signal e_b: BArray;
begin
	e_b(0)<=b & '0';
	e_a(0)(DATA_SIZE-1 downto 0)<=a;
	e_a(0)(DATA_SIZE*2-1 downto DATA_SIZE)<=(others=>a(DATA_SIZE-1));
	regout(0)(0) <= (others=>'0');

	GEX: for i in 0 to STAGE-1 generate
		GEY: for j in 0 to layer-1 generate
		begin
			BEC0: BoothEncoder
			port map(e_b(i)(((i*layer)+j+1)*2 downto ((i*layer)+j)*2), sel(i)(j));
		
			GEN0: BoothGenerator
			generic map(DATA_SIZE, (i*layer)+j)
			port map(e_a(i), ya(i)(j), y2a(i)(j));
		
			MUX0: Mux
			generic map(DATA_SIZE*2)
			port map(sel(i)(j)(0), ya(i)(j), y2a(i)(j), muxout(i)(j));
		
			zerosels(i)(j) <= (others => sel(i)(j)(2));
			zeroselout(i)(j) <= muxout(i)(j) and zerosels(i)(j);
			
			GE0: if j=0 generate
			begin
				ADDSUBn: AddSub
				generic map(DATA_SIZE*2)
				port map(sel(i)(j)(1), regout(i)(0), zeroselout(i)(j), addout(i)(j), open);
			end generate;
			
			GE1: if j/=0 generate
			begin
				ADDSUBn: AddSub
				generic map(DATA_SIZE*2)
				port map(sel(i)(j)(1), addout(i)(j-1), zeroselout(i)(j), addout(i)(j), open);
			end generate;
		end generate;
		
		
		GE2: if i<STAGE-1 generate 
		begin
			-- Register here
			REG0: Reg
			generic map(DATA_SIZE*2)
			port map(rst, '1', clk, addout(i)(layer-1), regout(i+1)(0));
			REG1: Reg
			generic map(DATA_SIZE*2)
			port map(rst, '1', clk, e_a(i), e_a(i+1));
			REG2: Reg
			generic map(DATA_SIZE+1)
			port map(rst, '1', clk, e_b(i), e_b(i+1));
		end generate;
		GE3: if i=STAGE-1 generate
		begin
			o<=addout(STAGE-1)(layer-1);
		end generate;
	end generate;
	
end booth_mul_arch;
