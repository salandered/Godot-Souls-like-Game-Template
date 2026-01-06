extends NodeSystem
class_name LegsBehavior
## Legs SM consists of states called LegsBehavior. LegsBehavior is also a SM.
## `LegsBehavior` manages `LegsActions`, and legs actions live in a shared pool 
##    => We can use `walk_stop` and `idle` in both `run_locomotion` and  `walk_locomotion` cycles. 
##    (See SupportedActions)

var container: PlayerStatesContainer
var legs_sm: LegsSM # set by SM
var combat: PlayerCombat
var area_awareness: AreaAwareness # FILL ME if you use it
var player_state: BasePlayerState # set by SM when switching

var behavior_name: String

var supported_actions: SupportedActions

func get_player() -> Princess:
	return legs_sm.get_player()

func pm() -> PlayerMovement:
	return legs_sm.player_sm.player_movement

func get_lsm_curr_action() -> LegsAction:
	return legs_sm.get_curr_action()

func get_lsm_prev_action() -> LegsAction:
	return legs_sm.get_prev_action()


func get_curr_action() -> BaseAction:
	return legs_sm.player_sm.get_curr_action()

func get_prev_action() -> BaseAction:
	return legs_sm.player_sm.get_prev_action()


func update(input_: InputPackage, delta: float):
	var verdict: LNextActionVerdict = choose_action(input_, delta)
	switch_action_to(verdict, input_) # yes, always. In LegsBehavior switch_action_to is smart
	get_lsm_curr_action()._update(input_, delta)


func _on_enter_behavior(input_: InputPackage):
	# Used to be choosing first action and switch. 
	# But in the same frame later update will be called. Switch logic will be there.
	# It's now safe because choose_action always returns an action belonging to its behavior.
	#   - it can not not deciding on an action (i.e. return empty verdict)
	#   - decided action cant be but supported by behavior.
	# This magic happens thanks to mandatory 'convert_to_supported' in SupportedActions
	# NOTE: switch_action_to still can decline this decision.
	on_enter_behavior(input_)


## usualy is overriden
## behaviors with one supported action should not override 
func choose_action(input_: InputPackage, delta: float) -> LNextActionVerdict:
	if len(supported_actions.action_names) > 1:
		__log_warn("default choose_action called when supported_actions.action_names > 1 for " + behavior_name)
	return LNextActionVerdict.new(supported_actions.action_names[0])


## to override
func on_enter_behavior(input_: InputPackage):
	pass

## currently nothing. There is even no on_exit_behavior for overrides.
func _on_exit_behavior():
	pass


func switch_action_to(verdict: LNextActionVerdict, input_: InputPackage):
	var curr_action_name := get_lsm_curr_action().action_name
	var next_action_name := verdict.next_action
	
	# VALIDATE THE SWITCH
	if next_action_name == "":
		__log_warn("Next action is empty str. This is normally should not happen ❌. Not switching from" + curr_action_name)
		return

	if curr_action_name == next_action_name:
		# spams a lot
		# print_.lsm_action("", pp.s("switch declined ✖️: same action", next_action_name))
		return
	## hard coded tranfer, but seems like its ok, we dont have too many actions 
	# if next_action_name == Leg.Act.sprint and curr_action_name == Leg.Act.run \
	# 	and legs_sm.current_action.till_blend_completes() > 0.0:
	# 	print_.lsm_action("", pp.s("switch to", next_action_name, "declined ✖️:", curr_action_name, "needs time to blend from the prev one."))
	# 	return
	# if next_action_name != Leg.Act.double and curr_action_name != Leg.Act.double \
	# 	and legs_sm.current_action.till_blend_completes() > 0.1: # ideally 0, but small tolerance is ok
	# 	print_.lsm_action("", pp.s("switch to", next_action_name, "declined ✖️: current", curr_action_name, "needs time to blend from the prev one."))
	# 	return
		
	# SWITCH
	print_.lsm_action("↪️", "action " + curr_action_name + " => " + next_action_name)
	get_lsm_curr_action()._on_exit_action()
	var _next_action := container.l_action_by_name(next_action_name)
	_next_action._on_enter_action(input_)


# region: shortcuts for decision checks

func is_moving(input_: InputPackage) -> bool:
	## note that on a keyboard it's either 0 or 1 
	return input_.input_direction.length() > 0.1

func is_reverse_moving(input_: InputPackage) -> bool:
	## is_moving can show zero while two keys pressed at once.
	## input_.reverse_data captures such case.
	## but it also captures very fast sequential presses 
	## => is_reverse_moving and is_moving answers may or may not overlap 
	##    => WARNING: their order is important
	return input_.reverse_data.is_reversed()

func is_pure_reverse_moving(input_: InputPackage) -> bool:
	return input_.reverse_data.is_pure_reversed()

func is_switch_from_unsupported_action() -> bool:
	return not supported_actions.is_action_supported(get_curr_action().action_name)

# endregion

func __log_decision_data(input_: InputPackage, next_action_name: String, ...additional_checks: Array):
	var _curr_motion_type := get_curr_action().motion_type
	print_.lsm_beh_ch(behavior_name,
		_curr_motion_type,
		is_moving(input_),
		is_reverse_moving(input_),
		is_pure_reverse_moving(input_),
		pp.array_(additional_checks),
		next_action_name)


# ## __LOGS
# # region


func __ELA() -> bool:
	## "extra logs allowed"
	return LogToggler.BEHAVIOR_INTERNAL_FILTER


func pp_name() -> String:
	return behavior_name

func __LOG_B() -> bool:
	return false

func __LOG_INDENT() -> int:
	return 0

# # endregion