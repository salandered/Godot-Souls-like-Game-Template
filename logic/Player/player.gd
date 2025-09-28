extends CharacterBody3D
class_name Princess

@export var input_gatherer: InputGatherer
@export var model: PlayerModel
@export var visuals: PlayerVisuals
@export var collider: CollisionShape3D
@onready var camera_focus: Node3D = %CameraFocus
@onready var fancy_camera: FancyCamera = %FancyCamera

@onready var dev_labels: Node = %_dev_labels

@onready var right_player_weapon: RightPlayerWeapon = $Weapons/RightPlayerWeapon

var current_state: PlayerState

var jump_data: UsualJumpData


var debug_cams: Array[Node]
var cam_i := 0
var __collisions_enabled: bool = true

func _ready() -> void:
	collision_layer = Collision.Layers.PLAYER_COL
	collision_mask = Collision.Mask.PLAYER_COL_MASK

	jump_data = UsualJumpData.new()

	#print_.print_ready(self)
	visuals.accept_model_data(model)

	debug_cams = get_tree().get_nodes_in_group("debug_cameras")
	print_.prefix("dbg", str(debug_cams))
	debug_cams.append(fancy_camera.camera)
	cam_i = len(debug_cams) - 1
	print_.prefix("dbg", "cam_i: " + str(cam_i))
	
	right_player_weapon.accept_data(self)
	model.active_weapon = right_player_weapon.specific_weapon

# func _process(_delta) -> void:
# 	dev_labels._label_player_info()


# TODO: _process or _physics_process? changed to _process for now
func _process(delta) -> void:
	# CONTROLLER (INPUT)
	var input := input_gatherer.gather_input(delta)
	
	# MODEL (SIMULATION)
	model.update(input, delta)
	
	
	# VISUALISE (PRESENTATION)
	# Visuals -> follow parent transformations
	
	#input.queue_free() ep 4


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dev_cycle_cam"):
		cam_i = (cam_i + 1) % debug_cams.size()
		print_.prefix("dbg", "cam_i: " + str(cam_i))
		if debug_cams[cam_i].has_method("make_current"):
			debug_cams[cam_i].make_current()

	elif event.is_action_pressed("dev_cycle_cam_prev"):
		cam_i = (cam_i - 1 + debug_cams.size()) % debug_cams.size()
		print_.prefix("dbg", "cam_i: " + str(cam_i))
		if debug_cams[cam_i].has_method("make_current"):
			debug_cams[cam_i].make_current()

	if event.is_action_pressed("debug_unstuck"):
		global_position.y += 1.5
		print_.prefix("dbg", "Unstuck: moved player up by 1.5 units")


	if event.is_action_pressed("dev_cols"):
		__collisions_enabled = not __collisions_enabled
		if __collisions_enabled:
			collision_mask = Collision.Mask.PLAYER_COL_MASK
		else:
			collision_mask = Collision.Mask._DEV_ZERO_MASK
		

# ONLY GETTERS FOR OPPONENT PROJECT
func hp_percentage() -> float:
	return model.resources.health / model.resources.max_health

func is_attacking() -> bool:
	return false
	# return current_state is AttackState

func current_attack_radius() -> float:
	if not is_attacking():
		return 0
	return current_state.attack_radius

func current_attack_locked_time_left() -> float:
	if not is_attacking():
		return 0
	return current_state.time_til_priority_release()

func current_state_initial_position() -> Vector3:
	return current_state.initial_position

func current_state_posttracking_radius() -> float:
	return current_state.posttracking_radius

func time_til_attack_connection() -> float:
	if not is_attacking():
		return 99999
	return current_state.extremum_timing - current_state.get_progress()

func is_rolling() -> bool:
	return current_state.state_name == "roll"

func roll_time_left() -> float:
	if is_rolling():
		return current_state.DURATION - current_state.get_progress()
	return 0

func get_roll_endpoint() -> Vector3:
	if is_rolling():
		return current_state.endpoint
	return Vector3(1000, 1000, 1000)

func get_current_state_position_after(time: float) -> Vector3:
	var data_track = current_state.backend_animation
	var future = current_state.get_progress() + time
	# you can check out the original method usage, it is used to "go back in time"
	# but technically nothing stops us from predicting future with it as well

	# TODO: turned off while get_root_delta_pos is being transformated
	# var predicted_delta_pos = states_data.get_root_delta_pos(data_track, future, time)
	# return global_position + get_quaternion() * predicted_delta_pos
	return Vector3.UP

# TODO: return only name
func get_current_state() -> PlayerState:
	return current_state
