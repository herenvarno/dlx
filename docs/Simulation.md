# Automatic Simulation HOWTO

## Tools
* OS: Linux
* Compile and Simulate Tool: ghdl
* Auto Tool Chain: gnu-make
* Script support: bash
* Waveform Viewer: gtkwave

## Commands
To simulate a component, use:
`./sim [EntityName]`

To clean up, use:
`./sim clean`

## Specific Requirements
1. All Makefiles should be placed in folder "$PROJECT\_PATH/dlx\_sim/Makefiles/".
2. All Testbenches should be placed in folder "$PROJECT\_PATH/dlx\_vhd/tb/".
3. Pay attention to the naming rules of Makefile and Testbench.
4. Inside Testbench, a configuratiion named as "tb\_[Component_Name]\_cfg" is required.
