@tool
@icon("res://-assets-/x_misc/x_icons/node-colors/orange-2.png")

extends Node
class_name LegsSM

@export var container: PlayerStatesContainer
@export var player_sm: PlayerSM
@export var area_awareness: AreaAwareness

@export var combat: PlayerCombat


var current_behavior: LegsBehavior
# It should belong here! current_action is managed by the "pool" of actions. 
# Behavior changes may or may NOT change current action.
var current_action: LegsAction
var prev_action: LegsAction ## curr and prev in LSM context


func update(input_: InputPackage, delta: float) -> void:
	current_behavior.update(input_, delta)


func set_current_action(new_action: LegsAction):
	prev_action = current_action
	current_action = new_action


func switch_to(next_behavior: LegsBehavior, input_: InputPackage):
	if next_behavior == current_behavior:
		print_.lsm_beh("", "not switching legs, same behavior: " + current_behavior.behavior_name)
		return
	print_.lsm_beh("↪️", pp.s(current_behavior.behavior_name, " => ", next_behavior.behavior_name))
	current_behavior._on_exit_behavior()
	if next_behavior.behavior_name == Leg.Beh.sprint:
		print()
	current_behavior = next_behavior
	current_behavior._on_enter_behavior(input_)
