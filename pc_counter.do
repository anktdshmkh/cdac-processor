project compileall
vsim work.pc_counter(pc_counter_a)

view signals

add wave *
force -freeze sim:/pc_counter/reset_a 1 0
force -freeze sim:/pc_counter/clk 1 0, 0 {50 ns} -r 100
force -freeze sim:/pc_counter/pc_ce 1 0
run
force -freeze sim:/pc_counter/jmp_cntrl 0 0
force -freeze sim:/pc_counter/off_cntrl 0 0
force -freeze sim:/pc_counter/off_set 11111100 0
force -freeze sim:/pc_counter/mem_add 0000111100000000 0
run
force -freeze sim:/pc_counter/reset_a 0 0
run
run
run
run
run
run
run
run
run
run
run
run
force -freeze sim:/pc_counter/jmp_cntrl 1 0
run
force -freeze sim:/pc_counter/jmp_cntrl 0 0
run
force -freeze sim:/pc_counter/off_cntrl 1 0
run
run
force -freeze sim:/pc_counter/jmp_cntrl 1 0
run
force -freeze sim:/pc_counter/jmp_cntrl 0 0
run
run
run
run
run
run
run
run
force -freeze sim:/pc_counter/off_cntrl 0 0
run
run
run
run
run