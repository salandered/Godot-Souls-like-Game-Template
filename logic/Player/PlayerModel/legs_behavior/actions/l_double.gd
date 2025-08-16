extends LegsAction

# anim setting simple
# legs animator - LegsSimple Modifer

# MotionType IDLE


# we also don't have any animation of our own,
# but rely on torso behavior's counterpart to provide one
func animate(previous_action: LegsAction, input: InputPackage):
	legs_sm.current_behavior.player_state.setup_legs_animator(previous_action, input)
