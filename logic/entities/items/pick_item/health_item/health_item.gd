class_name HealthItem
extends BasePickItem


func _on_my_area_interacted_implementation():
	var signal_data := GlobalSignal.player_change_health
	SigUtils.safe_emit_sig_data(signal_data, {SPS.amount_field: + 80}, true)
