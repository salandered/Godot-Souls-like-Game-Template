@tool
@icon("res://-assets-/x_icons/char/image (18).png")
class_name MechFighter
extends BaseStaticCharacter


@export var _player: Princess


@onready var h_arm_weapon: FighterHArmWeapon = %HArmWeapon
@onready var __native_player: AnimationPlayer = %AnimationPlayer

@onready var lever_rot_asp: AudioStreamPlayer3D = %LeverRotASP
@onready var hit_back_asp: AudioStreamPlayer3D = %HitBackASP
@onready var stone_push_asp: AudioStreamPlayer3D = %StonePushASP
@onready var move_asp: AudioStreamPlayer3D = %Move
@onready var h_move_asp: AudioStreamPlayer3D = %HMove

@onready var interact_area: InteractArea = %InteractArea
@onready var coll_collider: CollisionShape3D = $CollCollider


@export var container: MechFighterStatesContainer


var camera_target: EnemyCameraTarget


var _curr_state: BaseMechFighterState
var _prev_state: BaseMechFighterState


var queued_state: MetaState.Queued = MetaState.Queued.new()

enum VArmPos {
	LEFT,
	RIGHT
}

var varm_position := VArmPos.LEFT


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		h_arm_weapon,
		interact_area,
	]

func __soft_dependencies() -> Array:
	return super.__soft_dependencies() + [
		move_asp,
		h_move_asp,
		lever_rot_asp,
		hit_back_asp,
		stone_push_asp,
	]


func initialise_static_char_implementation() -> void:
	add_to_group(Groups.Chars.SIMPLE_ENEMY)
	char_type = DVS.CharacterType.SIMPLE_ENEMY

	collision_layer = Collision.Layers.OTHER_CHAR_COL
	collision_mask = Collision.Masks.OTHER_CHAR_COL_MASK
	camera_target = CamTargetUtils.initialise_cam_target(self )
	if not error_.null_object(coll_collider, "no coll_collider"):
		var original_shape := coll_collider.shape
		if not error_.null_object(original_shape, "Coll collder CollisionShape3D has no shape"):
			if original_shape is not CapsuleShape3D:
				__log_warn("shape is not CapsuleShape3D. Not supported")
			else:
				# Duplicate to avoid shared resource issues
				coll_collider.shape = original_shape.duplicate()

	if not __perform_validation(true):
		__log_warn_soft("won't be working")
		return
	

	container.accept_states(MechFighterNodeStateContainer.new(), _anim_container, self )
	var _idle_state := container.get_state_by_name(MFS.idle)
	
	_curr_state = _idle_state
	_prev_state = _idle_state

	interact_area.SIG_interacted.connect(_on_my_area_interacted)


func _for_init_native_player() -> AnimationPlayer:
	return __native_player
func _for_init_active_weapon_id_list() -> Array[String]:
	return [WeaponID.fighter_h_arm, WeaponID.fighter_v_arm]
func _for_init_anim_list() -> BaseCharAnimList:
	return MFA.new()
func _for_init_required_markers() -> Dictionary[String, Array]:
	return {}


##

func _check_transition(delta: float) -> BaseVerdict:
	var _curr_state_name := _safe_curr_state_name()
	if _curr_state_name == "":
		# should not happen, but if happended, mimick idle for next decision
		_curr_state_name = MFS.idle
	var _next_state := ""
	var _reason := ""
	
	match _curr_state_name:
		MFS.idle:
			if queued_state.is_set():
				_next_state = queued_state.get_state_name()
				queued_state.reset(__QUEUED_B)
				_reason = "queued state"
			else:
				__log_("_check_transition", "nothing to do, go _set_sleep")
				_set_sleep(true)
		_:
			if _curr_state.is_ended():
				if queued_state.is_set():
					_next_state = queued_state.get_state_name()
					queued_state.reset(__QUEUED_B)
					_reason = "queued state"
				else:
					_next_state = MFS.idle
					_reason = "non idle state ended"

	return BaseVerdict.new(_next_state, _reason)


