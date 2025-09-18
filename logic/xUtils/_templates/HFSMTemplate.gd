extends BaseHSMEState


#these are the functions you might to redefine to create a custom logic:

# check_transition is the transition logic for transitioning on the same level as current node
func check_transition(delta) -> VerdictHSM:
	return VerdictHSM.new("to what")


# choose_internal_state is the function that is being called exactly one time on_enter of BaseHSMEState
# which is also a container. Return the state in which this sub state machine starts
func choose_internal_state() -> VerdictHSM:
	return VerdictHSM.new("where to start")


# update(delta) is the function that will be called every _physics_update(), put your logic here
func update(delta):
	pass

# if you need, create custom events with on_enter() and on_exit()
# these functions are called when the state starts or ends it's lifecycle
func on_enter():
	pass

func on_exit():
	pass
