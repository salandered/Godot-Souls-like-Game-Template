extends BaseAttackAction


func get_hit_damage() -> float:
	match PREV_ACTION:
		PS.Act.axe_slice_2:
			return hit_damage + 20
		_:
			return hit_damage


func get_global_speed_scale() -> float:
	match PREV_ACTION:
		PS.Act.axe_slice_2:
			return 1.2
		_:
			return 1.0

func initialise_implementation() -> void:
	hit_damage = 24

	blend_time.set_by_prev_action({
		PS.Act.axe_slice_2: 0.45,
	})

	start_time_offset.set_by_prev_action({
		PS.Act.axe_slice_2: 0.0,
	})

	extra_root_speed_Z.set_by_prev_action({
		PS.Act.axe_slice_2: 0.0,
		PS.Act.axe_slice_1: 0.0,
		Leg.Act.run: 1.0,
		Leg.Act.sprint: 1.5,
		})
	# extra_root_speed_Z.set_specific(-0.0)


# var _dev_add_blend = 0.2
# var _dev_start_time_offset = 0.0


# func _input(event: InputEvent) -> void:
# 	if not OS.is_debug_build():
# 		return
# 	_dev_add_blend = u._dev_change_t34_param(event, _dev_add_blend, "_dev_add_blend", 0.05)
# 	_dev_start_time_offset = u._dev_change_t67_param(event, _dev_start_time_offset, "_dev_start_time_offset", 0.05)

# 	blend_time.set_by_prev_action({
# 		PS.Act.axe_slice_2: _dev_add_blend,
# 	})

# 	start_time_offset.set_by_prev_action({
# 		PS.Act.axe_slice_2: _dev_start_time_offset,
# 	})
