@abstract
class_name BaseAction
extends PlActionTimeManagement


var container: PlayerStatesContainer
var feelings: PlayerFeelings

var player_sm: PlayerSM
var combat: PlayerCombat
var anim_params_container: PlAnimParamsContainer

var action_name: StringName

## auto used for all actions
var blend_time := ActionData.BlendTime.new(0.2)
var start_time_offset := ActionData.StartTimeOffset.new(0.0)

## manually used by RM actions 
var extra_root_speed_Z := ActionData.ExtraRootSpeedZ.new(0.0)
var extra_root_speed_fade_time := ActionData.ExtraRootSpeedFadeTime.new(0.4)

# 
var default_sp: DefaultSpeedConfig = DefaultSpeedConfig.new()
var motion_type: StringName ## see MotionType


## assigned while updating current global action as the VERY FIRST operation of the action.
## excessive, but provides an extra gurantee that prev action would not change throughout 
## the current action (self) life cycle.
## => strongly recommended to use this instead of alternative ways like player_sm.get_prev_action
var PREV_ACTION: StringName = Const.EMPTY_SNAME


func get_animator_manager() -> PlAnimatorManager:
	return animator_manager


func get_player() -> Princess:
	return player_sm.get_player()
	

func pm() -> PlayerMovement:
	return player_sm.player_movement


# region: INTERFACE 

## if action needs something special to work. Would be called from states container.
## Reason: We rarely can rely on _ready
@abstract func initialise() -> void


func call_accumulate_time_spent(delta: float) -> void:
	accumulate_time_spent(delta)


func _update(input_: InputPackage, delta: float):
	call_accumulate_time_spent(delta)
	update(input_, delta)


@abstract func update(input_: InputPackage, delta: float)


func _on_enter_action(input_: InputPackage) -> void:
	mark_enter_state() # NOTE: used word 'state', its ok
	PREV_ACTION = player_sm.update_current_action(self ) # NOTE: very first line of curr action
	if self is LegsAction:
		player_sm.legs_sm.set_current_action(self ) # very second line
	elif self is PlayerAction:
		player_sm.current_state.curr_state_action = self
	

	on_enter_action(input_)
	animate()


## to override
func on_enter_action(input_: InputPackage) -> void:
	pass


func _on_exit_action() -> void:
	# TODO DANGER: while testing splitted SM, this may work after next action processed _on_enter_action 
	#    this is really bad but almost anything could be set up _on_enter_action and then its ok.
	on_exit_action()


## to override
func on_exit_action() -> void:
	pass


## default implementation. Called automatically.
## Example use cases to override: mute playing animation or overriden values for set_anim_to_play
## NOTE: called AFTER the on_enter_action()
## TODO: DANGER: If an action mutes playing anim (not calling set_anim_to_play), 
## 		TM like time_spent() would stuck and return final values from the previous actions.
## 		Such animations should work with functions like get_real_time_spent or not work with the TM at all.
func animate(): # ▶️
	set_anim_to_play()


func set_anim_to_play(override_blend_time: float = -1.0, override_start_time_offset: float = -1.0) -> void:
	var _actual_blend_time := blend_time.calculate_actual(PREV_ACTION)
	if override_blend_time != -1.0:
		_actual_blend_time = override_blend_time
	var _actual_start_time_offset := start_time_offset.calculate_actual(PREV_ACTION)
	if override_start_time_offset != -1.0:
		_actual_start_time_offset = override_start_time_offset
		
	__log_anim(_actual_blend_time, _actual_start_time_offset)
	get_animator_manager().set_anim_to_play(anim.anim_id, _actual_blend_time, _actual_start_time_offset)
	# _actual_blend_time = default_blend_time
	# _actual_start_time_offset = default_start_time_offset


func set_overlay_anim_to_play(overlay_anim_id: StringName, overlay_config: OverlayConfig) -> void:
	__log_overlay_anim(overlay_anim_id, overlay_config)
	get_animator_manager().set_overlay_anim(overlay_anim_id, overlay_config)


# endregion


# region: REACT


func _react_on_hit(hit: HitData):
	__log_upd("react_on_hit called")
	if not is_invincible():
		feelings.lose_health(hit.damage)
	
	var react_cfg := ReactionOnHit.calculate_reaction_for_pl_action(hit, action_name)
	if not react_cfg:
		__log_upd("state mutes react_on_hit, ignoring")
		return
	else:
		__log_upd("Calculated react_cfg", react_cfg)
	
	var actual_overlay_weight := react_cfg.overlay_weight
	var actual_bone_mask := react_cfg.bone_mask
	actual_overlay_weight /= 2.0 if self is BaseAttackAction else 1.0

	var overlay_config := OverlayConfig.new(
		OverlayConfig.Weight.new(actual_overlay_weight, actual_overlay_weight / 2),
		BlendConfig.new(),
		1.0,
		actual_bone_mask)

	set_overlay_anim_to_play(react_cfg.anim_id, overlay_config)

	react_on_hit(hit)


## may be overriden in actions
func react_on_hit(hit: HitData):
	pass

# endregion


