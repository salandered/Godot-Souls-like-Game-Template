extends Camera3D
class_name TopDownCamera


@export var target: Node3D
@export var height: float = 10.0
@export var _enabled: bool = false
## doesn't matter if _enabled false
@export var _process_input: bool = false


func _ready() -> void:
	rotation_degrees = Vector3(-90, 0, 0)


func _process(_delta: float) -> void:
	if not _enabled: return

	if target:
		# snap to target xz, y fixed
		global_position = Vector3(
			target.global_position.x,
			height,
			target.global_position.z
		)


func set_camera_enabled(value: bool, process_input: bool = false):
	_enabled = value
	_process_input = process_input


func _input(event: InputEvent) -> void:
	if not _enabled or not _process_input:
		return

	_handle_mouse_wheel(event)
	_handle_fov_input(event)

	
func _handle_mouse_wheel(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			height += 1
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			height -= 1
			get_viewport().set_input_as_handled()


func _handle_fov_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			fov = max(fov - 2, 10)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			fov = min(fov + 2, 170)
			get_viewport().set_input_as_handled()
