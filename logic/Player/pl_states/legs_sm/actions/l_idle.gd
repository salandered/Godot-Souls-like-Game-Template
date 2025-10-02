extends LegsAction


func update(_input: InputPackage, _delta: float) -> void:
	player.velocity = Vector3.ZERO


func animate(): # ▶️
	var blend_time := default_blend_time
	var start_time_offset := 0.0

	match legs_sm.prev_action.action_name:
		Leg.Act.sprint_to_idle:
			blend_time = 0.3

	__log_anim(blend_time, start_time_offset)
	animator_manager.set_anim_to_play(anim_id, blend_time, start_time_offset)
