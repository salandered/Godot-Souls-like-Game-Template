extends LegsLockedVertMoveAction


func initialise():
	ACCEL_FROM_IDLE_TIME = 0.4
	DIR_CHANGE_TIME = 0.3

	ANIM_F = A.strafe.combat_walk_f
	ANIM_B = A.strafe.combat_walk_b
	SPEED_F = 1.3
	SPEED_B = 1.2

	next_anim_correction = 0.93
	
	__initialise()

	
# var _next_anim_correction = 0.93
# func _input(event):
# 	# _dev_add_blend = u._dev_change_t12_param(event, _dev_add_blend, "_dev_add_blend", 0.05)
# 	_next_anim_correction = u._dev_change_t34_param(event, _next_anim_correction, "_next_anim_correction", 0.05)
