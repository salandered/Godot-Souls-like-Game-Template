extends BTAction

func _tick(_delta: float) -> Status:
	var target_pos: Vector3 = blackboard.get_var("pos")
	# accessing character (bird) via agent
	var current_pos: Vector3 = agent.global_transform.origin
	
	# move is a birds function (custom)
	agent.move(target_pos, _delta)
	
	if Vector2(current_pos.x, current_pos.z).distance_to(Vector2(target_pos.x, target_pos.z)) <=0.1:
		agent.velocity = Vector3.ZERO
		# limbo ai Sequence needs success
		return SUCCESS
	
	
	return RUNNING
