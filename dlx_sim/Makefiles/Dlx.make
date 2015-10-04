# Modify here if needed
MAXSIMTIME=1000ns

# Modify here
TARGET=Dlx
# Modify here
TARGET_LABEL=dlx
# Modify here
TARGET_LEVEL=a

# Modify here if needed
PATH_ROOT=../../dlx_vhd
PATH_SRC=$(PATH_ROOT)/src
PATH_TB=$(PATH_ROOT)/tb
# Modify here
PATH_TARG=$(PATH_SRC)
PATH_CORE=$(PATH_TARG)/$(TARGET_LEVEL)-$(TARGET).core

# Modify here
DEPENDENCE_G=\
	$(PATH_SRC)/0-Consts.vhd\
	$(PATH_SRC)/0-Funcs.vhd\
	$(PATH_SRC)/0-Types.vhd
# Modify here
DEPENDENCE_L=\
	$(PATH_SRC)/a.a-ControlUnit.core/a.a.a-CwGenerator.vhd\
	$(PATH_SRC)/a.a-ControlUnit.core/a.a.b-StallGenerator.vhd\
	$(PATH_SRC)/a.a-ControlUnit.core/a.a.c-Branch.vhd\
	$(PATH_SRC)/a.a-ControlUnit.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.0-Mux.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.0-Mux4.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.0-Reg.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.0-Sipo.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.a-Alu.core/a.b.a.a-Adder.core/a.b.a.a.0-FullAdder.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.a-Alu.core/a.b.a.a-Adder.core/a.b.a.a.0-Rca.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.a-Alu.core/a.b.a.a-Adder.core/a.b.a.a.0-AdderCarrySelect.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.a-Alu.core/a.b.a.a-Adder.core/a.b.a.a.0-AdderSumGenerator.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.a-Alu.core/a.b.a.a-Adder.core/a.b.a.a.0-P4AdderCarryGenerator.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.a-Alu.core/a.b.a.a-Adder.core/a.b.a.a.a-P4Adder.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.a-Alu.core/a.b.a.a-Adder.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.a-Alu.core/a.b.a.b-Shifter.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.a-Alu.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.b-Extender.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.c-RegisterFile.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.e-FwdMux2.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.f-Mul.core/a.b.f.0-AddSub.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.f-Mul.core/a.b.f.0-BoothEncoder.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.f-Mul.core/a.b.f.a-BoothMul.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.f-Mul.vhd\
	$(PATH_SRC)/a.b-DataPath.core/a.b.g-Div.vhd\
	$(PATH_SRC)/a.b-DataPath.vhd\
	$(PATH_SRC)/a.c-InstructionRam.vhd\
	$(PATH_SRC)/a.d-DataRam.vhd\
	
COMPONENT=$(PATH_TARG)/$(TARGET_LEVEL)-$(TARGET).vhd
TESTBENCH=$(PATH_TB)/$(TARGET_LEVEL)-tb$(TARGET).vhd
TBCFGNAME=tb_$(TARGET_LABEL)_cfg
SIMWAVE=$(TBCFGNAME).ghw

CC=ghdl
$(TARGET): $(DEPENDENCE_G) $(DEPENDENCE_L) $(COMPONENT) $(TESTBENCH)
	$(CC) -a --ieee=synopsys $(DEPENDENCE_G) $(DEPENDENCE_L) $(COMPONENT) $(TESTBENCH)
	$(CC) -e --ieee=synopsys $(TBCFGNAME)
	cp ../../asm_example/test_dump.txt ./test.asm.mem
	./$(TBCFGNAME) --wave=$(SIMWAVE) --stop-time=$(MAXSIMTIME)
	gtkwave $(SIMWAVE)
.PHONY : clean
clean:
	$(CC) --clean
	rm -rf $(SIMWAVE) *.cf *.ghw
