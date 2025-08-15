extends LegsBehavior

func update(input: InputPackage, delta: float):
	torso_behavior.update_legs(input, delta)


func on_enter_behavior(input: InputPackage):
	switch_to("double", input)
