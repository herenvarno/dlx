library ieee;
use ieee.std_logic_1164.all;

package myTypes is
	
	-- Control Word Signal List
	type CwSignals is (
		CW_S1_LATCH
		CW_S2_LATCH
		CW_S3_SEL_A,
		CW_S3_SEL_B,
		CW_S3_LATCH
		CW_S3_EQ_COND,
		CW_S4_RW_DRAM,
		CW_S4_LATCH,
		CW_S4_JUMP,
		CW_S5_SEL_WB,
		CW_S5_EN_WB
	);

end myTypes;

