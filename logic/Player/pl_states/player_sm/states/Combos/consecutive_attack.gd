extends Combo_

class_name AttackCombo

@export var primary_input: String


func is_triggered(input: InputPackage) -> bool:
	print_.combo(name, pp.ts("is_triggered?",
					"Primary input:", primary_input,
					"state_to_trigger:", state_to_trigger,
					"current input.actions:", input.actions
				))
	# TODO: not actions ...
	if input.actions.has(primary_input):
		print_.combo(name, "triggered 🖲️", 1)
		return true
	return false
