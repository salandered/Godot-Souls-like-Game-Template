extends Node3DLogger

## Autoload ##

@export var camera_speed := 10.0
@export var mouse_sensitivity := 0.003
@export var speed_multiplier := 1.1 # how much each scroll step multiplies speed

@onready var camera: FreeCamera = %Camera3D
@onready var light: SpotLight3D = %SpotLight3D
@onready var _cached_camera: Camera3D
@onready var _enabled := false

var _previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE


var ACTIVE: bool = false


## NOTE: deliberately using raw buttons, not RawAction (except for toggling)


func _ready() -> void:
	if OS.is_debug_build():
		_enabled = true

	if not camera:
		__log_warn_soft("Free camera is no available, no cam node found")
		_enabled = false

	set_process(_enabled)
	set_process_input(_enabled)
	set_process_unhandled_input(_enabled)

	hide()
	_cycle_labels_visible(true) # iterate to first element
	_set_labels_visible([false, false]) # not visible untill becomes active
	light.visible = false # by default false
	controls.text = controls_text


func _process(delta: float) -> void:
	if not ACTIVE:
		return
	
	move_camera(delta)

	_update_hud()


func _toggle_camera_mode() -> void:
	__log_("~~~ Toggling camera mode")
	
	## going back to main cam
	if ACTIVE:
		# get_tree().paused = false
		Input.mouse_mode = _previous_mouse_mode
		_turn_off_free_cam()
		_cached_camera.current = true
		hide()
		set_process(false)
		_set_labels_visible([false, false])
		ACTIVE = false
		InputManager.set_process(true)

	## turn on free cam
	else:
		# get_tree().paused = true
		_previous_mouse_mode = Input.mouse_mode
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_cached_camera = get_viewport().get_camera_3d()
		_turn_on_free_cam()
		show()
		set_process(true)
		_cycle_labels_visible(false)
		ACTIVE = true
		InputManager.set_process(false)


func _turn_on_free_cam():
	camera.current = true
	camera.fov = _cached_camera.fov
	camera.global_transform = _cached_camera.global_transform
	_create_camera_body()


func _turn_off_free_cam():
	camera.current = false
	_remove_camera_body() # important: remove it completely


## CAMERA MOVEMENT
# region

var _mouse_motion := Vector2.ZERO

func move_camera(delta: float):
	var movement := _get_keyboard_movement_vector()
	
	# rotation based on mouse movement
	if _mouse_motion != Vector2.ZERO:
		var rotation_input := -_mouse_motion.x * mouse_sensitivity
		var tilt_input := -_mouse_motion.y * mouse_sensitivity
		
		var euler_rotation := camera.global_transform.basis.get_euler()
		euler_rotation.x += tilt_input
		# limit vertical rotation
		euler_rotation.x = clamp(euler_rotation.x, -PI / 2 + 0.01, PI / 2 - 0.01)
		euler_rotation.y += rotation_input
		camera.global_transform.basis = Basis.from_euler(euler_rotation)
		
		# Reset mouse motion for next frame
		_mouse_motion = Vector2.ZERO
	
	# movement
	camera.global_position += camera.global_transform.basis * movement * delta * _get_current_movement_speed()


func _get_keyboard_movement_vector() -> Vector3:
	var movement := Vector3.ZERO
	movement += Vector3.FORWARD if Input.is_key_pressed(KEY_W) else Vector3.ZERO
	movement += Vector3.LEFT if Input.is_key_pressed(KEY_A) else Vector3.ZERO
	movement += Vector3.BACK if Input.is_key_pressed(KEY_S) else Vector3.ZERO
	movement += Vector3.RIGHT if Input.is_key_pressed(KEY_D) else Vector3.ZERO
	movement += Vector3.DOWN if Input.is_key_pressed(KEY_Q) else Vector3.ZERO
	movement += Vector3.UP if Input.is_key_pressed(KEY_E) else Vector3.ZERO
	return movement


func _get_current_movement_speed() -> float:
	var current_speed := camera_speed
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed *= 2.0 # sprint multiplier
	return current_speed

# endregion


## CAMERA BODY
# region

var _camera_body: PhysicsBody3D

