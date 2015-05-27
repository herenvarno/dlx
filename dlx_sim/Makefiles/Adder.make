# Modify here if needed
MAXSIMTIME=10ns

# Modify here
TARGET=Adder
# Modify here
TARGET_LABEL=adder
# Modify here
TARGET_LEVEL=a.b.a.a

# Modify here if needed
PATH_ROOT=../../dlx_vhd
# Modify here
PATH_TARG=$(PATH_ROOT)/a.b-DataPath.core/a.b.a-Alu.core
PATH_CORE=$(PATH_TARG)/$(TARGET_LEVEL)-$(TARGET).core

# Modify here
DEPENDENCE_G=\
	$(PATH_ROOT)/0-Consts.vhd\
	$(PATH_ROOT)/0-Funcs.vhd\
	$(PATH_ROOT)/0-Types.vhd
# Modify here
DEPENDENCE_L=\
	$(PATH_ROOT)/a.b-DataPath.core/a.b.0-Mux.vhd\
	$(PATH_CORE)/$(TARGET_LEVEL).0-FullAdder.vhd\
	$(PATH_CORE)/$(TARGET_LEVEL).0-Rca.vhd\
	$(PATH_CORE)/$(TARGET_LEVEL).0-AdderSumGenerator.vhd\
	$(PATH_CORE)/$(TARGET_LEVEL).0-AdderCarrySelect.vhd\
	$(PATH_CORE)/$(TARGET_LEVEL).0-P4AdderCarryGenerator.vhd\
	$(PATH_CORE)/$(TARGET_LEVEL).a-P4Adder.vhd

COMPONENT=$(PATH_TARG)/$(TARGET_LEVEL)-$(TARGET).vhd
TESTBENCH=$(PATH_ROOT)/tb/$(TARGET_LEVEL)-tb$(TARGET).vhd
TBCFGNAME=tb_$(TARGET_LABEL)_cfg
SIMWAVE=$(TBCFGNAME).ghw

CC=ghdl
$(TARGET): $(DEPENDENCE) $(COMPONENT) $(TESTBENCH)
	$(CC) -a --ieee=synopsys $(DEPENDENCE_G) $(DEPENDENCE_L) $(COMPONENT) $(TESTBENCH)
	$(CC) -e $(TBCFGNAME)
	./$(TBCFGNAME) --wave=$(SIMWAVE) --stop-time=$(MAXSIMTIME)
	gtkwave $(SIMWAVE)
.PHONY : clean
clean:
	$(CC) --clean
	rm -rf $(SIMWAVE) *.cf *.ghw