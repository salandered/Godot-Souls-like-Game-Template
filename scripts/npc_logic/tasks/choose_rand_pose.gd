extends BTAction

func _tick(_delta: float) -> Status:
	# bird pos in the world
	var pos: Vector3 = agent.global_transform.origin
	
	pos += Vector3(
		randf_range(-5, 5),
		0,
		randf_range(-5, 5),
	)
	# blackboard - global var that is available to tasks
	blackboard.set_var("pos", pos)
	
	return SUCCESS
