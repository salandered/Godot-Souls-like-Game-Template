@tool
@icon("res://-assets-/x_misc/x_icons/node-colors/orange-2.png")

extends Node
class_name LegsSM

@export var container: PlayerStatesContainer
@export var player_sm: PlayerSM
@export var area_awareness: AreaAwareness

@export var combat: HumanoidCombat

# TODO: fast solution. Design proper action (or states) ability to share data.
## for now its supposed to store only prev action data
## (u should not get data from some random past state, while its possible)
class TranferData extends RefCounted:
	var action_name: String
	var _transfer: Dictionary

	func _init(action_name_: String, data_ = null) -> void:
		action_name = action_name_
		if data_ == null:
			_transfer = {}
		elif data_ is Dictionary:
			_transfer = data_.duplicate_deep()
		else:
			_transfer = {}

	func _get_by_key(key: String) -> Variant:
		return u.safe_get_dict_key(_transfer, key, "Getting _transfer from TranferData")

	func get_by_key_if_action(action_name_: String, key: String) -> Variant:
		if action_name == action_name_:
			return _get_by_key(key)
		return null

	func fill(action_name_: String, data_: Dictionary):
		var msg = pp.s("| keys:", pp._dict(data_) if data_ is Dictionary else "| data is not a Dict" + em.warn)
		print_.lsm_beh("TransferData fill for " + pp.in_q(action_name_), msg)
		action_name = action_name_
		_transfer = data_.duplicate_deep()

	func _reset():
		action_name = ""
		_transfer = {}


var transfer_data = TranferData.new("")

var current_behavior: LegsBehavior
# It should belong here! current_action is managed by the "pool" of actions. 
# Behavior changes may or may NOT change current action.
var current_action: LegsAction
var prev_action: LegsAction

func update(input: InputPackage, delta: float) -> void:
	current_behavior.update(input, delta)


func switch_to(next_behavior: LegsBehavior, input: InputPackage):
	if next_behavior == current_behavior:
		print_.lsm_beh("", "not switching legs, same behavior:" + current_behavior.behavior_name)
		return
	print_.lsm_beh("↪️", pp.s(current_behavior.behavior_name, " = > ", next_behavior.behavior_name))
	current_behavior._on_exit_behavior()
	if next_behavior.behavior_name == Leg.Beh.sprint:
		print()
	current_behavior = next_behavior
	current_behavior._on_enter_behavior(input)