func _create_camera_body() -> void:
	if _camera_body:
		__log_("_create_camera_body", "already created")
		return
	
	var body = FreeCameraBody.new()
	body.name = "DebugCamBody"
	
	body.collision_layer = Collision.Layers.PLAYER_COL
	
	body.collision_mask = 0 # camera not pushing things
	
	var shape_node = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.5
	shape_node.shape = sphere
	
	body.add_child(shape_node)
	camera.add_child(body)
	body.collision_layer = Collision.Layers.PLAYER_COL
	_camera_body = body


func _remove_camera_body() -> void:
	if _camera_body:
		camera.remove_child(_camera_body)
		_camera_body.queue_free()
		_camera_body = null

# endregion


## INFO LABELS
# region

@onready var controls_info: MarginContainer = %ControlsInfo
@onready var controls: RichTextLabel = %Controls
@onready var hud_info: MarginContainer = %HUDInfo
@onready var hud: RichTextLabel = %HUD

const controls_text := "[b]WASD[/b] - Move
[b]Q/E[/b] - Down/Up
[b]Shift[/b] - Speed boost
[b]L[/b] - Light on/off
[b]P[/b] - Unpause/pause scene
[b]Wheel up/down[/b] - Change speed
[b]Wheel up/down with RMB[/b] - Change FOV
[b]Wheel up/down with LMB[/b] - Change Light energy
"

var label_visibility_cycler = Cycler.new([
	[true, true],
	[false, true],
	[false, false],
	[true, false],
]
)

func _cycle_labels_visible(next: bool):
	if not label_visibility_cycler:
		return
	
	var value
	
	if next:
		value = label_visibility_cycler.get_next()
	else:
		value = label_visibility_cycler.get_current()

	_set_labels_visible(value)


func _set_labels_visible(value: Array):
	if not value or value is not Array or len(value) != 2:
		return

	if controls_info:
		controls_info.visible = value[0]
	if hud_info:
		hud_info.visible = value[1]


func _update_hud() -> void:
	if not hud or not hud.visible:
		return

	var pos := camera.global_position
	var rot := camera.rotation_degrees
	var status_text := "POS:  %.1f, %.1f, %.1f\nROT:  %.1f, %.1f\nSPD:  %.1f\nFOV:  %.0f" % [
		pos.x, pos.y, pos.z,
		rot.x, rot.y,
		camera_speed,
		camera.fov
	]

	if light:
		status_text += pp.s("\nLIGHT: ", light.visible, pp.s(" | ENERGY: ", light.light_energy))

	if get_tree().paused:
		status_text += "\n\n[SCENE PAUSED]"
	else:
		status_text += "\n\n[SCENE CONTINUES]"

	hud.text = status_text

# endregion


## INPUT
# region

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(RawAction.DEV_free_cam):
		_toggle_camera_mode()

	if ACTIVE:
		_handle_pause_toggle(event)
		_handle_mouse_wheel(event)
		_handle_fov_input(event)
		_handle_label_visibility(event)
		_handle_light_toggle(event)
		_handle_light_energy_input(event)


func _unhandled_input(event: InputEvent) -> void:
	# capture mouse motion only when the debug camera is active
	if not ACTIVE:
		return
 
	if event is InputEventMouseMotion:
		_mouse_motion = event.relative


func _handle_pause_toggle(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		get_tree().paused = not get_tree().paused


func _handle_mouse_wheel(event: InputEvent) -> void:
	# Don't change speed if we are changing FOV (RMB is held)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return

	# mouse wheel for speed adjustment
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_speed *= speed_multiplier
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_speed /= speed_multiplier


func _handle_fov_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	# Hold Right Mouse Button + Scroll to change FOV
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.fov = max(camera.fov - 2, 10)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.fov = min(camera.fov + 2, 170)

func _handle_light_energy_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	# Hold LMB + Scroll to change FOV
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			light.light_energy = max(light.light_energy - 0.2, 0.2)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			light.light_energy = min(light.light_energy + 0.2, 10.0)


func _handle_label_visibility(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_KP_0:
		_cycle_labels_visible(true)


func _handle_light_toggle(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_L:
		light.visible = not light.visible


# endregion


## __LOGS
# region

func pp_name():
	return "~~~FreeCam" + em.pin

# endregion
