onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk
add wave -noupdate /tb/rst_n
add wave -noupdate /tb/valid_insert
add wave -noupdate /tb/header_insert
add wave -noupdate /tb/ready_insert
add wave -noupdate -radix binary /tb/keep_insert
add wave -noupdate /tb/valid_in
add wave -noupdate /tb/data_in
add wave -noupdate /tb/ready_in
add wave -noupdate -radix binary /tb/keep_in
add wave -noupdate /tb/last_in
add wave -noupdate /tb/data_out
add wave -noupdate /tb/valid_out
add wave -noupdate /tb/ready_out
add wave -noupdate -radix binary /tb/keep_out
add wave -noupdate /tb/last_out
add wave -noupdate -radix unsigned /tb/u_inst/total_zeros
add wave -noupdate -radix unsigned /tb/u_inst/final_zeros
add wave -noupdate -radix unsigned /tb/u_inst/header_zeros
add wave -noupdate /tb/u_inst/ZEROS_WD
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {45 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 201
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {210 ns}
