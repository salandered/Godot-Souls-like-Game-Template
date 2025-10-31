@abstract
class_name BasePHEState
extends TimeManagement


var me: PHCharacter
var container: PHContainer
var anim_container: BaseAnimationContainer
var phe_feelings: PHEFeelings
var active_weapon: PHWeapon
var combat: PHCombat
var native_player: AnimationPlayer
var animator_manager: EnemyAnimatorManager
var e_movement: EnemyMovement


var state_name: String

# min time to stay in state. -1 means not applied (like for Top state or some idle state)
var commitment: float = 0.4
# max time to stay in state -1 means not applied (like for Top state or some idle state)
var fatigue: float = 20


## MAIN INTERFACE
# region

@abstract func validate_substate_depth(parent_depth: int) -> bool

## if state needs something special to work. Would be called from states container.
func initialise() -> void:
	pass

func get_animator_manager() -> EnemyAnimatorManager:
	return animator_manager


## internal
@abstract func _on_enter_state()

## internal
@abstract func _on_exit_state()


## to override
func on_exit_state():
	pass


## to override
func on_enter_state():
	pass


## for the top state this is called from model
@abstract func _update(delta: float)


@abstract func works_longer_than_fatigue() -> bool

@abstract func works_less_than_commitment() -> bool


## To override
func update(delta: float):
	pass


## any state can update the value returning from this function.
## example: attack state can signal that it ended using this.
## Using of this function is a decision of the parent state. It could ignore it.
func is_ended() -> bool:
	return false


func get_player() -> Princess:
	return me.player

# endregion


@abstract func works_longer_than(time: float) -> bool

@abstract func works_less_than(time: float) -> bool


## MOVEMENT SHORTCUTS
# region

func distance_to_player() -> float:
	return e_movement.distance_to_player()

func dist_to_player_less(number: float) -> bool:
	return e_movement.square_distance_to_player() <= u.fpow2(number)

func dist_to_player_greater(number: float) -> bool:
	return e_movement.square_distance_to_player() >= u.fpow2(number)

func distance_to_(target: Node3D) -> float:
	return e_movement.distance_to_(target)

func abs_angle_to_player() -> float:
	return e_movement.abs_angle_to_player()

func signed_angle_to_player() -> float:
	return e_movement.signed_angle_to_player()

func direction_to_(target: Variant) -> Vector3:
	return e_movement.direction_to_(target)

# endregion


# region: __LOGS

func __get_common_context() -> String:
	var _msg = ""
	_msg += pp.s("Pl->E", pp.round_01(distance_to_player()),
		"∠" + pp.rad2deg(signed_angle_to_player(), true))
	return _msg


@abstract func __log_state() -> String

@abstract func __log_indent() -> int

func __log_phe(...parts: Array):
	print_.phe_sm(__log_state(), pp.list_(parts), __log_indent())

func __log_phe_choose(chose_state_: String, ...parts: Array):
	print_.phe_check(__log_state(), "Chose " + chose_state_ + " " + pp.list_(parts), __log_indent())

func __log_phe_check(...parts: Array):
	print_.phe_check(__log_state(), pp.list_(parts), __log_indent())

func __log_phe_decision(...parts: Array):
	print_.phe_sm(__log_state() + em.verdict, pp.list_(parts), __log_indent())

func __log_ent(...parts: Array):
	print_.phe_sm(__log_state() + pp.on_ent, pp.list_(parts), __log_indent())

@abstract func __log_timings() -> String

func __log_ext(...parts: Array):
	print_.phe_sm(pp.s(__log_state(), pp.on_ext, __log_timings()), pp.list_(parts), __log_indent())

func __log_phe__upd(...parts: Array):
	print_.phe_sm(__log_state() + pp.on_internal_upd, pp.list_(parts), __log_indent())

func __log_upd(...parts: Array):
	print_.phe_sm(__log_state() + pp.on_upd, pp.list_(parts), __log_indent())

func __log_warn(crucial: bool, ...parts: Array):
	print_.warn(pp.s(__log_state(), pp.list_(parts),
		"\n\t\t", me.__pp_state_history()),
		crucial)

# endregion
