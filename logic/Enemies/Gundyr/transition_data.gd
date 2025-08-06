extends Resource
class_name TransitionData

# TODO: why both vars. 
# check that empty string in target_state is always used with needs_switch = false
var needs_switch: bool
var target_state: String

# you can send some other data between your states

func _init(verdict: bool, next_state: String):
	needs_switch = verdict
	target_state = next_state
