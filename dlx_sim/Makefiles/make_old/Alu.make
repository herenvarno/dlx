# Modify here if needed
MAXSIMTIME=10ns

# Modify here
TARGET=Alu
# Modify here
TARGET_LABEL=alu
# Modify here
TARGET_LEVEL=a.b.a

# Modify here if needed
PATH_ROOT=../../dlx_vhd
PATH_SRC=$(PATH_ROOT)/src
PATH_TB=$(PATH_ROOT)/tb
# Modify here
PATH_TARG=$(PATH_SRC)/a.b-DataPath.core
PATH_CORE=$(PATH_TARG)/$(TARGET_LEVEL)-$(TARGET).core

# Modify here
DEPENDENCE_G=\
	$(PATH_SRC)/0-Consts.vhd\
	$(PATH_SRC)/0-Funcs.vhd\
	$(PATH_SRC)/0-Types.vhd
# Modify here
DEPENDENCE_L=\
	$(PATH_SRC)/a.b-DataPath.core/a.b.0-Mux.vhd\
	$(PATH_CORE)/$(TARGET_LEVEL).b-Shifter.vhd\
	$(PATH_CORE)/$(TARGET_LEVEL).a-Adder.core/$(TARGET_LEVEL).a.0-FullAdder.vhd\
	$(PATH_CORE)/$(TARGET_LEVEL).a-Adder.core/$(TARGET_LEVEL).a.0-Rca.vhd\
	$(PATH_CORE)/$(TARGET_LEVEL).a-Adder.core/$(TARGET_LEVEL).a.0-AdderSumGenerator.vhd\
	$(PATH_CORE)/$(TARGET_LEVEL).a-Adder.core/$(TARGET_LEVEL).a.0-AdderCarrySelect.vhd\
	$(PATH_CORE)/$(TARGET_LEVEL).a-Adder.core/$(TARGET_LEVEL).a.0-P4AdderCarryGenerator.vhd\
	$(PATH_CORE)/$(TARGET_LEVEL).a-Adder.core/$(TARGET_LEVEL).a.a-P4Adder.vhd\
	$(PATH_CORE)/$(TARGET_LEVEL).a-Adder.vhd\

COMPONENT=$(PATH_TARG)/$(TARGET_LEVEL)-$(TARGET).vhd
TESTBENCH=$(PATH_TB)/$(TARGET_LEVEL)-tb$(TARGET).vhd
TBCFGNAME=tb_$(TARGET_LABEL)_cfg
SIMWAVE=$(TBCFGNAME).ghw

CC=ghdl
$(TARGET): $(DEPENDENCE_G) $(DEPENDENCE_L) $(COMPONENT) $(TESTBENCH)
	$(CC) -a --ieee=synopsys $(DEPENDENCE_G) $(DEPENDENCE_L) $(COMPONENT) $(TESTBENCH)
	$(CC) -e $(TBCFGNAME)
	./$(TBCFGNAME) --wave=$(SIMWAVE) --stop-time=$(MAXSIMTIME)
	gtkwave $(SIMWAVE)
.PHONY : clean
clean:
	$(CC) --clean
	rm -rf $(SIMWAVE) *.cf *.ghw
