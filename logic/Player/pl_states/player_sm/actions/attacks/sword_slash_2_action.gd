extends BaseAttackAction


func initialise() -> void:
	hit_damage = 15

	default_sp.ANGULAR_SPEED = 8

	blend_time.set_by_prev_action({
		PS.Act.sword_slash_1: 0.3,
	})

	start_time_offset.set_by_prev_action({
		PS.Act.sword_slash_1: 0.3,
	})


# var _dev_add_blend := 0.0
# var _dev_add_offset := 0.0


# func _input(event):
# 	_dev_add_blend = u._dev_change_t34_param(event, _dev_add_blend, "_dev_add_blend", 0.1)
# 	_dev_add_offset = u._dev_change_t67_param(event, _dev_add_offset, "_dev_add_offset", 0.1)
	
# 	blend_time.set_by_prev_action({
# 		PS.Act.sword_slash_1: 0.0 + _dev_add_blend,
# 	})
# 	start_time_offset.set_by_prev_action({
# 		PS.Act.sword_slash_1: 0.0 + _dev_add_offset,
# 	})
