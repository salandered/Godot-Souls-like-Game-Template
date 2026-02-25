extends BaseAttackAction


var _repeat_count := 0


func get_hit_damage() -> float:
	match PREV_ACTION:
		PS.Act.axe_slice_3:
			var _r = hit_damage - 4 * (_repeat_count + 1)
			return maxf(hit_damage / 2, _r)
		PS.Act.axe_slice_2:
			return hit_damage + 20
		PS.Act.axe_slice_1:
			return hit_damage + 6
		_:
			return hit_damage


func get_global_speed_scale() -> float:
	match PREV_ACTION:
		PS.Act.axe_slice_3:
			var _r := 0.9 - 0.05 * (_repeat_count + 1)
			return maxf(0.7, _r)
		PS.Act.axe_slice_2:
			PlayerStats.set_power_combo()
			return 1.2
		PS.Act.axe_slice_1:
			return 1.05
		_:
			return 0.9


func initialise_implementation() -> void:
	hit_damage = 24

	blend_time.set_by_prev_action({
		PS.Act.axe_slice_1: 0.45,
		PS.Act.axe_slice_2: 0.45,
		PS.Act.axe_slice_3: 0.4,
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
# 	if eu.is_release():
# 		return
# 	_dev_add_blend = InputUtils._dev_change_t34_param(event, _dev_add_blend, "_dev_add_blend", 0.05)
# 	_dev_start_time_offset = InputUtils._dev_change_t67_param(event, _dev_start_time_offset, "_dev_start_time_offset", 0.05)

# 	blend_time.set_by_prev_action({
# 		PS.Act.axe_slice_2: _dev_add_blend,
# 	})

# 	start_time_offset.set_by_prev_action({
# 		PS.Act.axe_slice_2: _dev_start_time_offset,
# 	})


func on_enter_attack_implementation(input_: InputPackage):
	if PREV_ACTION == PS.Act.axe_slice_3:
		_repeat_count += 1
	else:
		_repeat_count = 0