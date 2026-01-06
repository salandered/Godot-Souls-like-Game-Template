## i m not sure are we the princess or not, but the name stuck.
## sometimes when 'player' sounds too abstract 
## (is it main player? animation player? or audio stream player?)
## and 'main character' is too verbose, use 'princess'
class_name Princess
extends BaseCharacter


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
@onready var feelings: PlayerFeelings = %Feelings
@onready var area_awareness: AreaAwareness = %AreaAwareness
@onready var player_sm: PlayerSM = %PlayerSM
@onready var sfx_system: PlayerSFXSystem = %AudioSystem
@onready var pl_anim_sfx_sig_emitter: PlayerAnimSFXSignalEmitter = %PlayerAnimSFXSigEmitter
@onready var smith_sword_anim_sfx_sig_emitter: PlayerAnimSFXSignalEmitter = %SmithSwordAnimSFXSigEmitter
@onready var small_pinga_anim_sfx_sig_emitter: PlayerAnimSFXSignalEmitter = %SmallPingaAnimSFXSigEmitter

# anim
@onready var anim_container: AnimContainer = %AnimContainer
@onready var animator_manager: PlAnimatorManager = %AnimatorManager
@onready var native_player: AnimationPlayer = %NativeAnimator
@onready var anim_params_container: AnimParamsContainer = %AnimParamsContainer

# 
@onready var hit_box_torso: CharacterHitbox = %HitBoxTorso


# dev
@onready var __fly_mode: Node3D = $__dev/FlyMode
@onready var __dev_labels: Node = %_dev_labels


@onready var _start_position := global_transform.origin
var push_rigid_bodies_force: float = 4.0


var active_weapon_id := WeaponID.smith_sword
# var active_weapon_id := WeaponID.pl_pinga_blade

@onready var meta_sfxasp: AudioStreamPlayer = %MetaSFXASP


var acquired_second_weapon: bool = true ## DANGER DEV

signal SIG_stamina_cant_be_paid
signal SIG_switch_weapon_cant_be_done
var stamina_cant_be_paid := SignalData.new("SIG_stamina_cant_be_paid", SIG_stamina_cant_be_paid)
var switch_weapon_cant_be_done := SignalData.new("SIG_switch_weapon_cant_be_done", SIG_switch_weapon_cant_be_done)


func __hard_dependencies() -> Array[Object]:
	return [
		fancy_camera,
		camera_focus,
		visuals,
		skeleton,
		container,
		bones,
		player_movement,
		get_sig_container(),
		get_combat(),
		feelings,
		area_awareness,
		player_sm,
		anim_container,
		animator_manager,
		native_player,
	]

## for Princess all the soft are kind of hard, but ok
func __soft_dependencies() -> Array[Object]:
	SIG_stamina_cant_be_paid.get_object_id()
	return [
		sfx_system,
		pl_anim_sfx_sig_emitter,
		smith_sword_anim_sfx_sig_emitter,
		small_pinga_anim_sfx_sig_emitter,
		hit_box_torso,
		__fly_mode,
	]


func initialise() -> void:
	collision_layer = Collision.Layers.PLAYER_COL
	collision_mask = Collision.Masks.PLAYER_COL_MASK

	if anim_container:
		container.accept_all_states(self, anim_container)
	if get_combat():
		player_sm.initialise(self)

	__dev_initialise()

	
	if not __perform_validation():
		__log_warn_soft("well game is not ready")
		process_mode = PROCESS_MODE_DISABLED


## FOR INIT 
# region 

## cont
func _for_init_sig_container() -> BaseCharacterSignalContainer:
	return PlayerSignalContainer.new()
func _for_init_sad_container() -> BaseCharacterSADContainer:
	return PlayerSADContainer.new()
## anim cont
func _for_init_anim_container() -> AnimContainer:
	return anim_container
func _for_init_anim_params_container() -> BaseAnimParamsContainer:
	return anim_params_container
func _for_init_anim_list() -> BaseCharAnimList:
	return PlAnimList.new()
func _for_init_required_markers() -> Dictionary[String, Array]:
	return PlRequiredMarkers.anim_to_required_marker
## anim
func _for_init_native_player() -> AnimationPlayer:
	return native_player
func _for_init_anim_manager() -> BaseAnimatorManager:
	return animator_manager
##
func _for_init_visuals() -> BaseVisuals:
	return visuals
func _for_init_bones() -> BaseCharBones:
	return bones
func _for_init_movement() -> BaseCharacterMovement:
	return player_movement
func _for_init_active_weapon_id_list() -> Array[String]:
	return [WeaponID.smith_sword]
## sfx
func _for_init_sfx_system() -> CharacterSFXSystem:
	return sfx_system
func _for_init_asp_config_container() -> BaseCharacterASPConfigContainer:
	return PlayerASPConfigContainer.new()
func _for_init_anim_sfx_sig_emitter() -> BaseAnimSFXSignalEmitter:
	return pl_anim_sfx_sig_emitter
func _for_init_weapon_id_to_emitter() -> Dictionary[String, BaseAnimSFXSignalEmitter]:
	return {
		WeaponID.smith_sword: smith_sword_anim_sfx_sig_emitter,
		WeaponID.small_pinga_blade: small_pinga_anim_sfx_sig_emitter,
	}

# endregion 


## BASIC GETTERS

func is_player() -> bool:
	return true

func get_player() -> Princess:
	return self

## not nullable in theory
func get_current_state() -> BasePlayerState:
	return player_sm.current_state

func get_prev_state_name() -> String:
	return player_sm.prev_state_name

