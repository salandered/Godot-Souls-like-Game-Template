class_name PlayerController extends CharacterBody3D

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

@export_range(0, 20.0, 0.1) var lerp_power := 1.0
@export var movementBlendPath: String;
@export var animationTree: AnimationTree;

@export var stopping_speed := 1.0

## Player model rotation speed
@export var rotation_speed := 12.0


@onready var state_machine: LimboHSM = $LimboHSM
# region: SM assumptions
# 1. State knows or may be not
# endregion

@onready var idle_state: LimboState = $LimboHSM/IdleState
@onready var move_state: LimboState = $LimboHSM/MoveState
@onready var jump_state: LimboState = $LimboHSM/JumpState
@onready var fall_state: LimboState = $LimboHSM/FallState
# @onready var attack_state: LimboState = $LimboHSM/AttackState


@onready var _last_strong_direction := Vector3.FORWARD


var speed_modifier := 1.0



func _ready() -> void:
	init_state_machine()
	# in limbo ai: 
	# death.connect(func(): remove_from_group(&"player"))

func init_state_machine():
	# IDLE
	state_machine.add_transition(idle_state, move_state, idle_state.INPUT_MOVED)
	# state_machine.add_transition(idle_state, attack_state, idle_state.INPUT_ATTACK)
	# do we need this?
	state_machine.add_transition(idle_state, fall_state, idle_state.STARTED_FALL)
	# idle - jump?
	# MOVE
	state_machine.add_transition(move_state, idle_state, move_state.WENT_IDLE)
	state_machine.add_transition(move_state, jump_state, move_state.INPUT_JUMPED)
	state_machine.add_transition(move_state, fall_state, move_state.STARTED_FALL)
	# state_machine.add_transition(move_state, attack_state, move_state.INPUT_ATTACK)
	# JUMP
	state_machine.add_transition(jump_state, move_state, jump_state.GOT_ON_FLOOR)
	state_machine.add_transition(jump_state, fall_state, jump_state.STARTED_FALL)
	# jump - idle?
	# FALL
	state_machine.add_transition(fall_state, move_state, fall_state.GOT_ON_FLOOR)


	state_machine.initial_state = idle_state
	state_machine.initialize(self)
	state_machine.set_active(true)
	

func input_move_direction() -> Vector3:
	# bool 
	#region CONVERTING 2D -> 3D
	# 1. 
	# 2. rotates the input direction to be relative to the camera's look direction
	# > camera's a child of player => its rotation is relative to the player's rotation
	# > but global_rotation is independent of the player rotation
	# => uses global_rotation to rotate input direction (so works regardless of players's initial rotation)
	# > In 2D, rotation is positive clockwise (oh)
	# > In 3D, rotation is positive counter-clockwise
	# => also negate the camera's rotation
	# 3. converts input vector to 3D. We use the x value for left and right movement, and the y value for forward and backward movement (mapped to the 3D vector's z component)
	#endregion
	var raw_input_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_direction_2d := raw_input_2d.rotated(-1.0 * _camera.global_rotation.y)
	var move_direction := Vector3(move_direction_2d.x, 0.0, move_direction_2d.y)

	return move_direction

func input_move_coming() -> bool:
	var dir = input_move_direction()
	return dir.length() > 0.1 # TODO: check
	

func _physics_process(delta: float) -> void:
	# var is_falling = not is_on_floor() and velocity.y < 0
	
	# CAMERA
	var move_direction: Vector3 = input_move_direction()
	if input_move_coming():
		_last_strong_direction = move_direction.normalized()
	# To not orient quickly to the last input, we save a last strong direction,
	# this also ensures a good normalized value for the rotation basis
	_orient_character_to_direction(_last_strong_direction, delta)
	
	# TODO: debug mode
	if input_move_coming():
		accelerate(move_direction, delta)


	#region: 10 just_landed_logic
	# var was_in_air := not is_on_floor() # was_in_air and just_landed works together
	# var fall_speed := absf(velocity.y)
	
	# move_and_slide()
	
	# var just_landed := was_in_air and is_on_floor()
	

	
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
	#endregion
	
	# That's how the blackboard works. Relevant parts of the game can fill it with data, and the AI can access it without having to know where the data comes from.
	#AI.BlackboardPlayer.player_global_position = global_position

func _orient_character_to_direction(direction: Vector3, delta: float) -> void:
	var left_axis := Vector3.UP.cross(direction)
	var rotation_basis := Basis(left_axis, Vector3.UP, direction).get_rotation_quaternion()
	var model_scale := _rotation_root.transform.basis.get_scale()
	var _what = _rotation_root.transform.basis.get_rotation_quaternion()
	var _the = _what.slerp(rotation_basis, delta * rotation_speed)
	_rotation_root.transform.basis = Basis(_the).scaled(model_scale)
	# move_and_slide()


func _orient_character_to_direction_all__(delta: float) -> void:
	if input_move_coming():
		var move_direction: Vector3 = input_move_direction()
		_last_strong_direction = move_direction.normalized()

	_orient_character_to_direction(_last_strong_direction, delta)
	# move_and_slide()


func accelerate(move_direction: Vector3, _delta: float):
	var player := self
	var max_speed = player.max_speed_jog
	var acceleration = player.acceleration_jog
	if Input.is_action_pressed("sprint"):
		max_speed = player.max_speed_sprint
		acceleration = player.acceleration_sprint
	
	# ground means no Y. 2D vector could be used but Vector3 is clearer.
	var velocity_ground_plane := Vector3(player.velocity.x, 0.0, player.velocity.z)
	var velocity_change = acceleration * _delta
	# move_toward() smoothly interpolates ground velocity to max speed
	# (and ensures vector cannot get longer than max_speed)

	# TODO: speed_modifier shouldnt be here
	velocity_ground_plane = velocity_ground_plane.move_toward(
		move_direction * max_speed,
		velocity_change
	) * speed_modifier

	player.velocity.x = velocity_ground_plane.x
	player.velocity.z = velocity_ground_plane.z
	
	player.velocity.x = velocity_ground_plane.x
	player.velocity.z = velocity_ground_plane.z


func stop_movement(start_duration: float, end_duration: float):
	var tween = create_tween()
	tween.tween_property(self, "speed_modifier", 0.2, start_duration)
	tween.tween_property(self, "speed_modifier", 1.0, end_duration)
