extends LegsAction


func _ready():
	blend_time_by_action = {
		Leg.Act.sprint_to_idle: 0.3,
		Leg.Act.turn_180: 0.3
	}


func update(_input: InputPackage, _delta: float) -> void:
	get_player().velocity = Vector3.ZERO


func animate(): # ▶️
	var blend_time: float = blend_time_by_action.get(legs_sm.prev_action.action_name, default_blend_time)
	var start_time_offset := 0.0

			
	__log_anim(blend_time, start_time_offset)
	animator_manager.set_anim_to_play(anim.anim_id, blend_time, start_time_offset)
