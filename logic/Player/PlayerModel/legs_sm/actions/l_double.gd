extends LegsAction

# anim setting simple
# legs animator - LegsSimple Modifer

# MotionType IDLE


# we also don't have any animation of our own,
# but rely on torso behavior's counterpart to provide one
# func animate(previous_action: LegsAction, input: InputPackage):
	# legs_sm.current_behavior.player_state.setup_legs_animator(previous_action, input)
## can be overriden (see double action)
func animate(previous_action: LegsAction, _input: InputPackage):
	var animation_ := legs_sm.current_behavior.player_state.current_action.animation
	
	print_.prefix("~~ LSM Action PLAY DOUBLE", "anim: " + animation_, 2)
	
	legs_animator.play(animation_, 0.2)
