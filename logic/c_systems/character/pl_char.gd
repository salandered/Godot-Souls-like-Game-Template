@tool
@icon("res://-assets-/x_icons/char/image (15).png")
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

@onready var feelings: PlayerFeelings = %Feelings
@onready var player_sm: PlayerSM = %PlayerSM
@onready var pl_anim_sfx_sig_emitter: PlayerAnimSFXSignalEmitter = %PlayerAnimSFXSigEmitter
@onready var smith_sword_anim_sfx_sig_emitter: PlayerAnimSFXSignalEmitter = %SmithSwordAnimSFXSigEmitter
@onready var small_pinga_anim_sfx_sig_emitter: PlayerAnimSFXSignalEmitter = %SmallPingaAnimSFXSigEmitter

@onready var native_player: AnimationPlayer = %NativeAnimator

# 
@onready var hit_box_torso: CharacterHitbox = %HitBoxTorso

@onready var _start_position := global_transform.origin
@onready var meta_sfxasp: AudioStreamPlayer = %MetaSFXASP

# dev
@onready var __fly_mode: Node3D = $__dev/FlyMode


var push_rigid_bodies_force: float = 4.0


var active_weapon_id := WeaponID.smith_sword
# var active_weapon_id := WeaponID.pl_pinga_blade


var acquired_second_weapon: bool = true ## DANGER DEV


signal SIG_stamina_cant_be_paid
signal SIG_switch_weapon_cant_be_done
var stamina_cant_be_paid := SignalData.new("SIG_stamina_cant_be_paid", SIG_stamina_cant_be_paid)
var switch_weapon_cant_be_done := SignalData.new("SIG_switch_weapon_cant_be_done", SIG_switch_weapon_cant_be_done)


func get_pl_movement() -> PlayerMovement:
	var casted: PlayerMovement = get_movement()
	return casted


func get_area_awareness() -> PlayerAreaAwareness:
	var casted: PlayerAreaAwareness = super.get_area_awareness()
	return casted


func get_animator_manager() -> PlAnimatorManager:
	var casted: PlAnimatorManager = super.get_animator_manager()
	return casted


func __hard_dependencies() -> Array:
	var ds := super.__hard_dependencies()
	ds.append_array([
		fancy_camera,
		camera_focus,
		skeleton,
	])
	return ds


## for Princess all the soft are kind of hard
func __soft_dependencies() -> Array:
	return [
		get_sfx_system(),
		pl_anim_sfx_sig_emitter,
		smith_sword_anim_sfx_sig_emitter,
		small_pinga_anim_sfx_sig_emitter,
		hit_box_torso,
		__fly_mode,
	]


func initialise_base_char_implementation() -> void:
	char_type = DVS.CharacterType.PLAYER
	add_to_group(Groups.Chars.PLAYER)

	collision_layer = Collision.Layers.PLAYER_COL
	collision_mask = Collision.Masks.PLAYER_COL_MASK
	
	_initialise_look_at_systems()

	if _anim_container:
		container.accept_all_states(self , _anim_container)
	if get_combat():
		player_sm.initialise(self )

	__dev_initialise()


	if not __perform_validation(true):
		__log_warn_soft("well game is not ready")


func _initialise_look_at_systems():
	_look_at_manager = ArrayUtils.get_only_one_or_null(get_descendants.pl_look_at_manager(self ))
	if _look_at_manager:
		_look_at_manager.initialise(null, get_look_at_char_marker())


## FOR INIT 
# region 

## cont
func _for_init_sig_container() -> BaseCharacterSignalContainer:
	return PlayerSignalContainer.new()
func _for_init_sad_container() -> BaseCharacterSADContainer:
	return PlayerSADContainer.new()
func _for_init_anim_list() -> BaseCharAnimList:
	return PlAnimList.new()
func _for_init_required_markers() -> Dictionary[String, Array]:
	return PlRequiredMarkers.anim_to_required_marker
## anim
func _for_init_native_player() -> AnimationPlayer:
	return native_player
##
func _for_init_visuals() -> BaseVisuals:
	return visuals
func _for_init_bones() -> BaseCharBones:
	return bones
func _for_init_active_weapon_id_list() -> Array[String]:
	return [WeaponID.smith_sword]
## sfx
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

##


## BASIC GETTERS

func is_player() -> bool:
	return true

func get_player() -> Princess:
	return self

## not nullable in theory
func get_current_state() -> BasePlayerState:
	return player_sm.current_state

func get_curr_state_name() -> String:
	return player_sm.current_state.state_name if player_sm.current_state else ""

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


func is_invincible() -> bool:
	return player_sm.is_invincible()


func reset_position(y_offset: float = 0.0) -> void:
	transform.origin = _start_position
	transform.origin.y += y_offset


# TODO: _process or _physics_process? changed to _process: frame issues
# TODO UPD: should be _physics_process if move_and_slide is called.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var input_ := InputManager.get_current_input()
	update(input_, delta)
	
	if u.is_nth_frame(10):
		basis = basis.orthonormalized()
	

func update(input_: InputPackage, delta: float):
	if __fly_mode.fly_mode_enabled:
		return

	player_sm.update(input_, delta)
	move_and_slide()
	PushRigidBodies.push_rigid_bodies_by_char(self , push_rigid_bodies_force)


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
	var curr_action := player_sm.get_curr_action()
	if not curr_action:
		return default_return
	if not curr_action is BaseAttackAction:
		return default_return
	return curr_action.attack_radius


func current_state_initial_position() -> Vector3:
	if not get_current_state():
		return Vector3.ZERO
	return get_current_state().initial_position


func is_in_attack_state() -> bool:
	return player_sm.current_state is AttackState


# endregion


## INPUT


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(RawAction.Unstuck):
		global_position.y += 1.2
		print_.dev("dbg", "Unstuck: moved player up by 1.2 units")
		InputUtils.mark_input_handled(self )

	_dev_input(event)


# region: DEV


var debug_cams: Array[Node]

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


func _dev_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
		
	if InputUtils.is_keycode_w_ctrl(event, KEY_J):
		var hit := HitData.new(25, "from god", PHEA.attack.sword_slide, 1.0, "test attack", AttackDirection.Dir.LEFT)
		get_combat()._last_processed_hit = hit
		self.react_on_hit(hit)
	if InputUtils.is_keycode_w_ctrl(event, KEY_K):
		var hit := HitData.new(24, "from god", PHEA.attack.attack_360_low, 1.0, "test attack", AttackDirection.Dir.RIGHT)
		get_combat()._last_processed_hit = hit
		self.react_on_hit(hit)
	if InputUtils.is_keycode_w_ctrl(event, KEY_L):
		var hit := HitData.new(24, "from god", PHEA.attack.attack_up, 1.0, "test attack", AttackDirection.Dir.UP)
		get_combat()._last_processed_hit = hit
		self.react_on_hit(hit)

	# if event.is_action_pressed(RawAction.DEV_8):
	# 	animator_manager.set_overlay_anim(A.react.react_from_L,
	# 	OverlayConfig.new(
	# 		OverlayConfig.Weight.new(0.8, 0.4),
	# 		BlendConfig.new(),
	# 		1.0,
	# 		BoneMask.get_upper_body_with_hips()
	# 		))
	
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

# endregion
