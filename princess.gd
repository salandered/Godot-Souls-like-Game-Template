class_name PlayerFPSController extends CharacterBody3D

@export_range(0.001, 1.0) var mouse_sensitivity := 0.001

@export_category("Ground movement")
@export_range(1.0, 50.0, 0.1) var max_speed_jog := 10.0
@export_range(1.0, 80.0, 0.1) var max_speed_sprint := 60.0
@export_range(1.0, 100.0, 0.1) var acceleration_jog := 40.0
@export_range(1.0, 100.0, 0.1) var acceleration_sprint := 100.0
@export_range(1.0, 100.0, 0.1) var deceleration := 70.0

@export_category("Air movement")
# gravity is 17 m/s² and max_fall is 20 =>
# * if player falls for one second -> fall speed will increase by 17 m/s.
# * player will reach max fall speed after ~ 1.18 seconds (20 m/s / 17 m/s²).
@export_range(1.0, 100.0, 0.1) var gravity := 60.0
@export_range(1.0, 100.0, 0.1) var max_fall_speed := 80.0
@export_range(1.0, 40.0, 0.1) var jump_velocity := 20.0

@onready var _camera: Camera3D = %Camera3D
@onready var _cam_anchor: Node3D = %CameraAnchor
@onready var _spring_arm: Node3D = %SpringArm3D
#@onready var _spring_position_what: Node3D = %SpringPosition
@onready var _cam_anchor_start_height: float = _cam_anchor.position.y
@onready var _rotation_root: Node3D = %RotationRoot
@onready var _hurt_box_3d: HurtBox3D = %HurtBox3D
@onready var _character_skin: GobotSkin3D = %PeaGirl4Anims

@export_range(0, 20.0, 0.1) var lerp_power := 1.0
@export var movementBlendPath: String;
@export var animationTree: AnimationTree;

@export var stopping_speed := 1.0

## Player model rotation speed
@export var rotation_speed := 12.0

@onready var _last_strong_direction := Vector3.FORWARD


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
func _process(delta: float) -> void:
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
	var raw_input_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_direction_2d := raw_input_2d.rotated(-1.0 * _camera.global_rotation.y)
	var move_direction := Vector3(move_direction_2d.x, 0.0, move_direction_2d.y)
	
	var player_wants_to_move := move_direction_2d.length() > 0.1 # move_direction ?
	
	# ORIENTATION
	if player_wants_to_move:
		# To not orient quickly to the last input, we save a last strong direction,
		# this also ensures a good normalized value for the rotation basis
		_last_strong_direction = move_direction.normalized()
	
	_orient_character_to_direction(_last_strong_direction, delta)
	
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
			move_direction * max_speed, 
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
	
		
	var is_just_jumping := Input.is_action_just_pressed("jump") and is_on_floor()
	
	# If modify vertical vel. after move_and_slide() -> changes to falling or jumping speed 
	# will be delayed by one frame.
	if not is_on_floor():
		velocity.y -= gravity * delta
		velocity.y = maxf(velocity.y, -max_fall_speed)
	#if is_on_floor() and Input.is_action_just_pressed("jump"):
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
	
	# ANIMATION
	var is_falling = not is_on_floor() and velocity.y < 0
	var xz_velocity := Vector3(velocity.x, 0, velocity.z)
	var is_moving = xz_velocity.length() > stopping_speed # adjusting stopping_speed?
	if is_just_jumping:
		_character_skin.jump()
	elif not is_on_floor() and velocity.y < 0:
		_character_skin.fall()
	elif is_on_floor():
		if is_moving:
			_character_skin.set_moving(true)
			_character_skin.set_moving_speed(inverse_lerp(0.0, max_speed_sprint/2, xz_velocity.length()))
		else: # idle
			_character_skin.set_moving(false)
	
	if Input.is_action_just_pressed("action"):
		_character_skin.attack(is_falling, is_moving, inverse_lerp(0.0, max_speed_sprint/2, xz_velocity.length()))
	
	var was_in_air := not is_on_floor() # was_in_air and just_landed works together
	var fall_speed := absf(velocity.y)
	
	move_and_slide()
	
	var just_landed := was_in_air and is_on_floor()
	
	# That's how the blackboard works. Relevant parts of the game can fill it with data, and the AI can access it without having to know where the data comes from.
	AI.BlackboardPlayer.player_global_position = global_position
	
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


func _orient_character_to_direction(direction: Vector3, delta: float) -> void:
	var left_axis := Vector3.UP.cross(direction)
	var rotation_basis := Basis(left_axis, Vector3.UP, direction).get_rotation_quaternion()
	var model_scale := _rotation_root.transform.basis.get_scale()
	_rotation_root.transform.basis = Basis(_rotation_root.transform.basis.get_rotation_quaternion().slerp(rotation_basis, delta * rotation_speed)).scaled(
		model_scale
	)
