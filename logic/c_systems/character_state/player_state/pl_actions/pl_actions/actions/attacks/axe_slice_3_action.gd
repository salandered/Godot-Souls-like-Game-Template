extends BaseAttackAction


func initialise_implementation() -> void:
	hit_damage = 44

	blend_time.set_by_prev_action({
		PS.Act.axe_slice_2: 0.45,
	})

	start_time_offset.set_by_prev_action({
		PS.Act.axe_slice_2: 0.0,
	})


var _dev_add_blend = 0.2
var _dev_start_time_offset = 0.0


func _input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	_dev_add_blend = u._dev_change_t34_param(event, _dev_add_blend, "_dev_add_blend", 0.05)
	_dev_start_time_offset = u._dev_change_t67_param(event, _dev_start_time_offset, "_dev_start_time_offset", 0.05)

	blend_time.set_by_prev_action({
		PS.Act.axe_slice_2: _dev_add_blend,
	})

	start_time_offset.set_by_prev_action({
		PS.Act.axe_slice_2: _dev_start_time_offset,
	})
