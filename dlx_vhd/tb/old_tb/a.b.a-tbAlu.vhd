library ieee;
use ieee.std_logic_1164.all;
use work.Consts.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity tbAlu is
end tbAlu;

architecture tb_alu_arch of tbAlu is
	constant N: integer:=32;
	signal a, b: std_logic_vector(N-1 downto 0):=x"00000000";
	signal o_add, o_and, o_or, o_xor, o_sll, o_srl, o_sra, o_sub, o_sgt, o_sge, o_slt, o_sle, o_sgtu, o_sgeu, o_sltu, o_sleu, o_seq, o_sne: std_logic_vector(N-1 downto 0):=x"00000000";
	
	component Alu is
		generic (
			DATA_SIZE : integer := C_SYS_DATA_SIZE
		);
		port (
			f : in std_logic_vector(4 downto 0);			-- Function
			a : in std_logic_vector(DATA_SIZE-1 downto 0);	-- Data A
			b : in std_logic_vector(DATA_SIZE-1 downto 0);	-- Data B
			o : out std_logic_vector(DATA_SIZE-1 downto 0)	-- Data Out
		);
	end component;
begin
	ALU0 : Alu
	generic map(N)
	port map(OP_ADD, a, b, o_add);
	ALU1 : Alu
	generic map(N)
	port map(OP_AND, a, b, o_and);
	ALU2 : Alu
	generic map(N)
	port map(OP_OR, a, b, o_or);
	ALU3 : Alu
	generic map(N)
	port map(OP_XOR, a, b, o_xor);
	ALU4 : Alu
	generic map(N)
	port map(OP_SLL, a, b, o_sll);
	ALU5 : Alu
	generic map(N)
	port map(OP_SRL, a, b, o_srl);
	ALU6 : Alu
	generic map(N)
	port map(OP_SRA, a, b, o_sra);
	ALU7 : Alu
	generic map(N)
	port map(OP_SUB, a, b, o_sub);
	ALU8 : Alu
	generic map(N)
	port map(OP_SGT, a, b, o_sgt);
	ALU9 : Alu
	generic map(N)
	port map(OP_SGE, a, b, o_sge);
	ALU10 : Alu
	generic map(N)
	port map(OP_SLT, a, b, o_slt);
	ALU11 : Alu
	generic map(N)
	port map(OP_SLE, a, b, o_sle);
	ALU12 : Alu
	generic map(N)
	port map(OP_SGTU, a, b, o_sgtu);
	ALU13 : Alu
	generic map(N)
	port map(OP_SGEU, a, b, o_sgeu);
	ALU14 : Alu
	generic map(N)
	port map(OP_SLTU, a, b, o_sltu);
	ALU15 : Alu
	generic map(N)
	port map(OP_SLEU, a, b, o_sleu);
	ALU16 : Alu
	generic map(N)
	port map(OP_SEQ, a, b, o_seq);
	ALU17 : Alu
	generic map(N)
	port map(OP_SNE, a, b, o_sne);
	
	
	a <= x"ffffffff", x"04532434" after 1 ns, x"2234e826" after 2 ns, x"a323f443" after 3 ns, x"8b651a8b" after 4 ns, x"ffffffff" after 5 ns;
	b <= x"00000001", x"05335f28" after 1.5 ns, x"2234e826" after 2.5 ns, x"11645030" after 3.5 ns, x"030035a6" after 4.5 ns, x"00000001" after 5.5 ns, x"12334224" after 7 ns;
end tb_alu_arch;

configuration tb_alu_cfg of tbAlu is
	for tb_alu_arch
	end for;
end tb_alu_cfg;
