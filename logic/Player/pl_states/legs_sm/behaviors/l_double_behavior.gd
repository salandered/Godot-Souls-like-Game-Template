extends LegsBehavior

func _ready() -> void:
	supported_actions = [
		LS.legs_action_double
		]

# func on_enter_behavior(_input: InputPackage) -> void:
# 	pass

# func update(input: InputPackage, delta: float) -> void:
# 	legs_sm.current_action.update(input, delta)


# func _ready() -> void:
# 	uses_actions = [
# 	LS.legs_action_double,
# ]

# func update(input: InputPackage, delta: float):
# 	player_state.update_legs(input, delta)
