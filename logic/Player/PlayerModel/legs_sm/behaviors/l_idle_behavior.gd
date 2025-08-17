extends LegsBehavior


func _ready() -> void:
	supported_actions = [
		LS.legs_action_idle,
	]

func update(input: InputPackage, delta: float):
	legs_sm.current_action.update(input, delta)


# func choose_initial_action(input: InputPackage):
# 	print_.prefix("LSM Beh INITIAL", "idle beh chooses initial idle action", 1)
# 	switch_action_to(LS.legs_action_idle, input)
# 	# print_.prefix("LSM Action", "using idle choose_initial_action based on " + str(legs_sm.current_action.motion_type), 2)
# 	# match legs_sm.current_action.motion_type:
# 	# 	legs_sm.MotionType.IDLE:
# 	# 		# switch_action_to(LS.legs_action_run, input)
# 	# 		return
# 	# 	legs_sm.MotionType.CYCLE:
# 	# 		switch_action_to(LS.legs_action_idle, input)
# 	# 		return
