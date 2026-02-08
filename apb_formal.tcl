clear -all

analyze -sv12  apb_master.sv \
		apb_slave.sv \
		apb_top.sv

analyze -sv12 apb_fv_tb.sv \ apb_bind_new.sv

check_cov -init -type all -model {branch toggle statement} -toggle_ports_only

elaborate -top apb_top

clock pclk

reset -expression {presetn == 1'b0}

prove -all

check_cov -measure -type {coi stimuli proof bound} -time_limit 60s -bg
