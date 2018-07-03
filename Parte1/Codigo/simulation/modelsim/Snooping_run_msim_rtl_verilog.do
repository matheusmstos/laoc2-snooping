transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Aluno/Downloads/TP4/Codigo {C:/Users/Aluno/Downloads/TP4/Codigo/Snooping.v}