func get_curr_action_name() -> String:
	var action := player_sm.get_curr_action()
	if not action:
		return ""
	return action.action_name

##

func react_on_hit(hit_data: HitData) -> void:
	player_sm.react_on_hit(hit_data)


func reset_position() -> void:
	transform.origin = _start_position


# TODO: _process or _physics_process? changed to _process: frame issues
func _process(delta: float) -> void:
	var input_ := InputManager.get_current_input()
	update(input_, delta)
	
	if u.is_nth_frame(10):
		basis = basis.orthonormalized()
	

func update(input_: InputPackage, delta: float):
	if __fly_mode.fly_mode_enabled:
		return

	player_sm.update(input_, delta)
	move_and_slide()
	PushRigidBodies.push_rigid_bodies(self, push_rigid_bodies_force)


## USED FOR SFX SYSTEM
# region

func get_run_state_names() -> Array[String]:
	return [PS.run]

func get_dodge_state_names() -> Array[String]:
	return [PS.dodge]

func get_sprint_state_names() -> Array[String]:
	return [PS.sprint]

func get_idle_state_names() -> Array[String]:
	return [PS.idle]

func get_power_attacks_state_names() -> Array[String]:
	return [PS.sword_slash_3, PS.axe_slice_3]

# endregion


## USED FOR ENEMY PROJECTS
# region

func hp_percentage() -> float:
	return feelings.get_curr_health() / feelings.get_max_health()


## returns -1.0 or default in case of problems
func current_attack_radius(default_return: float = -1.0) -> float:
	if not is_in_attack_state():
		return default_return
	var curr_action := _get_curr_action_with_warn("current_attack_radius")
	if not curr_action:
		return default_return
	if not curr_action is BaseAttackAction:
		return default_return
	return curr_action.attack_radius


func current_state_initial_position() -> Vector3:
	var curr_state := _get_curr_state_with_warn("current_state_initial_position")
	if not curr_state:
		return Vector3.ZERO
	return curr_state.initial_position


func is_in_attack_state() -> bool:
	var curr_state := _get_curr_state_with_warn("is_attacking")
	var curr_action := _get_curr_action_with_warn("is_attacking")
	if curr_state == null or curr_action == null:
		return false
	var _state_is_att: bool = curr_state is AttackState
	var _action_is_att: bool = curr_action is BaseAttackAction
	if _state_is_att != _action_is_att:
		__log_warn("no sync between currState/currAct being attacking", "is_attacking", "return true", _state_is_att, _action_is_att)
	return _state_is_att or _action_is_att


func is_dodging() -> bool:
	var curr_state := _get_curr_state_with_warn("is_dodging")
	if not curr_state:
		return false
	return curr_state.state_name == PS.dodge


func _get_curr_state_with_warn(caller_log: String = "") -> BasePlayerState:
	if not get_current_state():
		__log_warn("get_current_state() is null", caller_log, "return null")
		return null
	return get_current_state()


func _get_curr_action_with_warn(caller_log: String = "", ) -> BaseAction:
	var action := player_sm.get_curr_action()
	if not action:
		__log_warn("player_sm.get_curr_action() is null", caller_log, "return null")
		return null
	return action

# endregion


# region: DEV


func _input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	# if Input.is_action_just_pressed(RawAction.DEV_K):
	# 	var hit := HitData.new(10, "from god", PHEA.attack.scare_off)
	# 	get_combat()._last_processed_hit = hit
	# 	self.react_on_hit(hit)
	if Input.is_action_just_pressed(RawAction.DEV_J):
		var hit := HitData.new(30, "from god", PHEA.attack.sword_slide)
		get_combat()._last_processed_hit = hit
		self.react_on_hit(hit)
	if Input.is_action_just_pressed(RawAction.DEV_K):
		var hit := HitData.new(10, "from god", PHEA.attack.attack_360_low)
		get_combat()._last_processed_hit = hit
		self.react_on_hit(hit)
	if Input.is_action_just_pressed(RawAction.DEV_L):
		var hit := HitData.new(30, "from god", PHEA.attack.power_gap_closer)
		get_combat()._last_processed_hit = hit
		self.react_on_hit(hit)

	if event.is_action_released(RawAction.t8):
		visuals.visible = not visuals.visible
	
	# if event.is_action_pressed(RawAction.DEV_8):
	# 	animator_manager.set_overlay_anim(A.react.react_from_L,
	# 	OverlayConfig.new(
	# 		OverlayConfig.Weight.new(0.8, 0.4),
	# 		BlendConfig.new(),
	# 		1.0,
	# 		BoneMask.get_upper_body_with_hips()
	# 		))
	# if event.is_action_pressed(RawAction.DEV_9):
	# 	animator_manager.set_overlay_anim(A.react.react_from_R,
	# 			OverlayConfig.new(
	# 		OverlayConfig.Weight.new(1.0, 0.4),
	# 		BlendConfig.new(),
	# 		1.0,
	# 		BoneMask.get_upper_body_with_hips()
	# 	))


var debug_cams: Array[Node]
var csg_visible_initially: Array
var csg_non_visible_initially: Array
var csg_visible_cycle: Cycler

var cam_i := 0
var __collisions_enabled: bool = true

func __dev_initialise():
	if not OS.is_debug_build():
		return
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
	if event.is_action_pressed(RawAction.Unstuck):
		global_position.y += 1.5
		print_.dev("dbg", "Unstuck: moved player up by 1.5 units")

	if not OS.is_debug_build():
		return

		
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

@onready var rig: RangerWrapper = %RIG

func _on_secret_enemy_sig_death_raised() -> void:
	if rig:
		rig.super_mats()
