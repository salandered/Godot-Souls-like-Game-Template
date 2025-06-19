class_name PlayerFPSController extends CharacterBody3D

@export_range(0.001, 1.0) var mouse_sensitivity := 0.001

@export_category("Ground movement")
@export_range(1.0, 50.0, 0.1) var max_speed_jog := 20.0
@export_range(1.0, 80.0, 0.1) var max_speed_sprint := 60.0
@export_range(1.0, 100.0, 0.1) var acceleration_jog := 60.0
@export_range(1.0, 100.0, 0.1) var acceleration_sprint := 100.0
@export_range(1.0, 100.0, 0.1) var deceleration := 70.0

@export_category("Air movement")
# gravity is 17 m/s² and max_fall is 20 =>
# * if player falls for one second -> fall speed will increase by 17 m/s.
# * player will reach max fall speed after ~ 1.18 seconds (20 m/s / 17 m/s²).
@export_range(1.0, 100.0, 0.1) var gravity := 60.0
@export_range(1.0, 100.0, 0.1) var max_fall_speed := 80.0
@export_range(1.0, 40.0, 0.1) var jump_velocity := 30.0

@onready var _camera: Camera3D = %Camera3D
@onready var _cam_anchor: Node3D = %CameraAnchor
@onready var _spring_arm: Node3D = %SpringArm3D
#@onready var _spring_position_what: Node3D = %SpringPosition
@onready var _cam_anchor_start_height: float = _cam_anchor.position.y

@onready var _hurt_box_3d: HurtBox3D = %HurtBox3D


@export_range(0, 20.0, 0.1) var lerp_power := 1.0

func _process(delta: float) -> void:
	#_camera.position = lerp(_camera.position, _spring_position_what.position, delta*lerp_power)
	pass

func _physics_process(delta: float) -> void:
	# 1. CONVERTING 2D -> 3D
	# 2. rotates the input direction to be relative to the camera's look direction
	# > camera's a child of player => its rotation is relative to the player's rotation
	# > but global_rotation is independent of the player rotation
	# => uses global_rotation to rotate input direction (so works regardless of players's initial rotation)
	# > In 2D, rotation is positive clockwise (oh)
	# > In 3D, rotation is positive counter-clockwise
	# => also negate the camera's rotation
	# 3. converts input vector to 3D. We use the x value for left and right movement, and the y value for forward and backward movement (mapped to the 3D vector's z component)
	var input_direction_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var movement_direction_2d := input_direction_2d.rotated(-1.0 * _camera.global_rotation.y)
	var movement_direction_3d := Vector3(movement_direction_2d.x, 0.0, movement_direction_2d.y)
	
	var player_wants_to_move := movement_direction_2d.length() > 0.1
	# ACCELERATION
	if player_wants_to_move:
		var max_speed := max_speed_jog
		var acceleration := acceleration_jog
		if Input.is_action_pressed("sprint"):
			max_speed = max_speed_sprint
			acceleration = acceleration_sprint
		
		# ground means no Y. 2D vector could be used but Vector3 is clearer.
		var velocity_ground_plane := Vector3(velocity.x, 0.0, velocity.z)
		var velocity_change := acceleration * delta
		# move_toward() smoothly interpolates ground velocity to max speed
		# (and ensures vector cannot get longer than max_speed)
		velocity_ground_plane = velocity_ground_plane.move_toward(
			movement_direction_3d * max_speed, 
			velocity_change
		)
		velocity.x = velocity_ground_plane.x
		velocity.z = velocity_ground_plane.z
		
		velocity.x = velocity_ground_plane.x
		velocity.z = velocity_ground_plane.z
	# DECELERATION
	else:
		var velocity_ground_plane := Vector3(velocity.x, 0.0, velocity.z)
		# moves towards zero
		velocity_ground_plane = velocity_ground_plane.move_toward(
			Vector3.ZERO,
			deceleration * delta
		)
		velocity.x = velocity_ground_plane.x
		velocity.z = velocity_ground_plane.z
	
	# If modify vertical vel. after move_and_slide() -> changes to falling or jumping speed 
	# will be delayed by one frame.
	if not is_on_floor():
		velocity.y -= gravity * delta
		velocity.y = maxf(velocity.y, -max_fall_speed)
	#if is_on_floor() and Input.is_action_just_pressed("jump"):
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	var was_in_air := not is_on_floor() # was_in_air and just_landed works together
	var fall_speed := absf(velocity.y)
	
	move_and_slide()
	
	var just_landed := was_in_air and is_on_floor()
	
	# That's how the blackboard works. Relevant parts of the game can fill it with data, and the AI can access it without having to know where the data comes from.
	AI.Blackboard.player_global_position = global_position
	
	#if just_landed:
		#var impact_intensity := fall_speed / max_fall_speed
		#
		## 1. new Tween object to animate position of Neck node, which directly affects the camera. 
		## 	* Tween.EASE_OUT => node moves faster at beginning of anim. and slower at end, reinforcing the impact.
		## 	* TRANS_QUAD: a quadratic easing curve (smooth and sharp)
		## 	* 0.06 is duration
		## 2. higher the intensity, further camera goes down (up to 0.2m).
		## 3. camera goes back up to its original position over 0.1 seconds.
		#var impact_tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		#impact_tween.tween_property(_cam_anchor, "position:y", _cam_anchor.position.y - 0.2 * impact_intensity, 0.06)
		#impact_tween.tween_property(_cam_anchor, "position:y", _cam_anchor_start_height, 0.1)


func _unhandled_input(event: InputEvent) -> void:
	var is_mouse_button := event is InputEventMouseButton
	var is_mouse_captured := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	var is_escape_pressed := event.is_action_pressed("ui_cancel")

	if is_mouse_button and not is_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif is_escape_pressed and is_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event.is_action_pressed("wheel_up"):
		_spring_arm.spring_length -= 1
	if event.is_action_pressed("wheel_down"):
		_spring_arm.spring_length += 1
	
	if (
		event is InputEventMouseMotion and
		Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	):
		## gets mouse motion in the screen's coordinate system.
		# no multiplying by delta! mouse motion reported through input events is already frame-rate independent. 
		# events are sent over time by OS, independently of the engine's frame rate. 
		var look_offset_2d: Vector2 = event.screen_relative * mouse_sensitivity
		_rotate_camera_by(look_offset_2d)

## old X component of the mouse motion should control the camera's rotation around Y-axis
## old Y component of the mouse motion should control the camera's rotation around X-axis
## X controls orbit left/right; Y controls vertical angle (tilt)
func _rotate_camera_by(look_offset_2d: Vector2) -> void:
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
	
