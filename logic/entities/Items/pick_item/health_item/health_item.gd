class_name HealthItem
extends BasePickItem


func _on_my_area_interacted_implementation():
	var signal_data := GlobalSignal.player_change_health
	SigUtils.safe_emit(signal_data, {GlobalSignal.payload_amount_field: + 80}, true)
