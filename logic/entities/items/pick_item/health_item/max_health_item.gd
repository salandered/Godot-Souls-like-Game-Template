class_name MaxHealthItem
extends BasePickItem


func _on_my_area_interacted_implementation():
	var signal_data := GlobalSignal.player_max_health_increase
	SigUtils.safe_emit_sig_data(signal_data, {SPS.amount_field: + 40}, true)
