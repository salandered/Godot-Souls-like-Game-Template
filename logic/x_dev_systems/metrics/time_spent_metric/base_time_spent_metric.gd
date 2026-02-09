@tool

@abstract
class_name BaseTimeSpentMetric
extends BaseDVCDependentNode


@export var metric_label: Label


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		metric_label,
		get_character()
	]


@abstract func get_character() -> BaseStaticCharacter


## can be overriden
func nth_frame() -> int:
	return 1


func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if not get_character(): return

	if not u.is_nth_frame(nth_frame()):
		return
	
	var ts := get_ts_from_state()
	if ts != -1.0:
		_update_metric(ts)


func get_ts_from_state() -> float:
	if not get_character(): return -1.0
	var curr_state := get_character().get_current_state()
	if not curr_state: return -1.0
	
	var time_spent := curr_state.get_actual_time_spent()
	return time_spent


func _update_metric(metric_value: Variant, fmt_show_vector_len: bool = true) -> void:
	if not metric_label:
		return

	var new_text := pp.metric_fmt(metric_value, fmt_show_vector_len)
	
	metric_label.text = new_text
