@tool
@icon("res://-assets-/x_misc/x_icons/node-colors/orange-2.png")

extends Node
class_name LegsSM

@export var container: PlayerStatesContainer
@export var player_sm: PlayerSM
@export var area_awareness: AreaAwareness

@export var combat: PlayerCombat


var _transfer_data: TranferData = TranferData.new()

var current_behavior: LegsBehavior
# It should belong here! current_action is managed by the "pool" of actions. 
# Behavior changes may or may NOT change current action.
var current_action: LegsAction
var prev_action: LegsAction

func update(input_: InputPackage, delta: float) -> void:
	current_behavior.update(input_, delta)


# TODO: fast solution. Design proper action (or states) ability to share data.
## for now its supposed to store only prev action data
## so actions can only use these methods for working with tranfer data
func fill_tranfer_data(tranfer_turn_data):
	## auto setting current action
	_transfer_data.fill(current_action.action_name, tranfer_turn_data)

func get_tranfer_data_by_key(key) -> Variant:
	## auto getting prev one
	var data = _transfer_data.get_by_action_and_key(prev_action.action_name, key)
	return data


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
