@tool
@icon("res://-assets-/x_icons/node-colors/orange-2.png")

extends Node
class_name LegsSM

@export var container: PlayerStatesContainer
@export var player_sm: PlayerSM

@export var combat: PlayerCombat


var current_behavior: LegsBehavior
# It should belong here! _current_action is managed by the "pool" of actions. 
# Behavior changes may or may NOT change current action.
var _current_action: LegsAction
var _prev_action: LegsAction ## curr and prev in LSM context. (LegsAction, not BaseAction)


func update(input_: InputPackage, delta: float) -> void:
	current_behavior.update(input_, delta)


func get_player() -> Princess:
	return player_sm.get_player()

func get_curr_action() -> LegsAction:
	return _current_action

func get_prev_action() -> LegsAction:
	return _prev_action


func set_current_action(new_action: LegsAction):
	var __old_prev_name := _prev_action.action_name
	_prev_action = _current_action
	_current_action = new_action
	# print_.dev("[]", pp.s("curr ->", _current_action.action_name,
		# "| prev ->", _prev_action.action_name, pp.in_br("from " + __old_prev_name)), 20)


func switch_to(next_behavior: LegsBehavior, input_: InputPackage):
	if next_behavior == current_behavior:
		print_.lsm_beh("", "not switching legs, same behavior: " + current_behavior.behavior_name)
		return
	print_.lsm_beh("↪️", pp.s(current_behavior.behavior_name, " => ", next_behavior.behavior_name))
	current_behavior._on_exit_behavior()
	current_behavior = next_behavior
	SigUtils.safe_emit_raw(
		GlobalSignal.SIG_player_leg_beh_changed,
		{SPS.state_name_field: current_behavior.behavior_name}
	)
	current_behavior._on_enter_behavior(input_)
