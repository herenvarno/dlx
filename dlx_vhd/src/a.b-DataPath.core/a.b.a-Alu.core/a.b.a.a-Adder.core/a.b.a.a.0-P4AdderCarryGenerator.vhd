--------------------------------------------------------------------------------
-- FILE: P4Adder
-- DESC: The Adder used in P4 micro-processor
--
-- Author:
-- Create: 2015-05-27
-- Update: 2015-05-27
-- Status: TESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Consts.all;
use work.Funcs.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity P4CarryGenerator is
	generic(
		DATA_SIZE: integer := C_SYS_DATA_SIZE;
		SPARSITY: integer := C_ADD_SPARSITY
	);
	port(
		a, b: in std_logic_vector(DATA_SIZE-1 downto 0);
		cin: in std_logic;
		cout: out std_logic_vector(DATA_SIZE/SPARSITY-1 downto 0)
	);
end P4CarryGenerator;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture p4_carry_generator_arch of P4CarryGenerator is
	constant layer : integer := MyLog2Ceil(DATA_SIZE)+1;
	type sigmat_t is array (layer-1 downto 0) of std_logic_vector(DATA_SIZE-1 downto 0); 
	signal p_sigmat, g_sigmat: sigmat_t;
begin
	GEi: for i in 0 to layer-1 generate
		GEj: for j in 0 to DATA_SIZE-1 generate
			-- if part1 (0th row)
			GE0: if i=0 generate
				-- if part1 (0th row), LSB, consider ci
				GE00: if j=0 generate
					p_sigmat(i)(j) <= a(j) xor b(j);
					g_sigmat(i)(j) <= (a(j) and b(j)) or (a(j) and cin) or (b(j) and cin);
				end generate;
				-- if part1 (0th row), not LSB, do not consider ci
				GE01: if j>0 generate
					p_sigmat(i)(j) <= a(j) xor b(j);
					g_sigmat(i)(j) <= (a(j) and b(j));
				end generate;
			end generate;
			GE1: if i>0 and i<=MyLog2Ceil(SPARSITY) generate
				-- if part2
				G10: if ((j+1) mod (2**i) = 0) generate
					-- if G node
					GE100: if j<2**i generate
						g_sigmat(i)(j) <= g_sigmat(i-1)(j) or (p_sigmat(i-1)(j) and g_sigmat(i-1)(j-2**(i-1)));
					end generate;
					-- if PG node
					GE101: if j>=2**i generate
						p_sigmat(i)(j) <= p_sigmat(i-1)(j) and p_sigmat(i-1)(j-2**(i-1));
						g_sigmat(i)(j) <= g_sigmat(i-1)(j) or (p_sigmat(i-1)(j) and g_sigmat(i-1)(j-2**(i-1)));
					end generate;
				end generate;
			end generate;
			-- if part3
			GE2: if i>MyLog2Ceil(SPARSITY) generate
				-- only the position of node which is n times of sparsity, and the position is in higher part of adjusted current row position will be keep, other nodes, don't care.
				GE20: if((j mod (2**i))>=2**(i-1) and (j mod (2**i))<2**i) and (((j+1) mod SPARSITY) =0) generate
					-- if G node
					GE200: if (j<2**i) generate
						g_sigmat(i)(j) <= g_sigmat(i-1)(j) or (p_sigmat(i-1)(j) and g_sigmat(i-1)((j/2**(i-1))*2**(i-1)-1));
					end generate;
					-- if PG node
					GE201: if (j>=2**i) generate
						p_sigmat(i)(j) <= p_sigmat(i-1)(j) and p_sigmat(i-1)((j/2**(i-1))*2**(i-1)-1);
						g_sigmat(i)(j) <= g_sigmat(i-1)(j) or (p_sigmat(i-1)(j) and g_sigmat(i-1)((j/2**(i-1))*2**(i-1)-1));
					end generate;
				end generate;
				-- if node is on the LOWER part of adjusted current row position, then make it as a buffer in order to be used by following nodes.
				GE21: if((j mod (2**i))<2**(i-1) and (j mod (2**i))>=0) and (((j+1) mod SPARSITY) =0) generate
					p_sigmat(i)(j) <= p_sigmat(i-1)(j);
					g_sigmat(i)(j) <= g_sigmat(i-1)(j);
				end generate;
			end generate;
			-- if last row, sign G signal to cout array
			GE3: if i=layer-1 generate
				GE30: if ((j+1) mod SPARSITY) =0 generate
					cout(j/SPARSITY) <= g_sigmat(i)(j);
				end generate;
			end generate;
		end generate;
	end generate;
end p4_carry_generator_arch;
