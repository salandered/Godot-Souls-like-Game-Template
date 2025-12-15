class_name TargetMarker
extends Sprite3D

@export var height_offset: float = 0.0
@export var smooth_speed: float = 20.0

var _current_target: Node3D = null

var y_shift_from_target: float = 0.0

func _ready() -> void:
	visible = false
	top_level = true # detaches from parent transform

func _process(delta: float) -> void:
	if not is_instance_valid(_current_target):
		if visible:
			_set_active(false)
		return

	# interpolate pos for smoothness
	var target_pos = _current_target.global_position
	target_pos.y += get_y_shift()
	global_position = global_position.lerp(target_pos, smooth_speed * delta)


func set_target(new_target: BaseCameraTarget) -> void:
	if not new_target:
		return
	_current_target = new_target
	_set_active(true)
	
	global_position = _current_target.global_position
	y_shift_from_target = new_target.Y_ui_marker_shift
	global_position.y = get_y_shift()


func reset_target() -> void:
	_current_target = null
	y_shift_from_target = 0.0
	_set_active(false)


func get_y_shift() -> float:
	return height_offset + y_shift_from_target


func _set_active(state: bool) -> void:
	visible = state
	set_process(state) # Stop processing when hidden to save performance
