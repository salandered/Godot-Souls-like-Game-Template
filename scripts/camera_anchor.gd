extends Node3D

@onready var _cam_anchor: Node3D = %CameraAnchor
@onready var _spring_arm: Node3D = %SpringArm3D
@export_range(0.001, 1.0) var mouse_sensitivity := 0.001


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	var is_mouse_input := event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	
	# region 10 mouse code
	#var is_mouse_captured := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	var is_mouse_button := event is InputEventMouseButton
	var is_escape_pressed := event.is_action_pressed("ui_cancel")

	#if is_mouse_button and not is_mouse_captured:
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#elif is_escape_pressed and is_mouse_captured:
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# endregion
	
	if event.is_action_pressed("wheel_up"):
		_spring_arm.spring_length -= 1
	if event.is_action_pressed("wheel_down"):
		_spring_arm.spring_length += 1
	
	if is_mouse_input:
		## gets mouse motion in the screen's coordinate system.
		# no multiplying by delta! mouse motion reported through input events is already frame-rate independent. 
		# events are sent over time by OS, independently of the engine's frame rate. 
		var look_offset_2d: Vector2 = event.screen_relative * mouse_sensitivity
		_rotate_camera_by(look_offset_2d)

## old X component of the mouse motion should control the camera's rotation around Y-axis
## old Y component of the mouse motion should control the camera's rotation around X-axis
## X controls orbit left/right; Y controls vertical angle (tilt)
func _rotate_camera_by(look_offset_2d: Vector2) -> void:
	#region some 10 code
	## look_offset_2d represents the mouse motion 
	#_camera.rotation.y -= look_offset_2d.x
	#_camera.rotation.x -= look_offset_2d.y
	## wrapf() keeps Y rotation between -PI and PI:
	## 	* when the rotation value > PI, it wraps around to -PI, and vice versa. 
	## 	* => allows player to make a full turn and prevents the angles from accumulating
	## large rotation values -> bugs when adding camera controls like focusing the view on a point of interest
	#_camera.rotation.y = wrapf(_camera.rotation.y, -PI, PI)
	#
	#const MAX_VERTICAL_ANGLE := PI / 3.0 # 60
	## clampf() function takes a float value and a lower and upper bound.
	## it limits rotation unlike the wrapf()
	#_camera.rotation.x = clampf(_camera.rotation.x, -1.0 * MAX_VERTICAL_ANGLE, MAX_VERTICAL_ANGLE)
	#
	#_camera.orthonormalize()
	#endregion

	## look_offset_2d represents the mouse motion 
	_cam_anchor.rotation.y -= look_offset_2d.x
	_cam_anchor.rotation.x -= look_offset_2d.y
	
	# Adjust horisontal rotation (mouse left or right)
	_cam_anchor.rotation.y = wrapf(_cam_anchor.rotation.y, -PI, PI)
	
	# Adjust vertical rotation (mouse up and down)
	const MAX_VERTICAL_ANGLE := PI / 3.0 # 60 degrees
	_cam_anchor.rotation.x = clampf(_cam_anchor.rotation.x, -MAX_VERTICAL_ANGLE, MAX_VERTICAL_ANGLE)
	
	#_camera.orthonormalize()
	_cam_anchor.orthonormalize()
	
