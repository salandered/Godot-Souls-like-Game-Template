extends BaseCharacter
class_name Princess


# camera
@onready var fancy_camera: FancyCamera = %FancyCamera
@onready var camera_focus: Node3D = %CameraFocus

#
@onready var visuals: PlayerVisuals = %Visuals
@onready var skeleton: Skeleton3D = %GeneralSkeleton
@onready var container: PlayerStatesContainer = %StatesContainer
@onready var bones: PlayerBones = %bones

# essential systems
@onready var player_movement: PlayerMovement = %PlayerMovement
@onready var combat: PlayerCombat = $Combat
@onready var feelings: PlayerFeelings = %Feelings
@onready var area_awareness: AreaAwareness = %AreaAwareness
@onready var player_sm: PlayerSM = %PlayerSM

# anim
@onready var anim_container: AnimationContainer = %AnimContainer
@onready var animator_manager: PlAnimatorManager = %AnimatorManager
@onready var native_player: AnimationPlayer = %NativeAnimator

# 
@onready var hit_box_torso: CharacterHitbox = %HitBoxTorso


# dev
@onready var __fly_mode: Node3D = $__dev/FlyMode
@onready var __dev_labels: Node = %_dev_labels


@onready var _start_position := global_transform.origin
var push_rigid_bodies_force = 4.0


func initialise() -> void:
	collision_layer = Collision.Layers.PLAYER_COL
	collision_mask = Collision.Masks.PLAYER_COL_MASK

	visuals.accept_model_data(self)
	

	var _pl_anim_container := PlAnimList.new()
	# NOTE: should be before accepting states!
	anim_container._accept_animations(
		_pl_anim_container.list_of_animations,
		native_player,
		AnimParamsContainer.TRACK_PREFIXES,
		AnimParamsContainer.get_all_params(),
		PlRequiredMarkers.anim_to_required_marker)
		 
	container.accept_all_states(self)
	player_sm.initialise(self)

	bones.accept_bones()
	combat.initialise()
	animator_manager.initialise()

	__dev_initialise()


func pretty_name() -> String:
	return "Player"

## not nullable in theory
func get_current_state() -> BasePlayerState:
	return player_sm.current_state


func react_on_hit(hit_data: HitData) -> void:
	player_sm.react_on_hit(hit_data)


func reset_position() -> void:
	transform.origin = _start_position


# TODO: _process or _physics_process? changed to _process: frame issues
func _process(delta) -> void:
	var input_ := InputManager.get_current_input()
	update(input_, delta)
	# seems like every frame is ok. may be try to make it once per N frames for safety
	basis = basis.orthonormalized()
	

func update(input_: InputPackage, delta: float):
	if __fly_mode.fly_mode_enabled:
		return

	player_sm.update(input_, delta)
	move_and_slide()
	PushRigidBodies.push_rigid_bodies(self, push_rigid_bodies_force)




## USED FOR ENEMY PROJECTS
# region

func hp_percentage() -> float:
	return feelings.get_curr_health() / feelings.get_max_health()


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
	var action = player_sm.get_curr_action()
	if not action:
		print_.warn(false, "player_sm.get_curr_action() is null", caller_log, "return null")
		return null
	return action

# endregion


# region: __LOGS

func __log_warn(crucial: bool, what: String, where: String, fallback: String, ...details: Array):
	print_.warn(crucial, what, where + "| player model", fallback, pp.list_(details))


# endregion


# region: DEV

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(RawAction.DEV_H):
		var hit = HitData.new(10, "from god", PHEA.attack.scare_off)
		combat._last_processed_hit = hit
		self.react_on_hit(hit)
	if Input.is_action_just_pressed(RawAction.DEV_J):
		var hit = HitData.new(30, "from god", PHEA.attack.sword_slide)
		combat._last_processed_hit = hit
		self.react_on_hit(hit)
	if Input.is_action_just_pressed(RawAction.DEV_K):
		var hit = HitData.new(10, "from god", PHEA.attack.attack_360_low)
		combat._last_processed_hit = hit
		self.react_on_hit(hit)
	if Input.is_action_just_pressed(RawAction.DEV_L):
		var hit = HitData.new(30, "from god", PHEA.attack.power_gap_closer)
		combat._last_processed_hit = hit
		self.react_on_hit(hit)

	if event.is_action_released(RawAction.t8):
		visuals.visible = not visuals.visible
	
	if event.is_action_pressed(RawAction.DEV_8):
		animator_manager.set_overlay_anim(A.react.react_from_L,
		OverlayConfig.new(
			OverlayConfig.Weight.new(0.8, 0.4),
			BlendConfig.new(),
			1.0,
			BoneMask.get_upper_body_with_hips()
			))
	if event.is_action_pressed(RawAction.DEV_9):
		animator_manager.set_overlay_anim(A.react.react_from_R,
				OverlayConfig.new(
			OverlayConfig.Weight.new(1.0, 0.4),
			BlendConfig.new(),
			1.0,
			BoneMask.get_upper_body_with_hips()
		))


var debug_cams: Array[Node]
var csg_visible_initially: Array
var csg_non_visible_initially: Array
var csg_visible_cycle: Cycler

var cam_i := 0
var __collisions_enabled: bool = true

func __dev_initialise():
	debug_cams = get_tree().get_nodes_in_group(Groups.Dev.DEBUG_CAMERAS)
	# print_.dev("dbg", str(debug_cams))
	debug_cams.append(fancy_camera.camera)
	cam_i = len(debug_cams) - 1
	# print_.dev("dbg", "cam_i: " + str(cam_i))
	var _csg_visuals = get_descendants.csg_primitives(self)
	for _csg: CSGPrimitive3D in _csg_visuals:
		if _csg.visible:
			csg_visible_initially.append(_csg)
		else:
			csg_non_visible_initially.append(_csg)

	csg_visible_cycle = Cycler.new([[false, false], [true, false], [true, true], [false, true]])


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(RawAction.DEV_CAM_cycle):
		cam_i = (cam_i + 1) % debug_cams.size()
		print_.dev("dbg", "cam_i: " + str(cam_i))
		if debug_cams[cam_i].has_method("make_current"):
			debug_cams[cam_i].make_current()

	elif event.is_action_pressed(RawAction.DEV_CAM_cycle_prev):
		cam_i = (cam_i - 1 + debug_cams.size()) % debug_cams.size()
		print_.dev("dbg", "cam_i: " + str(cam_i))
		if debug_cams[cam_i].has_method("make_current"):
			debug_cams[cam_i].make_current()

	if event.is_action_pressed(RawAction.DEV_unstuck):
		global_position.y += 1.5
		print_.dev("dbg", "Unstuck: moved player up by 1.5 units")

	if event.is_action_pressed(RawAction.DEV_cols):
		__collisions_enabled = not __collisions_enabled
		if __collisions_enabled:
			collision_mask = Collision.Masks.PLAYER_COL_MASK
		else:
			collision_mask = Collision.Masks._ZERO_MASK

	if event.is_action_pressed(RawAction.DEV_O):
		var _next_booleans = csg_visible_cycle.get_next()
		for csg in csg_visible_initially:
			csg.visible = _next_booleans[0]
		for csg in csg_non_visible_initially:
			csg.visible = _next_booleans[1]


# endregion
