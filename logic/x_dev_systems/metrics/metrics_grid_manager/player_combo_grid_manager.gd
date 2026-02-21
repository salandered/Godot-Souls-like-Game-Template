@tool
class_name PlayerComboGridManager
extends BaseMetricsGridManager


## Time in seconds before the combo chain is cleared if no new moves occur
@export var combo_timeout: float = 1.8


# State for tracking the current sequence
var _combo_chain: Array[String] = []
var _clear_tween: Tween


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + []


func get_dvc_op_key() -> DVS.KeyBOverlayPanel:
	return DVS.KeyBOverlayPanel.PLAYER_COMBO


func _supported_signal_pairs() -> Array[Array]:
	return [
		[GlobalSignal.SIG_player_combo_triggered, _on_SIG_player_combo_triggered]
	]


func initialise_implementation() -> void:
	use_process = false
	super.initialise_implementation()


func _on_SIG_player_combo_triggered(payload: Dictionary[StringName, Variant]):
	var _r_state := SigUtils.safe_get_string_payload_value(payload, SPS.state_name_field)
	if _r_state.err: return
	var _r_triggered_state := SigUtils.safe_get_string_payload_value(payload, SPS.triggered_state_field)
	if _r_triggered_state.err: return
	
	__log_("_update_combo_metrics")
	_update_combo_metrics(_r_state.value, _r_triggered_state.value)


func _update_combo_metrics(curr_state: String, triggered_state: String) -> void:
	if _combo_chain.is_empty():
		_combo_chain = [curr_state, triggered_state]
	else:
		if _combo_chain.back() == curr_state:
			_combo_chain.append(triggered_state)
		else:
			# reset chain
			_combo_chain = [curr_state, triggered_state]

	# e.g. Idle -> Attack1 -> Attack2
	var display_text := " -> ".join(_combo_chain)
	_metrics_grid.update_metric("Combo Chain", display_text)

	if _clear_tween and _clear_tween.is_valid():
		_clear_tween.kill()
	
	_clear_tween = create_tween()
	_clear_tween.tween_interval(combo_timeout)
	_clear_tween.tween_callback(_reset_metric)

func _reset_metric():
	_combo_chain.clear()
	## clears the metric 
	_metrics_grid.update_metric("Combo Chain", "")
