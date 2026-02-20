extends BaseAttackAction


func get_global_speed_scale() -> float:
	return 1.1


func initialise_implementation() -> void:
	hit_damage = 24

	blend_time.set_by_prev_action({
		PS.Act.axe_slice_1: 0.4,
	})

	start_time_offset.set_by_prev_action({
		PS.Act.axe_slice_1: 0.0,
	})


	extra_root_speed_Z.set_by_prev_action({
		PS.Act.axe_slice_1: 0.0,
		PS.Act.axe_slice_2: 0.0,
		PS.Act.axe_slice_3: 0.0,
		})

# var _dev_add_blend = 0.2
# var _dev_start_time_offset = 0.0


# func _input(event: InputEvent) -> void:
# 	if u.is_release():
# 		return
# 	_dev_add_blend = InputUtils._dev_change_t34_param(event, _dev_add_blend, "_dev_add_blend", 0.05)
# 	_dev_start_time_offset = InputUtils._dev_change_t67_param(event, _dev_start_time_offset, "_dev_start_time_offset", 0.05)

# 	blend_time.set_by_prev_action({
# 		PS.Act.axe_slice_1: _dev_add_blend,
# 	})

# 	start_time_offset.set_by_prev_action({
# 		PS.Act.axe_slice_1: _dev_start_time_offset,
# 	})
