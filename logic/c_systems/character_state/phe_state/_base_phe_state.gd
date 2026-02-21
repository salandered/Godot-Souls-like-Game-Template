@abstract
class_name BasePHEState
extends BaseCharacterState


var me: PHCharacter
var container: PHEContainer
var anim_container: BaseAnimContainer
var phe_feelings: PHEFeelings
var combat: PHECombat
var animator_manager: EnemyAnimatorManager
var e_movement: EnemyMovement
var anim_params_container: BaseAnimParamsContainer
var config: PHEConfig


## -1 for leafs
var state_depth: int


# min time to stay in state. -1 means not applied (like for Top state or some idle state)
var commitment: float = 0.4
# max time to stay in state -1 means not applied (like for Top state or some idle state)
var fatigue: float = 20


## MAIN INTERFACE
# region

@abstract func validate_substate_depth(parent_depth: int) -> bool


## if state needs something special to work. Would be called from states container.
func _initialise() -> void:
	initialise()


func initialise() -> void:
	pass


func get_animator_manager() -> EnemyAnimatorManager:
	return animator_manager


## internal
@abstract func _on_enter_state()

## internal
@abstract func _on_exit_state()


## to override
func on_exit_state() -> void:
	pass


## to override
func on_enter_state() -> void:
	pass


## for the top state this is called from model
@abstract func _update(delta: float)


@abstract func works_longer_than_fatigue() -> bool

@abstract func works_less_than_commitment() -> bool


## To override
func update(delta: float) -> void:
	pass


## Any state can signal to its parent that it's ended.
## Parent state decides on what to do with this information freely (including ignoring it).
## But NOTE: 
##   - strongly recommended to use this mechanics if substate describes finite action like attack or jump.
##   - in case of any uncertainty return 'true'. 
@abstract func is_ended() -> bool


func get_player() -> Princess:
	return me.player

# endregion


@abstract func time_spent() -> float


@abstract func works_longer_than(time: float) -> bool


@abstract func works_less_than(time: float) -> bool


@abstract func react_on_hit(hit_data: HitData) -> void


@abstract func is_apply_gravity() -> bool


@abstract func get_current_substate_by_depth(depth: int) -> BasePHEState


## MOVEMENT SHORTCUTS
# region

func distance_to_player() -> float:
	return e_movement.distance_to_player()

func dist_to_player_less(number: float) -> bool:
	return e_movement.square_distance_to_player() <= MathUtil.fpow2(number)

func dist_to_player_greater(number: float) -> bool:
	return e_movement.square_distance_to_player() >= MathUtil.fpow2(number)

func distance_to_(target: Node3D) -> float:
	return e_movement.distance_to_(target)

func abs_angle_to_player() -> float:
	return e_movement.abs_angle_to_player()

func signed_angle_to_player() -> float:
	return e_movement.signed_angle_to_player()

func direction_to_(target: Variant) -> Vector3:
	return e_movement.direction_to_(target)

# endregion

## COMMON HELPERS
# region

func _auto_update_monitors(__monitors: Array[PHEHelpers.MonitorFor], delta: float, curr_sbs_name: StringName, next_sbs_name: StringName, __log_context: String = ""):
	# NOTE: out states tend to return empty string, meaning that no switch needed. Monitors are not ready for this
	if next_sbs_name == "":
		next_sbs_name = curr_sbs_name
	for monitor in __monitors:
		monitor.auto_update(delta, curr_sbs_name, next_sbs_name, -1, -1, __log_context)


func state_angry(state_usual: StringName, state_angry_: StringName) -> StringName:
	return state_usual if not me.angry_raised else state_angry_


func fvalue_angry(value_usual_: float, value_angry_: float) -> float:
	return value_usual_ if not me.angry_raised else value_angry_

func svalue_angry(value_usual_: String, value_angry_: String) -> String:
	return value_usual_ if not me.angry_raised else value_angry_

func chance_angry(chance_usual: float, chance_angry_: float) -> float:
	return ra.chance(fvalue_angry(chance_usual, chance_angry_))


## 50% chance or third if angry
func flip_w_angry(state_a: StringName, state_b: StringName, state_angry_: StringName) -> StringName:
	if me.angry_raised: return state_angry_
	return flip_state(state_a, state_b)


## 50% chance
func flip_state(state_a: StringName, state_b: StringName) -> StringName:
	return state_a if ra.coinflip() else state_b

## returns 'state_a' with chance 'chance' else 'state_b'
func flip_chance(chance: float, state_a: StringName, state_b: StringName) -> StringName:
	return state_a if ra.chance(chance) else state_b


# endregion


# region: __LOGS


var __LOG_EXIT: bool = false
var __LOG_ANIM: bool = false
var __LOG_OVERLAY_ANIM: bool = false

func __get_common_context() -> String:
	var _msg := ""
	_msg += pp.s("Pl->E", pp.round_01(distance_to_player()),
		"∠" + pp.rad2deg(signed_angle_to_player(), true))
	return _msg


func __ELA() -> bool:
	## "extra logs allowed"
	return LogToggler.PHE_INTERNAL_FILTER_B

@abstract func __log_state() -> String

@abstract func __log_indent() -> int

func __log_phe(...parts: Array):
	if __ELA():
		print_.phe_sm(__log_state(), pp.list_(parts), __log_indent())

func __log_phe_choose(chose_state_: String, ...parts: Array):
	if __ELA():
		print_.phe_check(__log_state(), "Chose " + chose_state_ + " " + pp.list_(parts), __log_indent())

func __log_phe_check(...parts: Array):
	if __ELA():
		print_.phe_check(__log_state(), pp.list_(parts), __log_indent())

func __log_phe_decision(...parts: Array):
	if __ELA():
		print_.phe_sm(__log_state() + em.verdict, pp.list_(parts), __log_indent())

func __log_ent(...parts: Array):
	if __ELA():
		print_.phe_sm(__log_state() + pp.on_ent, pp.list_(parts), __log_indent())

@abstract func __log_timings() -> String

func __log_ext(...parts: Array):
	if __ELA():
		if __LOG_EXIT: print_.phe_sm(pp.s(__log_state(), pp.on_ext, __log_timings()), pp.list_(parts), __log_indent())

func __log_phe__upd(...parts: Array):
	if __ELA():
		print_.phe_sm(__log_state() + pp.on_internal_upd, pp.list_(parts), __log_indent())

func __log_upd(...parts: Array):
	if __ELA():
		print_.phe_sm(__log_state() + pp.on_upd, pp.list_(parts), __log_indent())


## overrides built in log
func __log_warn(...parts: Array):
	error_.warn(pp.s(
		__log_state(),
		pp.list_(parts),
		"\n\t\t",
		me.__pp_state_history()),
		"",
		""
		)


func __log_warn_v2(what: String, where: String = "", fallback: String = "", ...parts: Array):
	var _parts := pp.list_(parts)
	error_.warn(what, where, fallback, WL.PUSH_ERROR, _parts, "\n\t\t", __log_state(), me.__pp_state_history())

func __log_forgot_implement(sbs_name: StringName, function_name: String, fallback: String, ...parts: Array):
	var _msg := "forgot to implement '%s' logic in '%s()'. Fallback: %s" % [sbs_name, function_name, fallback]
	__log_warn_soft(_msg)

# endregion
