--------------------------------------------------------------------------------
-- FILE: Branch
-- DESC: The branch unit, decide whether a branch instruction should be taken or not
--
-- Author:
-- Create: 2015-06-03
-- Update: 2015-06-03
-- Status: TESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;
use work.Consts.all;
use work.Funcs.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity Branch is
	generic (
		DATA_SIZE : integer := C_SYS_DATA_SIZE;
		OPCD_SIZE : integer := C_SYS_OPCD_SIZE;
		ADDR_SIZE : integer := C_SYS_ADDR_SIZE
	);
	port (
		rst		: in std_logic;
		clk		: in std_logic;
		reg_a	: in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
		ld_a	: in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
		opcd	: in std_logic_vector(OPCD_SIZE-1 downto 0):=(others=>'0');
		addr	: in std_logic_vector(ADDR_SIZE-1 downto 0):=(others=>'0');
		sig_bal	: in std_logic:='0';
	  	sig_bpw	: out std_logic :='0';
		sig_brt	: out std_logic :='0'
	);
end Branch;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture branch_arch of Branch is
	constant BPU_ADDR_SIZE: integer:= C_BPU_ADDR_SIZE;
	constant BPU_BHT_SIZE: integer := 2**BPU_ADDR_SIZE;
	type Bht_t is array (0 to BPU_BHT_SIZE-1) of std_logic_vector(1 downto 0);
	signal bht : Bht_t;

	signal sig_brt_tmp, sig_bpw_tmp, sig_brt_delay, sig_bal_delay: std_logic:='0';
	signal opcd_delay: std_logic_vector(OPCD_SIZE-1 downto 0):=(others=>'0');
	signal addr_delay: std_logic_vector(ADDR_SIZE-1 downto 0):=(others=>'0');
	signal index_r, index_r_delay : integer:= 0;
	signal entry_r, entry_r_delay : std_logic_vector(1 downto 0);
begin
	P0: process(rst, reg_a, opcd, sig_bal)
		variable index : integer:= 0;
		variable entry : std_logic_vector(1 downto 0);
	begin
		if rst='0' then
			sig_brt <= '0';
			sig_brt_tmp <= '0';
		else
			if sig_bal='1' then
				index := to_integer(unsigned(addr(BPU_ADDR_SIZE+1 downto 2)));
				entry := bht(index_r);
				index_r <= index;
				entry_r <= entry;
				sig_brt <= entry(1);
				sig_brt_tmp <= entry(1);
			else
				if ((reg_a=(reg_a'range=>'0')) and (opcd=OPCD_BEQZ)) or ((reg_a/=(reg_a'range=>'0')) and (opcd=OPCD_BNEZ)) then
					sig_brt <= '1';
					sig_brt_tmp <= '1';
				else
					sig_brt <= '0';
					sig_brt_tmp <= '0';
				end if;
			end if;
		end if;
	end process;
	
	P1: process(rst, ld_a, opcd_delay, sig_bal_delay)
		variable index : integer:= 0;
		variable entry : std_logic_vector(1 downto 0);
	begin
		if rst='0' then
			for i in 0 to BPU_BHT_SIZE-1 loop
				bht(i) <= (others=>'0');
			end loop;
			sig_bpw <= '0';
			sig_bpw_tmp <= '0';
		else
			if sig_bal_delay='1' then
				if (ld_a=(ld_a'range=>'0') and opcd_delay=OPCD_BEQZ and sig_brt_delay='1') or (ld_a/=(reg_a'range=>'0') and opcd_delay=OPCD_BNEZ and sig_brt_delay='1') then
					index := index_r_delay;
					entry := entry_r_delay;
					entry(0) := sig_brt_delay;
					bht(index) <= entry;
					sig_bpw <= '0';
					sig_bpw_tmp <= '0';
				else
					index := index_r_delay;
					entry := entry_r_delay;
					if entry = "10" then
						bht(index) <= "01";
					elsif entry = "01" then
						bht(index) <= "10";
					else
						entry(0) := not sig_brt_delay;
						bht(index) <= entry;
					end if;
					sig_bpw <= '1';
					sig_bpw_tmp <= '1';
				end if;
			else
				sig_bpw <= '0';
				sig_bpw_tmp <= '0';
			end if;
		end if;
	end process;
	
	P2: process(rst, clk)
	begin
		if rst='0' then
			sig_bal_delay <= '0';
			sig_brt_delay <= '0';
			opcd_delay <= (others=>'0');
			addr_delay <= (others=>'0');
			index_r_delay <= 0;
			entry_r_delay <= (others=>'0');
		else
			if clk'event and clk='1' then
				sig_bal_delay <= sig_bal;
				sig_brt_delay <= sig_brt_tmp;
				opcd_delay <= opcd;
				addr_delay <= addr;
				index_r_delay <= index_r;
				entry_r_delay <= entry_r;
			end if;
		end if;
	end process;
			
end branch_arch;
