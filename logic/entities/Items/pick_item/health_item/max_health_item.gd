class_name MaxHealthItem
extends BasePickItem


func _on_my_area_interacted_implementation():
	var signal_data := GlobalSignal.player_max_health_increase
	u.safe_emit(signal_data, {GlobalSignal.payload_amount_field: + 40}, true)
