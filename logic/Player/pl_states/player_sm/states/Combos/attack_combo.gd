extends Combo_

class_name AttackCombo

@export var primary_input: String


func is_triggered(input_: InputPackage) -> bool:
	if input_.actions.has(primary_input):
		print_.combo(name + " triggered 🖲️",
			pp.s("input.actions has input", pp.in_q(primary_input),
			"state_to_trigger", state_to_trigger))
		return true
	return false