# todo: we can auto calculate this using MotionType
const IDLE_LIKE_ACTIONS = [
	Leg.Act.idle,
	PS.Act.axe_slice_1,
	PS.Act.axe_slice_2,
	PS.Act.axe_slice_3,
	PS.Act.sword_slash_1,
	PS.Act.sword_slash_2,
	PS.Act.sword_slash_3,
	PS.Act.stab_attack_1,
	PS.Act.stab_attack_2,
	# PS.Act.dodge,
	PS.Act.pushback,
	PS.Act.thrown,
]

const LOOP_LIKE_ACTIONS = [
	Leg.Act.run,
	Leg.Act.sprint,
	Leg.Act.strafe,
	PS.Act.midair,
]


# region: SPECIFIC TIME MANAGEMENT (TM)

## Like time_remaining(), but takes into account the blend time of the next state.
## It would be needed for a smooth switch.
## NOTE: makes no sense for looping animations => unsupported
## NOTE: less important after modifier started to support multiple blends
## WARNING: does not account for speed scaling
## TODO: oh, can be done with usual functions 
func time_remaining_for_smooth_switch(next_action_name: StringName) -> float:
	if anim.is_looping:
		__log_warn("Will return big meaningless number: time_remaining_for_smooth_switch does not support looping anims. " + anim.anim_name)
		return Const.BIG_MEANINGLESS_NUMBER
	var action := container.l_action_by_name(next_action_name)
	var _blend_time: float = action.blend_time.calculate_actual(action_name)
	return max(time_remaining() - _blend_time, 0.0)


## Time remaining till a moment, when current animation would be blended 100%. 
## This is important for the next switch considerations: if A action wants to switch the current B anim, 
## but B is still blending from the previous C animation, there would be a noticable visual snap. 
## Reason: C to B blend would be interrupted by B to A.
## Note: using actual blend duration from manager is better than rely on current action's data or desires.
func till_blend_completes() -> float:
	return max(get_animator_manager().get_curr_blend_duration() - time_spent(), 0.0)

# endregion


# region: GET ANIMATION PARAMETERS

func switches_to_queue() -> bool:
	return anim_params_container.is_switches_to_queue(anim.native_anim, effective_time_spent())

func allows_queue() -> bool:
	return anim_params_container.is_allows_queue(anim.native_anim, effective_time_spent())

func is_invincible() -> bool:
	## use container only in several states.
	## good optimisation, but akward implementation
	var _r: bool = false
	if player_sm.current_state and player_sm.current_state.state_name in PlayerConfig.invincible_states:
		_r = anim_params_container.is_invincible(anim.native_anim, effective_time_spent())
		# prints("anim_params_container~~~~~", _r)

	# prints("~~~~~", _r)
	return _r


func is_weapon_hurts(weapon_id: StringName, __log: bool = false) -> bool:
	var _r: bool = false
	if weapon_id in combat.get_active_weapon_ids():
		_r = anim_params_container.is_weapon_hurts(weapon_id, anim.native_anim, effective_time_spent())
	else:
		__log_error("unknown weapon name " + pp.in_q(weapon_id), "is_weapon_hurts", "return false", WL.WARN_CRUCIAL)
	if _r and __log:
		print_.msg_raw("// HURT")
	return _r


func tracks_input_vector() -> bool:
	return anim_params_container.is_tracks_input_vector(anim.native_anim, effective_time_spent())

# endregion


# region: HELPERS

## if no _speed_extra_X specified, will be 0.0 (ignored)
func calculate_extra_root_speed(_speed_extra_Z: float, _speed_extra_X: float = 0.0) -> Vector3:
	var _start_time_offset := start_time_offset.calculate_actual(PREV_ACTION)
	var _final_extra_speed_Z := pm().calculate_extra_root_speed_Z(anim, _start_time_offset, _speed_extra_Z, false)
	var _final_extra_speed_X := _speed_extra_X
	var result := Vector3(_final_extra_speed_X, 0, _final_extra_speed_Z)

	__log_ent("extra root speed Z/X", _final_extra_speed_Z, _final_extra_speed_X)
	return result

# endregion


## __LOGS

var __LOG_OVERLAY_ANIM: bool = true


@abstract func __log_function(prefix: String, ...parts: Array) -> void


func __log_ent(...parts: Array):
	__log_function(action_name + pp.on_ent, pp.list_(parts))

func __log_ext(...parts: Array):
	__log_function(action_name + pp.on_ext, pp.list_(parts))

func __log_upd(...parts: Array):
	__log_function(action_name + pp.on_upd, pp.list_(parts))

func __log_action(...parts: Array):
	__log_function(action_name, pp.list_(parts))


func __log_anim(_actual_blend_time: float, _actual_start_time_offset: float):
	print_preset.any_action_anim(action_name, anim.anim_name, _actual_blend_time, _actual_start_time_offset, PREV_ACTION)

func __log_overlay_anim(overlay_anim_id: StringName, overlay_config: OverlayConfig):
	if __LOG_OVERLAY_ANIM: print_preset.phe_overlay_anim(action_name, overlay_anim_id, overlay_config)
