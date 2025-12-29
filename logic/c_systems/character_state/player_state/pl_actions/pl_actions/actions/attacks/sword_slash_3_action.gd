extends BaseAttackAction


func get_hit_damage() -> float:
	match PREV_ACTION:
		PS.Act.sword_slash_2:
			return hit_damage + 5
		_:
			return hit_damage


func get_global_speed_scale() -> float:
	match PREV_ACTION:
		PS.Act.sword_slash_2:
			return 1.1
		_:
			return 1.0


func initialise_implementation() -> void:
	hit_damage = 10


	blend_time.set_by_prev_action({
		PS.Act.sword_slash_2: 0.3,
	})

	start_time_offset.set_by_prev_action({
		PS.Act.sword_slash_2: 0.4,
	})

	extra_root_speed_Z.set_by_prev_action({
		PS.Act.sword_slash_2: 0.0,
		Leg.Act.run: 1.0,
		Leg.Act.sprint: 1.5,
		})
	extra_root_speed_Z.set_specific(-0.0)


## TODO: dont use custom update
func update(input_: InputPackage, delta: float):
	if tracks_input_vector() and not player_sm.area_awareness.is_camera_locked():
		pm().rotate_with_input_vector(input_, delta, SpeedConfig.new(default_sp))
	
	
	var fade_factor := fade_interpolator.update(delta)
	var extra_vel_local := Vector3(_final_extra_speed_X * fade_factor, 0, _final_extra_speed_Z * fade_factor) # Animation +Z
	
	pm().move_with_root(delta, extra_vel_local)
	
	__log_hurt()

	_combat_update_is_attacking(false)


# DEV

# var _blend_time: float = 0.2
# var _start_time_offset: float = 0.0

# func _input(event):
# 	_blend_time = u._dev_change_t12_param(event, _blend_time, "_blend_time", 0.1)
# 	_start_time_offset = u._dev_change_t34_param(event, _start_time_offset, "_start_time_offset", 0.1)

# 	blend_time.set_by_prev_action({
# 		PS.Act.sword_slash_2: _blend_time,
# 	})

# 	start_time_offset.set_by_prev_action({
# 		PS.Act.sword_slash_2: _start_time_offset,
# 	})
