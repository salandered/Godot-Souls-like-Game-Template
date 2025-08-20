extends LegsBehavior


func _ready() -> void:
	supported_actions = [
	LS.legs_action_idle,
	LS.legs_action_run,
	LS.legs_action_sprint,
	]

func update(input: InputPackage, delta: float) -> void:
	_choose_action(input)
	legs_sm.current_action.update(input, delta)


func _choose_action(input: InputPackage) -> void:
	if input.actions.has(PS.sprint):
		switch_action_to(LS.legs_action_sprint, input)
	elif input.actions.has(PS.run):
		switch_action_to(LS.legs_action_run, input)
	else:
		switch_action_to(LS.legs_action_idle, input)

func choose_initial_action(input: InputPackage) -> String:
	print_.prefix("LSM Beh Sprint INITIAL", "choosing legs_action_sprint", 1)
	return LS.legs_action_sprint
