library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;
use work.Consts.all;
use work.Funcs.all;

entity tbDataPath is
end tbDataPath;

architecture tb_data_path_arch of tbDataPath is
	constant ADDR_SIZE : integer := C_SYS_ADDR_SIZE;
	constant DATA_SIZE : integer := C_SYS_DATA_SIZE;
	constant ISTR_SIZE : integer := C_SYS_ISTR_SIZE;
	constant OPCD_SIZE : integer := C_SYS_OPCD_SIZE;
	constant IMME_SIZE : integer := C_SYS_IMME_SIZE;
	constant CWRD_SIZE : integer := C_SYS_CWRD_SIZE;
	constant CALU_SIZE : integer := C_CTR_CALU_SIZE;	
	constant DRCW_SIZE : integer := C_CTR_DRCW_SIZE;
	
	component DataPath is
		generic (
			ADDR_SIZE : integer := C_SYS_ADDR_SIZE;
			DATA_SIZE : integer := C_SYS_DATA_SIZE;
			ISTR_SIZE : integer := C_SYS_ISTR_SIZE;
			OPCD_SIZE : integer := C_SYS_OPCD_SIZE;
			IMME_SIZE : integer := C_SYS_IMME_SIZE;
			CWRD_SIZE : integer := C_SYS_CWRD_SIZE;	-- Datapath Contrl Word
			CALU_SIZE : integer := C_CTR_CALU_SIZE;	
			DRCW_SIZE : integer := C_CTR_DRCW_SIZE
		);
	  	port (
	  		clk			: in std_logic;
	  		rst			: in std_logic;
	  		istr_addr	: out std_logic_vector(ADDR_SIZE-1 downto 0);
	  		istr_val	: in std_logic_vector(ISTR_SIZE-1 downto 0);
	  		ir_out		: out std_logic_vector(ISTR_SIZE-1 downto 0);
	  		reg_a_out	: out std_logic_vector(DATA_SIZE-1 downto 0);
	  		data_addr	: out std_logic_vector(ADDR_SIZE-1 downto 0);
	  		data_i_val	: in std_logic_vector(DATA_SIZE-1 downto 0);
	  		data_o_val	: out std_logic_vector(DATA_SIZE-1 downto 0);
	  		cw			: in std_logic_vector(CWRD_SIZE-1 downto 0);
	  		dr_cw		: out std_logic_vector(DRCW_SIZE-1 downto 0);
	  		calu		: in std_logic_vector(CALU_SIZE-1 downto 0)
	  	);
	end component;
	signal clk			: std_logic := '0';
	signal rst			: std_logic;
	signal istr_addr	: std_logic_vector(ADDR_SIZE-1 downto 0);
	signal istr_val		: std_logic_vector(ISTR_SIZE-1 downto 0);
	signal ir_out		: std_logic_vector(ISTR_SIZE-1 downto 0);
	signal reg_a_out	: std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_addr	: std_logic_vector(ADDR_SIZE-1 downto 0);
	signal data_i_val	: std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_o_val	: std_logic_vector(DATA_SIZE-1 downto 0);
	signal cw			: std_logic_vector(CWRD_SIZE-1 downto 0);
	signal dr_cw		: std_logic_vector(DRCW_SIZE-1 downto 0);
	signal calu			: std_logic_vector(CALU_SIZE-1 downto 0);
begin
	DP: DataPath
	port map(clk,rst,istr_addr,istr_val,ir_out,reg_a_out,data_addr,data_i_val,data_o_val,cw,dr_cw,calu);
	
	CLK0: process(clk)
	begin
		clk <= not (clk) after 0.5 ns;
	end process;
	
	rst <= '0', '1' after 1 ns;
	istr_val <= x"20410001", x"20420002" after 2 ns, x"20430003" after 3 ns, x"20440004" after 4 ns;
	data_i_val <= x"00000000";
	cw <= "1010101000011";
	calu <= "00000";
end tb_data_path_arch;

configuration tb_data_path_cfg of tbDataPath is
for tb_data_path_arch
end for;
end tb_data_path_cfg;
