extends CharacterBody3D


@export var input_gatherer: InputGatherer
@export var model: PlayerModel
@export var visuals: PlayerVisuals
@export var camera_mount: Node3D
@export var collider: CollisionShape3D
@onready var camera_focus: Node3D = %CameraFocus
@onready var fancy_camera: FancyCamera = %FancyCamera

@onready var label: Label = $debug_labels/Label
@onready var label_2: Label = $debug_labels/Label2
@onready var label_3: Label = $debug_labels/Label3

var debug_cams: Array[Node]
var cam_i := 0


func _ready():
	#Print.print_ready(self)
	visuals.accept_model(model)

	debug_cams = get_tree().get_nodes_in_group("debug_cameras")
	Print.print_debug_(debug_cams)
	debug_cams.append(fancy_camera.camera)
	cam_i = len(debug_cams) - 1
	Print.print_debug_("cam_i: " + str(cam_i))

func _process(_delta):
	_update_debug_interface()


func _update_debug_interface():
		var p_pos = model.global_position
		var nest_pos := fancy_camera.nest.global_position
		var camera_pos := fancy_camera.camera.global_position
		
		
		label.text = "player to nest " + "%10.3f" % p_pos.distance_to(nest_pos)
		label_2.text = "player to cam " + "%10.3f" % p_pos.distance_to(camera_pos)

		var free_offset = fancy_camera.free_camera.offset.length() if fancy_camera.free_camera.offset else 0.0
		var locked_offset := fancy_camera.locked_camera.offset.length() if fancy_camera.locked_camera.offset else 0.0
		label_3.text = "offset " + "%10.3f" % free_offset
		label_3.text += "%10.3f" % locked_offset


func _physics_process(delta):
	# CONTROLLER (INPUT)
	var input := input_gatherer.gather_input()
	
	# MODEL (SIMULATION)
	model.update(input, delta)
	
	
	# VISUALISE (PRESENTATION)
	# Visuals -> follow parent transformations
	
	#input.queue_free() ep 4


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_cycle_cam"):
		cam_i = (cam_i + 1) % debug_cams.size()
		Print.print_debug_("cam_i: " + str(cam_i))
		if debug_cams[cam_i].has_method("make_current"):
			debug_cams[cam_i].make_current()


# the section below contains some getters utilised by enemies to
# analyze battle situation, currently it's used in Opponent project
# if you only read this file to look at player's controller code, skip freely
func hp_percentage() -> float:
	return model.resources.health / model.resources.max_health

func is_attacking() -> bool:
	return model.current_state is AttackState

func current_attack_radius() -> float:
	if not is_attacking():
		return 0
	return model.current_state.attack_radius

func current_attack_locked_time_left() -> float:
	if not is_attacking():
		return 0
	return model.current_state.time_til_priority_release()

func current_state_initial_position() -> Vector3:
	return model.current_state.initial_position

func current_state_posttracking_radius() -> float:
	return model.current_state.posttracking_radius

func time_til_attack_connection() -> float:
	if not is_attacking():
		return 99999
	return model.current_state.extremum_timing - model.current_state.get_progress()

func is_rolling() -> bool:
	return model.current_state.state_name == "roll"

func roll_time_left() -> float:
	if is_rolling():
		return model.current_state.DURATION - model.current_state.get_progress()
	return 0

func get_roll_endpoint() -> Vector3:
	if is_rolling():
		return model.current_state.endpoint
	return Vector3(1000, 1000, 1000)

func get_current_state_position_after(time: float) -> Vector3:
	var states_data = model.current_state.states_data_repo as StatesDataRepository
	var data_track = model.current_state.backend_animation
	var future = model.current_state.get_progress() + time
	# you can check out the original method usage, it is used to "go back in time"
	# but technically nothing stops us from predicting future with it as well
	var predicted_delta_pos = states_data.get_root_delta_pos(data_track, future, time)
	return global_position + get_quaternion() * predicted_delta_pos

func is_locked_in_animation() -> bool:
	return not model.current_state.tracks_input_vector()

func time_til_next_last_locked_frame() -> float:
	if not is_locked_in_animation():
		return 0
	return model.current_state.time_til_unlocking()

# pandora's box potentialy, better return immutable snapshot copy or use getters for fields,
# otherwise some out-of-palyer functional can mess with controller's flow
# but who cares
func get_current_state() -> BasePlayerState:
	return model.current_state


# works but stuns the game, need some other approach(
#func get_guaranteed_positions_list() -> Array[Array]:
	#var positions_list = model.current_state.get_guaranteed_positions_list()
	#print(model.current_state.state_name + str(positions_list))
	#return positions_list
