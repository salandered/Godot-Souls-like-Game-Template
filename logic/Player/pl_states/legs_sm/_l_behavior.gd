extends Node
class_name LegsBehavior
## Legs SM consists of states called LegsBehavior. 
## LegsBehavior manages what action updates our legs currently.

var container: PlayerStatesContainer
var legs_sm: LegsSM # set by SM
var player: Princess
var combat: HumanoidCombat
var area_awareness: AreaAwareness # FILL ME if you use it
var player_state: PlayerState # set by SM when switching

var behavior_name: String


var supported_actions: SupportedActions


func update(_input: InputPackage, _delta: float):
	var verdict: LNextActionVerdict = choose_action(_input, _delta)
	switch_action_to(verdict, _input) # yes, always. In LegsBehavior switch_action_to is smart
	legs_sm.current_action.update(_input, _delta)


func _on_enter_behavior(_input: InputPackage):
	## If beh supports an action which were used by the prev one, we don't switch
	if supported_actions.actions.has(legs_sm.current_action.action_name):
		print_.lsm_beh(behavior_name + pp.on_ent, pp.s("Supports curr action", legs_sm.current_action.action_name, "=> no switch ⚪"))
	else:
		var initial_action := choose_initial_action(_input)
		# print_.lsm_beh(behavior_name + pp.on_ent, "Initial action choosen " + choosen_action)
		switch_action_to(initial_action, _input)

	on_enter_behavior(_input)


## usualy is overriden
## behaviors with one supported action should not override
func choose_initial_action(input) -> LNextActionVerdict:
	print_.lsm_action("Choose initial", "using default method: pick first")
	return LNextActionVerdict.new(supported_actions.actions[0]) # safe, validated in supported_actions

## usualy is overriden
## behaviors with one supported action should not override 
func choose_action(_input, _delta) -> LNextActionVerdict:
	return LNextActionVerdict.new(supported_actions.actions[0])


## to override
func on_enter_behavior(input: InputPackage):
	pass

## currently nothing. There is even no on_exit_behavior for overrides.
func _on_exit_behavior():
	pass


func switch_action_to(verdict: LNextActionVerdict, input: InputPackage):
	var curr_action_name := legs_sm.current_action.action_name
	var next_action_name := verdict.next_action
	
	# VALIDATE THE SWITCH
	if next_action_name == "":
		print_.warn("Next action is empty str. This is normally should not happen ❌. Not switching from" + curr_action_name)
		return

	if curr_action_name == next_action_name:
		# spams a lot
		# print_.lsm_action("", pp.s("switch declined ✖️: same action", next_action_name))
		return
	
	if next_action_name != Leg.Act.double and curr_action_name != Leg.Act.double \
		and legs_sm.current_action.time_remaining_for_blend_to_complete() > 0.2: # may be small tolerance here
		print_.lsm_action("", pp.s("switch to", next_action_name, "declined ✖️: current", curr_action_name, "needs time to blend from the prev one."))
		return
		
	# SWITCH
	print_.lsm_action("↪️", "action " + curr_action_name + " => " + next_action_name)
	legs_sm.current_action._on_exit_action()
	legs_sm.current_action = container.legs_action_by_name(next_action_name)
	legs_sm.current_action._on_enter_action(input)