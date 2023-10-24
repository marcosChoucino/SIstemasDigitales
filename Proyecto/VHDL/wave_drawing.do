onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lcd_drawing_testbench/tb_CLK
add wave -noupdate /lcd_drawing_testbench/tb_DEL_SCREEN
add wave -noupdate /lcd_drawing_testbench/tb_DRAWFIG
add wave -noupdate /lcd_drawing_testbench/tb_COLOUR_CODE
add wave -noupdate /lcd_drawing_testbench/tb_DONE_CURSOR
add wave -noupdate /lcd_drawing_testbench/tb_DONE_COLOUR
add wave -noupdate /lcd_drawing_testbench/tb_OP_SETCURSOR
add wave -noupdate /lcd_drawing_testbench/tb_XCOL
add wave -noupdate /lcd_drawing_testbench/tb_YROW
add wave -noupdate /lcd_drawing_testbench/tb_OP_DRAWINGCOLOUR
add wave -noupdate /lcd_drawing_testbench/tb_RGB
add wave -noupdate /lcd_drawing_testbench/tb_NUM_PIX
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1400002 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1024 ns}
