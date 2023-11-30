# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_BURST_LEN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_M_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DDR_DOWN_ADDR_END" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DDR_DOWN_ADDR_START" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DDR_UP_ADDR_END" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DDR_UP_ADDR_START" -parent ${Page_0}
  ipgui::add_param $IPINST -name "READ_C_TRANSACTIONS_NUM" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RESULT_DATA_LENGTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WRITE_C_TRANSACTIONS_NUM" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_BURST_LEN { PARAM_VALUE.C_BURST_LEN } {
	# Procedure called to update C_BURST_LEN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_BURST_LEN { PARAM_VALUE.C_BURST_LEN } {
	# Procedure called to validate C_BURST_LEN
	return true
}

proc update_PARAM_VALUE.C_M_AXI_DATA_WIDTH { PARAM_VALUE.C_M_AXI_DATA_WIDTH } {
	# Procedure called to update C_M_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_DATA_WIDTH { PARAM_VALUE.C_M_AXI_DATA_WIDTH } {
	# Procedure called to validate C_M_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.DDR_DOWN_ADDR_END { PARAM_VALUE.DDR_DOWN_ADDR_END } {
	# Procedure called to update DDR_DOWN_ADDR_END when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DDR_DOWN_ADDR_END { PARAM_VALUE.DDR_DOWN_ADDR_END } {
	# Procedure called to validate DDR_DOWN_ADDR_END
	return true
}

proc update_PARAM_VALUE.DDR_DOWN_ADDR_START { PARAM_VALUE.DDR_DOWN_ADDR_START } {
	# Procedure called to update DDR_DOWN_ADDR_START when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DDR_DOWN_ADDR_START { PARAM_VALUE.DDR_DOWN_ADDR_START } {
	# Procedure called to validate DDR_DOWN_ADDR_START
	return true
}

proc update_PARAM_VALUE.DDR_UP_ADDR_END { PARAM_VALUE.DDR_UP_ADDR_END } {
	# Procedure called to update DDR_UP_ADDR_END when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DDR_UP_ADDR_END { PARAM_VALUE.DDR_UP_ADDR_END } {
	# Procedure called to validate DDR_UP_ADDR_END
	return true
}

proc update_PARAM_VALUE.DDR_UP_ADDR_START { PARAM_VALUE.DDR_UP_ADDR_START } {
	# Procedure called to update DDR_UP_ADDR_START when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DDR_UP_ADDR_START { PARAM_VALUE.DDR_UP_ADDR_START } {
	# Procedure called to validate DDR_UP_ADDR_START
	return true
}

proc update_PARAM_VALUE.READ_C_TRANSACTIONS_NUM { PARAM_VALUE.READ_C_TRANSACTIONS_NUM } {
	# Procedure called to update READ_C_TRANSACTIONS_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.READ_C_TRANSACTIONS_NUM { PARAM_VALUE.READ_C_TRANSACTIONS_NUM } {
	# Procedure called to validate READ_C_TRANSACTIONS_NUM
	return true
}

proc update_PARAM_VALUE.RESULT_DATA_LENGTH { PARAM_VALUE.RESULT_DATA_LENGTH } {
	# Procedure called to update RESULT_DATA_LENGTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RESULT_DATA_LENGTH { PARAM_VALUE.RESULT_DATA_LENGTH } {
	# Procedure called to validate RESULT_DATA_LENGTH
	return true
}

proc update_PARAM_VALUE.WRITE_C_TRANSACTIONS_NUM { PARAM_VALUE.WRITE_C_TRANSACTIONS_NUM } {
	# Procedure called to update WRITE_C_TRANSACTIONS_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WRITE_C_TRANSACTIONS_NUM { PARAM_VALUE.WRITE_C_TRANSACTIONS_NUM } {
	# Procedure called to validate WRITE_C_TRANSACTIONS_NUM
	return true
}


proc update_MODELPARAM_VALUE.C_BURST_LEN { MODELPARAM_VALUE.C_BURST_LEN PARAM_VALUE.C_BURST_LEN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_BURST_LEN}] ${MODELPARAM_VALUE.C_BURST_LEN}
}

proc update_MODELPARAM_VALUE.C_M_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_M_AXI_DATA_WIDTH PARAM_VALUE.C_M_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.DDR_UP_ADDR_START { MODELPARAM_VALUE.DDR_UP_ADDR_START PARAM_VALUE.DDR_UP_ADDR_START } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DDR_UP_ADDR_START}] ${MODELPARAM_VALUE.DDR_UP_ADDR_START}
}

proc update_MODELPARAM_VALUE.DDR_UP_ADDR_END { MODELPARAM_VALUE.DDR_UP_ADDR_END PARAM_VALUE.DDR_UP_ADDR_END } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DDR_UP_ADDR_END}] ${MODELPARAM_VALUE.DDR_UP_ADDR_END}
}

proc update_MODELPARAM_VALUE.DDR_DOWN_ADDR_START { MODELPARAM_VALUE.DDR_DOWN_ADDR_START PARAM_VALUE.DDR_DOWN_ADDR_START } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DDR_DOWN_ADDR_START}] ${MODELPARAM_VALUE.DDR_DOWN_ADDR_START}
}

proc update_MODELPARAM_VALUE.DDR_DOWN_ADDR_END { MODELPARAM_VALUE.DDR_DOWN_ADDR_END PARAM_VALUE.DDR_DOWN_ADDR_END } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DDR_DOWN_ADDR_END}] ${MODELPARAM_VALUE.DDR_DOWN_ADDR_END}
}

proc update_MODELPARAM_VALUE.WRITE_C_TRANSACTIONS_NUM { MODELPARAM_VALUE.WRITE_C_TRANSACTIONS_NUM PARAM_VALUE.WRITE_C_TRANSACTIONS_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WRITE_C_TRANSACTIONS_NUM}] ${MODELPARAM_VALUE.WRITE_C_TRANSACTIONS_NUM}
}

proc update_MODELPARAM_VALUE.READ_C_TRANSACTIONS_NUM { MODELPARAM_VALUE.READ_C_TRANSACTIONS_NUM PARAM_VALUE.READ_C_TRANSACTIONS_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.READ_C_TRANSACTIONS_NUM}] ${MODELPARAM_VALUE.READ_C_TRANSACTIONS_NUM}
}

proc update_MODELPARAM_VALUE.RESULT_DATA_LENGTH { MODELPARAM_VALUE.RESULT_DATA_LENGTH PARAM_VALUE.RESULT_DATA_LENGTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RESULT_DATA_LENGTH}] ${MODELPARAM_VALUE.RESULT_DATA_LENGTH}
}

