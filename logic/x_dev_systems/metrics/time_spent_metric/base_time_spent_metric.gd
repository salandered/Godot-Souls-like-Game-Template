@tool

@abstract
class_name BaseTimeSpentMetric
extends DVCSignalEnabledNode


@export var ts_curr_state_label: Label


const DEF_WRONG_VALUE := -1.0
const DEF_NO_VALUE := 0.0


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		ts_curr_state_label,
		get_character()
	]


@abstract func get_character() -> BaseStaticCharacter


func reset_visuals() -> void:
	pass


func _initialise_implementation() -> void:
	_update_metric(ts_curr_state_label, DEF_NO_VALUE)


## can be overriden
func nth_frame() -> int:
	return 5


func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if not get_character(): return

	if not u.is_nth_frame(nth_frame()):
		return
	
	_process_imp(delta)
	var ts := get_ts_from_state()
	if ts != DEF_WRONG_VALUE:
		_update_metric(ts_curr_state_label, ts)


func _process_imp(delta: float):
	return


func get_ts_from_state() -> float:
	if not get_character(): return DEF_WRONG_VALUE
	var curr_state := get_character().get_current_state()
	if not curr_state: return DEF_WRONG_VALUE
	
	var time_spent := curr_state.get_actual_time_spent()
	return time_spent


func _update_metric(metric_label: Label, metric_value: Variant, fmt_show_vector_len: bool = true) -> void:
	if not metric_label:
		return

	if metric_value == DEF_WRONG_VALUE:
		metric_value = DEF_NO_VALUE

	var new_text := pp.metric_fmt(metric_value, fmt_show_vector_len)
	
	metric_label.text = new_text
