extends Node
class_name LegsBehavior
## Legs SM consists of states called LegsBehavior. LegsBehavior is also a SM.
## `LegsBehavior` manages `LegsActions`, and legs actions live in a shared pool 
##    => We can use `walk_stop` and `idle` in both `run_locomotion` and  `walk_locomotion` cycles. 
##    (See SupportedActions)

var container: PlayerStatesContainer
var legs_sm: LegsSM # set by SM
var combat: HumanoidCombat
var area_awareness: AreaAwareness # FILL ME if you use it
var player_state: PlayerState # set by SM when switching

var behavior_name: String

var supported_actions: SupportedActions

func get_player() -> Princess:
	return legs_sm.player_sm.player


func update(_input: InputPackage, _delta: float):
	var verdict: LNextActionVerdict = choose_action(_input, _delta)
	switch_action_to(verdict, _input) # yes, always. In LegsBehavior switch_action_to is smart
	legs_sm.current_action._update(_input, _delta)


func _on_enter_behavior(_input: InputPackage):
	# Used to be choosing first action and switch. 
	# But in the same frame later update will be called. Switch logic will be there.
	# It's now safe because choose_action always returns an action belonging to its behavior.
	#   - it can not not deciding on an action (i.e. return empty verdict)
	#   - decided action cant be but supported by behavior.
	# This magic happens thanks to mandatory 'convert_to_supported' in SupportedActions
	# NOTE: switch_action_to still can decline this decision.
	on_enter_behavior(_input)


## usualy is overriden
## behaviors with one supported action should not override 
func choose_action(_input, _delta) -> LNextActionVerdict:
	if len(supported_actions.action_names) > 1:
		print_.warn("default choose_action called when supported_actions.action_names > 1 for " + behavior_name)
	return LNextActionVerdict.new(supported_actions.action_names[0])


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
	
	# if next_action_name != Leg.Act.double and curr_action_name != Leg.Act.double \
	# 	and legs_sm.current_action.time_remaining_for_blend_to_complete() > 0.1: # ideally 0, but small tolerance is ok
	# 	print_.lsm_action("", pp.s("switch to", next_action_name, "declined ✖️: current", curr_action_name, "needs time to blend from the prev one."))
	# 	return
		
	# SWITCH
	print_.lsm_action("↪️", "action " + curr_action_name + " => " + next_action_name)
	legs_sm.current_action._on_exit_action()
	legs_sm.current_action = container.legs_action_by_name(next_action_name)
	legs_sm.current_action._on_enter_action(input)


# region: sugar for decision checks

func is_moving(input) -> bool:
	## note that on a keyboard it's either 0 or 1 
	return input.input_direction.length() > 0.1

func is_reverse_moving(input) -> bool:
	## is_moving can show zero while two keys pressed at once.
	## input.reverse_data captures such case.
	## but it also captures very fast sequential presses 
	## => is_reverse_moving and is_moving answers may or may not overlap 
	##    => WARNING: their order is important
	return input.reverse_data.is_reversed()

func is_pure_reverse_moving(input) -> bool:
	return input.reverse_data.is_pure_reversed()

func get_abs_angle_pl_input(input, delta) -> float:
	var angle = get_player().model.__angle_between_player_and_input(input, delta)
	return abs(angle)

func get_abs_angle_pl_input_deg(input, delta) -> float:
	var angle = get_player().model.__angle_between_player_and_input(input, delta)
	return rad_to_deg(abs(angle))

# endregion

func __log_decision_data(input, additional_checks: String, next_action_name: String):
	var _curr_motion_type = legs_sm.current_action.motion_type
	print_.lsm_beh_ch(behavior_name,
		_curr_motion_type,
		is_moving(input),
		is_reverse_moving(input),
		is_pure_reverse_moving(input),
		additional_checks,
		next_action_name)