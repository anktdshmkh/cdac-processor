project compileall
vsim work.reg_bank(reg_bank_a)
view signals
add wave *
force -freeze sim:/reg_bank/reset_a 1 0
force -freeze sim:/reg_bank/wr_en 0 0
force -freeze sim:/reg_bank/ce 00000 0
force -freeze sim:/reg_bank/sel 000 0
force -freeze sim:/reg_bank/clk 1 0, 0 {50 ns} -r 100
run
force -freeze sim:/reg_bank/din 10101010 0
force -freeze sim:/reg_bank/xin 00001111 0
run
force -freeze sim:/reg_bank/reset_a 0 0
run
force -freeze sim:/reg_bank/ce 10000 0
run
force -freeze sim:/reg_bank/wr_en 1 0
run
force -freeze sim:/reg_bank/wr_en 0 0
run
force -freeze sim:/reg_bank/ce 01000 0
run
force -freeze sim:/reg_bank/wr_en 1 0
run
force -freeze sim:/reg_bank/din 00000010 0
force -freeze sim:/reg_bank/ce 00100 0
run
force -freeze sim:/reg_bank/din 00000100 0
force -freeze sim:/reg_bank/ce 00010 0
run
force -freeze sim:/reg_bank/din 00001000 0
force -freeze sim:/reg_bank/ce 00001 0
run
run
force -freeze sim:/reg_bank/wr_en 0 0
run
force -freeze sim:/reg_bank/sel 001 0
run
force -freeze sim:/reg_bank/sel 010 0
run
force -freeze sim:/reg_bank/sel 011 0
run
force -freeze sim:/reg_bank/sel 100 0
run
force -freeze sim:/reg_bank/sel 101 0
run
force -freeze sim:/reg_bank/sel 110 0
run
force -freeze sim:/reg_bank/sel 111 0
run