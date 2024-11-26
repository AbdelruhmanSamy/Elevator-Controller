vsim work.integrated_model
add wave -position insertpoint sim:/integrated_model/u1/*
add wave -position insertpoint sim:/integrated_model/u2/*
add wave -position insertpoint  \
sim:/integrated_model/clk
add wave -position insertpoint  \
sim:/integrated_model/reset
add wave -position insertpoint  \
sim:/integrated_model/take_request
add wave -position insertpoint  \
sim:/integrated_model/request_btn
add wave -position insertpoint  \
sim:/integrated_model/curr_floor
add wave -position insertpoint  \
sim:/integrated_model/door_open \
sim:/integrated_model/mv_up \
sim:/integrated_model/mv_down
add wave -position insertpoint  \
sim:/integrated_model/u3/state
force -freeze sim:/integrated_model/clk 1 0, 0 {5 ps} -r 10
force -freeze sim:/integrated_model/reset 1 0
force -freeze sim:/integrated_model/take_request 1 0
force -freeze sim:/integrated_model/request_btn 0011 0
run
force -freeze sim:/integrated_model/reset 0 0
run
force -freeze sim:/integrated_model/request_btn 0001 0
run
force -freeze sim:/integrated_model/request_btn 0111 0
run
force -freeze sim:/integrated_model/take_request 0 0
run