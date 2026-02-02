class_name DodgeIncreaseItem
extends BasePickItem


func _on_my_area_interacted_implementation():
	var signal_data := GlobalSignal.player_dodge_increase
	SigUtils.safe_emit(signal_data, {SPS.amount_field: + 2}, false)
