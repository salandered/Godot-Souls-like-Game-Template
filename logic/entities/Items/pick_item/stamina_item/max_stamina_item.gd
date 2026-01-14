class_name MaxStaminaItem
extends BasePickItem


func _on_my_area_interacted_implementation():
	var signal_data := GlobalSignal.player_max_stamina_increase
	u.safe_emit(signal_data, {GlobalSignal.payload_amount_field: + 20}, false)
