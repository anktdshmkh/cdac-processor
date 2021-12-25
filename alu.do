project compileall
vsim work.alu(alu_a)
view signals
add wave *
force -freeze sim:/alu/in_a 00001110 0
force -freeze sim:/alu/in_b 01010000 0
force -freeze sim:/alu/op_sel 0000 0
run
run
force -freeze sim:/alu/op_sel 0001 0
run
force -freeze sim:/alu/op_sel 0010 0
run
force -freeze sim:/alu/op_sel 0011 0
run
force -freeze sim:/alu/op_sel 0100 0
run
force -freeze sim:/alu/in_b 00000111 0
run
force -freeze sim:/alu/op_sel 0101 0
run
force -freeze sim:/alu/op_sel 0110 0
run
force -freeze sim:/alu/in_b 00001110 0
run
force -freeze sim:/alu/op_sel 1000 0
run
force -freeze sim:/alu/op_sel 1001 0
run
force -freeze sim:/alu/op_sel 1100 0
run
force -freeze sim:/alu/op_sel 1101 0
run
force -freeze sim:/alu/op_sel 1110 0
run
force -freeze sim:/alu/op_sel 1111 0
run
run