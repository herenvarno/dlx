# Modify here if needed
MAXSIMTIME=30ns

# Modify here
TARGET=StallGenerator
# Modify here
TARGET_LABEL=stall_generator
# Modify here
TARGET_LEVEL=a.a.b

# Modify here if needed
PATH_ROOT=../../dlx_vhd
PATH_SRC=$(PATH_ROOT)/src
PATH_TB=$(PATH_ROOT)/tb
# Modify here
PATH_TARG=$(PATH_SRC)/a.a-ControlUnit.core/
PATH_CORE=

# Modify here
DEPENDENCE_G=\
	$(PATH_SRC)/0-Consts.vhd\
	$(PATH_SRC)/0-Funcs.vhd\
	$(PATH_SRC)/0-Types.vhd
# Modify here
DEPENDENCE_L=\

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
