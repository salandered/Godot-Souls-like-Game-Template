extends Combo

class_name ConsecutiveAttack

@export var panic_click_block: float

@export var primary_input: String


func is_triggered(input: InputPackage):
	if input.actions.has(primary_input) and state.works_longer_than(panic_click_block):
		return true
	return false
