extends LegsAction

# anim setting simple
# legs animator - LegsSimple Modifer

# MotionType IDLE


# we also don't have any animation of our own,
# but rely on torso behavior's counterpart to provide one
# func animate(previous_action: LegsAction, input: InputPackage):
	# legs_sm.current_behavior.player_state.setup_legs_animator(previous_action, input)
## overrides
func animate(): # ▶️🔗
	# var animation_ := legs_sm.current_behavior.player_state.current_action.animation
	var animation_ := legs_sm.player_sm.current_state.current_action.anim_name
	
	print_.lsm_action(action_name + em.play, em.linked + "PLAY DOUBLE anim: " + animation_, 8)
	
	legs_sm.legs_animator.set_anim_to_play(animation_, 0.2)
