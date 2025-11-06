extends BaseCharacter
class_name Princess

@export var model: PlayerModel
@export var visuals: PlayerVisuals
@export var collider: CollisionShape3D
@onready var camera_focus: Node3D = %CameraFocus
@onready var fancy_camera: FancyCamera = %FancyCamera
@onready var player_movement: PlayerMovement = %PlayerMovement

@onready var dev_labels: Node = %_dev_labels

@onready var smith_sword: SmithSword = %SmithSword


func _ready() -> void:
	collision_layer = Collision.Layers.PLAYER_COL
	collision_mask = Collision.Mask.PLAYER_COL_MASK

	visuals.accept_model_data(model)

	model.active_weapon = smith_sword

	__dev_initialise()


## not nullable in theory
func get_current_state() -> BasePlayerState:
	return model.player_sm.current_state


func apply_hit(hit_data: HitData) -> void:
	model.combat.apply_hit(hit_data)


func react_on_hit(hit_data: HitData) -> void:
	var _curr_state = get_current_state()
	if not _curr_state:
		print_.warn(false, "no _curr_state", "player's react_on_hit", "no hit applied, it's lost", hit_data)
		return
	get_current_state().react_on_hit(hit_data)


# TODO: _process or _physics_process? changed to _process: frame issues
func _process(delta) -> void:
	# CONTROLLER (INPUT)
	var input_ := InputManager.get_current_input()
	
	# MODEL (SIMULATION)
	model.update(input_, delta)
	
	
	# VISUALISE (PRESENTATION)
	# Visuals -> follow parent transformations

	# seems like every frame is ok. may be try to make it once per N frames for safety
	basis = basis.orthonormalized()
	

## USED FOR ENEMY PROJECTS
# region

func hp_percentage() -> float:
	return model.feelings.get_curr_health() / model.feelings.get_max_health()


## returns -1.0 or default in case of problems
func current_attack_radius(default_return: float = -1.0) -> float:
	if not is_attacking():
		return default_return
	var curr_action = _get_curr_action_with_warn("current_attack_radius")
	if not curr_action:
		return default_return
	if not curr_action is BaseAttackAction:
		return default_return
	return curr_action.attack_radius


func current_state_initial_position() -> Vector3:
	var curr_state = _get_curr_state_with_warn("current_state_initial_position")
	if not curr_state:
		return Vector3.ZERO
	return curr_state.initial_position


## means in attack state (don't confuse with weapon's 'is_attacking')
func is_attacking() -> bool:
	var curr_state = _get_curr_state_with_warn("is_attacking")
	var curr_action = _get_curr_action_with_warn("is_attacking")
	if curr_state == null or curr_action == null:
		return false
	var _state_is_att: bool = curr_state is AttackState
	var _action_is_att: bool = curr_action is BaseAttackAction
	if _state_is_att != _action_is_att:
		print_.warn(false, "no sync between currState/currAct being attacking", "is_attacking", "return true", _state_is_att, _action_is_att)
	return _state_is_att or _action_is_att


func is_dodging() -> bool:
	var curr_state = _get_curr_state_with_warn("is_dodging")
	if not curr_state:
		return false
	return curr_state.state_name == PS.dodge


func _get_curr_state_with_warn(caller_log: String = "") -> BasePlayerState:
	if not get_current_state():
		print_.warn(false, "get_current_state() is null", caller_log, "return null")
		return null
	return get_current_state()


func _get_curr_action_with_warn(caller_log: String = "", ) -> BaseAction:
	var action = model.player_sm.get_curr_action()
	if not action:
		print_.warn(false, "model.player_sm.get_curr_action() is null", caller_log, "return null")
		return null
	return action

# endregion

# region: DEV

var debug_cams: Array[Node]
var cam_i := 0
var __collisions_enabled: bool = true

func __dev_initialise():
	debug_cams = get_tree().get_nodes_in_group(Groups.Dev.DEBUG_CAMERAS)
	print_.dev("dbg", str(debug_cams))
	debug_cams.append(fancy_camera.camera)
	cam_i = len(debug_cams) - 1
	print_.dev("dbg", "cam_i: " + str(cam_i))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dev_cycle_cam"):
		cam_i = (cam_i + 1) % debug_cams.size()
		print_.dev("dbg", "cam_i: " + str(cam_i))
		if debug_cams[cam_i].has_method("make_current"):
			debug_cams[cam_i].make_current()

	elif event.is_action_pressed("dev_cycle_cam_prev"):
		cam_i = (cam_i - 1 + debug_cams.size()) % debug_cams.size()
		print_.dev("dbg", "cam_i: " + str(cam_i))
		if debug_cams[cam_i].has_method("make_current"):
			debug_cams[cam_i].make_current()

	if event.is_action_pressed("debug_unstuck"):
		global_position.y += 1.5
		print_.dev("dbg", "Unstuck: moved player up by 1.5 units")

	if event.is_action_pressed("dev_cols"):
		__collisions_enabled = not __collisions_enabled
		if __collisions_enabled:
			collision_mask = Collision.Mask.PLAYER_COL_MASK
		else:
			collision_mask = Collision.Mask._DEV_ZERO_MASK

# endregion
