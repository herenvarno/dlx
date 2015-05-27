

entity Brancher is
	generic (
		data_width : integer := C_SYS_DATA_WIDTH
	);
	port (
		enable : in std_logic;
		opcode : in std_logic_vector(1 downto 0); 
		reg_cond : in std_logic_vector(data_width-1 downto 0);
		reg_nxpc : in std_logic_vector(data_width-1 downto 0);
		reg_addr : in std_logic_vector(data_width-1 downto 0);
		imm_addr : in std_logic_vector(data_width-1 downto 0);
		mux_sel  : out std_logic_vector(data_width-1 downto 0);
		out_addr : out std_logic_vector(data_width-1 downto 0)
	);
end Brancher;

architecture brancher_arch_behav of Brancher is

	component Adder is
		generic (
			data_width : integer : C_SYS_DATA_WIDTH
		);
		port (
			cin : in std_logic;
			a,b : in std_logic_vector(data_width-1 downto 0);
			s   : out std_logic_vector(data_width-1 downto 0);
			cout: out std_logic
		);
	end component;
	
	signal abs_addr : std_logic_vector(data_width-1 downto 0);
begin
	ADD0: Adder
		generic map (data_width)
		port map ('0', reg_nxpc, imm_addr, abs_addr, open);
		
	PROC: process
		if enable = '0' then
			mux_sel <= '0';					-- always select PC+4
		else
			if opcode(1) = '0' then			-- It's a JUMP 
				mux_sel <= '1';				-- always select Jump address
				if opcode(0) = '0' then		-- It's a J/JAL
					out_addr <= abs_addr;
				else						-- It's a JR/JALR
					out_addr <= reg_addr;
				end if;
			else							-- It's a Branch
				out_addr <= abs_addr;
				if opcode(0) = '0' then		-- It's a BEQZ
					if reg_cond = (others=>'0') then
						mux_sel <= '1';
					else
						mux_sel <= '0';
					end if;
				else						-- It's a BNEZ
					if reg_cond = (others=>'0') then
						mux_sel <= '0';
					else
						mux_sel <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;
end brancher_arch_behav;
			
				
