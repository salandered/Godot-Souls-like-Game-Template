extends BaseAction
class_name PlayerAction

var state_name: String

## to override if needed
func initialise() -> void:
	pass


# not abstract
func update(input_: InputPackage, delta: float):
	pass


## LOGS

func __log_function(prefix: String, ...parts: Array) -> void:
	print_.psm_action(prefix, pp.list_(parts))