func _process(delta: float) -> void:
	if u.is_editor(): return

	var verdict := _check_transition(delta)


	if verdict.next_state != "":
		__log_("Chose state", verdict.next_state, "Reason:", verdict.get_reason())
		_switch_state(verdict.next_state)

	if _curr_state:
		_curr_state._update(delta)
		

func _set_sleep(value: bool):
	__log_("_set_sleep 😴", value)
	set_process(not value)


func _switch_state(next_state_id: String) -> void:
	if next_state_id == _safe_curr_state_name():
		__log_("↪️", "attempt to switch to the same state ", pp.in_q(_safe_curr_state_name()))
		return

	__log_("↪️", pp.in_q(_curr_state.state_name if _curr_state else "-x-"), "=>", pp.in_q(next_state_id))
	
	_curr_state._on_exit_state()
	_update_curr_state(next_state_id)
	# now current_state is next state
	_curr_state._on_enter_state()


func _update_curr_state(next_state_id: String):
	var _next_state := container.get_state_by_name(next_state_id)
	if not _next_state:
		__log_error(pp.s("no _next_state got using id", next_state_id), "_update_curr_state", "curr state won't change")
		return
	_prev_state = _curr_state
	_curr_state = _next_state
	SigUtils.safe_emit_raw(
		GlobalSignal.SIG_enemy_state_changed,
		{SPS.state_name_field: _curr_state.state_name}
	)


##

func get_current_state() -> BaseCharacterState:
	return _curr_state

func get_prev_state_name() -> String:
	return _safe_prev_state_name()


func _safe_prev_state_name() -> String:
	if not _prev_state:
		__log_warn_soft("no prev state")
	return _prev_state.state_name if _prev_state else ""


func _safe_curr_state_name() -> String:
	if not _curr_state:
		__log_warn_soft("no curr state")
	return _curr_state.state_name if _curr_state else ""


func react_on_hit(hit_data: HitData) -> void:
	__log_("react_on_hit")
	ReactionOnHit.calculate_reaction_for_enemy(hit_data, _safe_curr_state_name())
	# ReactionOnHit.calculate_reaction_for_enemy_state(hit_data)
	_queue_next_state()


func is_invincible() -> bool:
	return true


var attack_chain: Dictionary[String, String] = {
	## idle to default
	MFS.idle: MFS.attack_lr,
	## attacks
	MFS.attack_lr: MFS.attack_rl,
	MFS.attack_rl: MFS.attack_stab,
	MFS.attack_stab: MFS.attack_up,
	MFS.attack_up: MFS.attack_down,
	MFS.attack_down: MFS.attack_stab_power,
	MFS.attack_stab_power: MFS.attack_lr_power,
	MFS.attack_lr_power: MFS.attack_rl_power,
	MFS.attack_rl_power: MFS.attack_lr,
}


func _queue_next_state():
	var state_to_queue = ""
	
	if _safe_curr_state_name() != MFS.idle:
		# __log_("in idle state, won't queue")
		# return
		state_to_queue = DictUtils.safe_get_dict_key(attack_chain, _safe_curr_state_name(), MFS.attack_lr)
	else:
		state_to_queue = DictUtils.safe_get_dict_key(attack_chain, _safe_prev_state_name(), MFS.attack_lr)

	_set_sleep(false)
	
	queued_state.try_set(state_to_queue, 0, false, __QUEUED_B)

##


func _on_my_area_interacted():
	__log_("_on_my_area_interacted")
	_queue_next_state()


##

func get_run_state_names() -> Array[String]:
	return []

func get_dodge_state_names() -> Array[String]:
	return []

func get_sprint_state_names() -> Array[String]:
	return []

func get_idle_state_names() -> Array[String]:
	return []

func get_power_attacks_state_names() -> Array[String]:
	return []
#


##

func is_player() -> bool:
	return false

func get_player() -> Princess:
	return _player

## __LOGS

var __QUEUED_B: bool = false


func __LOG_B() -> bool:
	return false
