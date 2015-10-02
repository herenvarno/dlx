--------------------------------------------------------------------------------
-- FILE: BoothEncoder
-- DESC: Encoder of Booth's Multiplier
--
-- Author:
-- Create: 2015-08-14
-- Update: 2015-08-14
-- Status: TESED

-- NOTE 1:
-- Encoder:
-- 		0xx -- 0
--		x0x -- positive	x1x -- negative
--		xx0 -- a		xx1 -- 2a
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity BoothEncoder is
	port(
		din: in std_logic_vector(2 downto 0);
		sel: out std_logic_vector(2 downto 0)
	);
end BoothEncoder;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture booth_encoder_arch of BoothEncoder is
begin
	sel <= "000"	when (din="000" or din="111") else	-- 0
			"100"	when (din="001" or din="010") else	-- +a
			"110"	when (din="101" or din="110") else	-- -a
			"101"	when (din="011") else				-- +2a
			"111"	when (din="100");					-- -2a
end booth_encoder_arch;
