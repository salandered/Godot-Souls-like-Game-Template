extends Combo_

class_name ConsecutiveAttack

@export var primary_input: String


func is_triggered(input: InputPackage) -> bool:
	# TODO: not actions ...
	if input.actions.has(primary_input):
		return true
	return false
