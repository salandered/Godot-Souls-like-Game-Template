class_name SpeedIncreaseItem
extends BasePickItem


func _on_my_area_interacted_implementation():
	var signal_data := GlobalSignal.player_speed_increase
	SigUtils.safe_emit(signal_data, {SPS.amount_field: + 0.3}, false)
