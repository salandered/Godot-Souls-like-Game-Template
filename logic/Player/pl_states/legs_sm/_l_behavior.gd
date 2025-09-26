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


## Not abstract! It can be empty and not overriden. (double behavior)
func update(_input: InputPackage, _delta: float):
	# todo: i suppose it should be here, not in implementations:
		# legs_sm.current_action.update(_input, _delta)
	pass


func switch_action_to(next_action_name: String, input: InputPackage):
	var previous_action := legs_sm.current_action

	if previous_action.action_name == next_action_name and not next_action_name == LS.legs_action_double:
		# this print important but spams a lot
		# print_.lsm_action("", "switch called with same " + previous_action.action_name + "⚪ NO SWITCH", 3)
		return

	print_.lsm_action("↪️", "action " + previous_action.action_name + " => " + next_action_name, 3)

	previous_action._on_exit_action()

	var next_action: LegsAction = container.legs_action_by_name(next_action_name)
	legs_sm.current_action = next_action

	next_action._on_enter_action(input)


func _on_enter_behavior(_input: InputPackage):
	## If it so happens that the previous behavior used one of our states, 
	## we don't bother switching it and instead work directly from here, analysing the next input. 
	if not __new_behavior_supports_current_action() or __double_behavior_coming():
		var choosen_action := choose_initial_action(_input)
		print_.lsm_beh(behavior_name + " on enter", "choose INITIAL -> " + choosen_action, 2)
		if choosen_action == "":
			push_error("No valid action found")

		switch_action_to(choosen_action, _input)

	else:
		print_.lsm_beh(behavior_name + " on enter", "can use current action so NO SWITCH ⚪ ", 2)

	on_enter_behavior(_input)

func on_enter_behavior(input: InputPackage):
	pass

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


func __new_behavior_supports_current_action() -> bool:
	if supported_actions.has(legs_sm.current_action.action_name):
		return true
	return false

func __double_behavior_coming() -> bool:
	return behavior_name == LS.legs_behavior_double