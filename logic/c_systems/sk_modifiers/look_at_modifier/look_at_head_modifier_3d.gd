extends LookAtModifier3DLogger
class_name LookAtHeadModifier3D


@export var max_influence: float = 1.0
@export var tag: String = ""

var _tween_influence: Tween
var _target: LookAtCharacterMarker


var GLOBAL_ACTIVE_FLAG: bool = false


func _ready() -> void:
	active = false


func set_marker(marker: LookAtCharacterMarker):
	if marker:
		__log_("set_marker", "marker", marker)
		_target = marker
		target_node = get_path_to(marker)
	else:
		__log_warn("null marker provided")


func set_to_work(toggle: bool, time_dur: float = 0.5) -> void:
	if not target_node:
		__log_("set_to_work", "not target_node")
		return
	if not is_instance_valid(_target):
		__log_("set_to_work", "not is_instance_valid(_target)")
		return

	if GLOBAL_ACTIVE_FLAG == toggle:
		__log_("set_to_work", "GLOBAL_ACTIVE_FLAG == toggle", "return")
		return
	__log_("set_to_work", "going to apply toggle", toggle)

	if _tween_influence:
		_tween_influence.kill()
	
	_tween_influence = create_tween()
	var target_val = 0.0
	if toggle:
		active = true
		GLOBAL_ACTIVE_FLAG = true
		target_val = max_influence
		_tween_influence.tween_property(self , "influence", target_val, time_dur)
	else:
		GLOBAL_ACTIVE_FLAG = false
		target_val = 0.0
		_tween_influence.tween_property(self , "influence", target_val, time_dur)
		_tween_influence.tween_callback(func(): active = false)


##


func __LOG_B() -> bool:
	return false
