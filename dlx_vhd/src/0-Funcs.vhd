--------------------------------------------------------------------------------
-- FILE: Funcs
-- DESC: Define all functions.
--
-- Author:
-- Create: 2015-05-20
-- Update: 2015-05-20
-- Status: TESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package Funcs is
	-- FUNC: MyDivCeil
	-- DESC: Calculate the division, the result is integer which equals to or
	--       is greater than the real result.
	function MyDivCeil (n:integer; m:integer) return integer;

	-- FUNC: MyLog2Ceil
	-- DESC: Calculate the log2(n), the result is integer which equals to or
	--       is greater than the real result.
	function MyLog2Ceil (n:integer) return integer;
end package Funcs;

package body Funcs is
	function MyDivCeil (n:integer; m:integer) return integer is
	begin
		if (n mod m) = 0 then
			return n/m;
		else
			return n/m+1;
		end if;
	end MyDivCeil;
	
	function MyLog2Ceil (n:integer) return integer is
	begin
		if n <=2 then
			return 1;
		else
			return 1 + MyLog2Ceil(MyDivCeil(n,2));
		end if;
	end MyLog2Ceil;
end Funcs;
