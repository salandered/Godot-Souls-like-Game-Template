extends Combo_

class_name ConsecutiveAttack

@export var primary_input: String


func is_triggered(input: InputPackage) -> bool:
	print_.prefix("Combo 🗡️ " + name, "Checking for trigger for state " + state.state_name + \
				" Primary input: " + primary_input + \
				" triggered_state: " + state_to_trigger + \
				" current input.actions: " + str(input.actions)
				)
	# TODO: not actions ...
	if input.actions.has(primary_input):
		print_.prefix("Combo 🗡️ " + name, "triggered", 1)
		return true
	return false
