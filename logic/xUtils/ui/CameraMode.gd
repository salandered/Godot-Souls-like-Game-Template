extends Node3D

@export var camera_speed := 10.0
@export var mouse_sensitivity := 0.003
@export var speed_multiplier := 1.1 # How much each scroll step multiplies speed

@onready var camera: Camera3D
@onready var _cached_camera: Camera3D
@onready var _enabled := false

# For mouse movement
var _mouse_motion := Vector2.ZERO


func _ready() -> void:
	if OS.is_debug_build():
		_enabled = true
	set_process(_enabled)
	set_process_input(_enabled)
	set_process_unhandled_input(_enabled)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed() and not event.is_echo():
			if event.keycode == KEY_F9:
				_toggle_camera_mode()
	
	# Handle mouse wheel for speed adjustment
	if event is InputEventMouseButton and visible:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_speed *= speed_multiplier
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_speed /= speed_multiplier


func _unhandled_input(event: InputEvent) -> void:
	# Capture mouse motion only when the debug camera is active
	if visible and event is InputEventMouseMotion:
		_mouse_motion = event.relative


func _process(delta: float) -> void:
	if not visible:
		return
	
	# Handle keyboard movement
	var movement := Vector3.ZERO
	movement += Vector3.FORWARD if Input.is_key_pressed(KEY_W) else Vector3.ZERO
	movement += Vector3.LEFT if Input.is_key_pressed(KEY_A) else Vector3.ZERO
	movement += Vector3.BACK if Input.is_key_pressed(KEY_S) else Vector3.ZERO
	movement += Vector3.RIGHT if Input.is_key_pressed(KEY_D) else Vector3.ZERO
	movement += Vector3.DOWN if Input.is_key_pressed(KEY_Q) else Vector3.ZERO
	movement += Vector3.UP if Input.is_key_pressed(KEY_E) else Vector3.ZERO
	
	# Apply rotation based on mouse movement
	if _mouse_motion != Vector2.ZERO:
		var rotation_input = - _mouse_motion.x * mouse_sensitivity
		var tilt_input = - _mouse_motion.y * mouse_sensitivity
		
		var euler_rotation = camera.global_transform.basis.get_euler()
		euler_rotation.x += tilt_input
		euler_rotation.x = clamp(euler_rotation.x, -PI / 2 + 0.01, PI / 2 - 0.01) # Limit vertical rotation
		euler_rotation.y += rotation_input
		camera.global_transform.basis = Basis.from_euler(euler_rotation)
		
		# Reset mouse motion for next frame
		_mouse_motion = Vector2.ZERO
	
	# Apply movement
	camera.global_position += camera.global_transform.basis * movement * delta * camera_speed


func _toggle_camera_mode() -> void:
	print("Toggling camera mode. Current speed: ", camera_speed)
	if visible:
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_cached_camera.current = true
		camera.queue_free()
		hide()
		
		for node in get_tree().get_nodes_in_group("camera_mode_toggle"):
			node.show()
	else:
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_cached_camera = get_viewport().get_camera_3d()
		camera = Camera3D.new()
		add_child(camera)
		camera.current = true
		show()
		camera.fov = _cached_camera.fov
		camera.global_transform = _cached_camera.global_transform
		
		for node in get_tree().get_nodes_in_group("camera_mode_toggle"):
			node.hide()
