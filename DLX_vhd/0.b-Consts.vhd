--------------------------------------------------------------------------------
-- FILE: Consts
-- DESC: Define all constants.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package Consts is
	C_SYS_DATA_SIZE 	: integer	:=	32;			-- Data size
	C_SYS_ISTR_SIZE		: integer	:=	32;			-- Instruction size
	C_SYS_ADDR_SIZE		: integer	:=	32;			-- Address size
	C_SYS_CWRD_SIZE		: integer	:=	15;			-- Control Word size
	C_SYS_CALU_SIZE		: integer	:=	2;			-- ALU control word size
	C_CTR_OPCD_SIZE		: integer	:=	6;			-- Operation code size
	C_CTR_FUNC_SIZE		: integer	:=	11;			-- Function code size
	C_CTR_IMME_SIZE		: integer	:=	26;			-- Immediate value size
	C_ADD_SPARSITY		: integer	:=	4;			-- Sparsity of Adder carray generator
	C_REG_GLOBAL_NUM	: integer	:=	8;			-- Number of Global register in register file
	C_REG_GENERAL_NUM	: integer	:=	8;			-- Number of General registers (I/L/O) in register file
	C_REG_WINDOW_NUM	: integer	:=	8;			-- Number of Windows in register file
end package Funcs;
