extends LegsBehavior


func _ready() -> void:
	used_actions = [
	PS.legs_action_double,
]

func update(input: InputPackage, delta: float):
	player_state.update_legs(input, delta)


func on_enter_behavior(input: InputPackage):
	switch_action_to(PS.legs_action_double, input)
