extends PlayerAction

var curr_direction: DualDirection


func _detect_dodge_direction(input_: InputPackage) -> DualDirection.Dir:
	# Right - PRIMARY, Left - SECONDARY
	if input_.input_direction.x > 0.1:
		return DualDirection.Dir.PRIMARY
	else:
		return DualDirection.Dir.SECONDARY

func on_enter_action(input_: InputPackage) -> void:
	var new_dir = _detect_dodge_direction(input_)
	curr_direction.set_direction(new_dir)


func on_exit_action() -> void:
	pass