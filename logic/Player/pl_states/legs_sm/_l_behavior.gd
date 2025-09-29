extends Node
## Legs SM consists of states called LegsBehavior. 
## LegsBehavior is a piece of transition logic, it only manages what action updates our legs currently
class_name LegsBehavior

var container: PlayerStatesContainer
var legs_sm: LegsSM # set by SM
var player: Princess # optional; set by SM if you want it
var combat: HumanoidCombat # optional; set by SM if you want it
# var legs_anim_settings: AnimationPlayer # optional; set by SM if you want it
var area_awareness: AreaAwareness # FILL ME if you use it
var player_state: PlayerState # set by SM when switching

var behavior_name: String

var supported_actions: Array[String] = []


## Not abstract! It can be empty and not overriden (double behavior)
func update(_input: InputPackage, _delta: float):
	# todo: i suppose it should be here, not in implementations:
		# legs_sm.current_action.update(_input, _delta)
	pass


func switch_action_to(next_action_name: String, input: InputPackage):
	var prev_action := legs_sm.current_action

	if prev_action.action_name == next_action_name:
		# this print important but spams a lot
		print_.lsm_action("", pp.ts("Switch called with same", prev_action.action_name, "=> no switch ⚪"), 3)
		return

	print_.lsm_action("↪️", "action " + prev_action.action_name + " => " + next_action_name, 3)

	prev_action._on_exit_action()

	var next_action: LegsAction = container.legs_action_by_name(next_action_name)
	legs_sm.current_action = next_action

	next_action._on_enter_action(input)


func _on_enter_behavior(_input: InputPackage):
	## It can be that prev behavior used and action which new one supports.
	## We don't switch it, then. Later in update() it would be considered as a usual routine. 
	if supported_actions.has(legs_sm.current_action.action_name):
		print_.lsm_beh(behavior_name + " on enter", pp.ts("Supports curr action", legs_sm.current_action.action_name, "=> no switch ⚪"), 2)
	else:
		var choosen_action := choose_initial_action(_input)
		# print_.lsm_beh(behavior_name + " on enter", "Initial action choosen " + choosen_action, 2)

		switch_action_to(choosen_action, _input)

	on_enter_behavior(_input)

## to override
func on_enter_behavior(input: InputPackage):
	pass

## currently nothing. There is even no on_exit_behavior for overrides.
func _on_exit_behavior():
	pass

## can be overriden
## behaviors with one supported action don't need to override
func choose_initial_action(input) -> String:
	print_.lsm_action("INITIAL", "using base choose_initial_action: pick first", 3)
	assert(len(supported_actions) > 0)
	# if supported_actions.is_empty():
		# print_.lsm_action(" INITIAL", "supported_actions is empty, nothing to choose", 3)
		# ""
	return supported_actions[0]
