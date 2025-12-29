class_name SpeedIncreaseItem
extends BasePickItem


func _on_my_area_interacted_implementation():
	var signal_data := GlobalSignal.player_speed_increase
	u.safe_emit(signal_data, {GlobalSignal.payload_amount_field: + 0.5}, false)
