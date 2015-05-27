# Modify here if needed
MAXSIMTIME=10ns

# Modify here
TARGET=Shifter
# Modify here
TARGET_LABEL=shifter
# Modify here
TARGET_LEVEL=a.b.a.b

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
DEPENDENCE_L=

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
