extends LegsAction

# we also don't have any animation of our own,
# but rely on torso behavior's counterpart to provide one
func setup_animator(previous_action: LegsAction, input: InputPackage):
	legs.current_behavior.torso_behavior.setup_legs_animator(previous_action, input)
