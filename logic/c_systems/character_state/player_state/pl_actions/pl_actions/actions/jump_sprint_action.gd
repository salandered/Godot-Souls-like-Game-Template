extends PlayerAction


var VERT_SPEED_BUMP: float = 3
var FORWARD_SPEED_BUMP: float = 2
var GRAVITY_DURING_JUMP: float = 9

var is_jumped: bool = false

# region: DOCS NOTE
##   It looks like a good jump in game dev is three different states: jump up, midair and land.
##   but here i deliberatly use jump up with the almost full parabolic ark and then try to switch straight to land state.
##   (if during this smart jump up we see that floor is nowhere near, we d go to midair, of course)
##   Reasons: 
##		I dont like current midair animations
##      We jump only from sprint state more like forward then up (dark souls like)
##      I am not even sure we need a jump in out game tbh
# endregion


func on_enter_action(input_: InputPackage) -> void:
	is_jumped = false


func update(input_: InputPackage, delta: float) -> void:
	if passed_marker(MarkerName.JUMP.LAUNCH):
		if not is_jumped:
			__log_upd("passed_marker JUMP_LAUNCH and is_jumped false => + VERT_SPEED_BUMP")
			get_player().velocity.y += VERT_SPEED_BUMP
			var _face_dir := get_player().global_basis.z
			get_player().velocity += _face_dir * FORWARD_SPEED_BUMP
			is_jumped = true

	# Apply gravity throughout the jump (creates the arc)
	if is_jumped:
		pm().apply_gravity(delta, 1.0, GRAVITY_DURING_JUMP)
	
	if passed_marker(MarkerName.JUMP.PEAK):
		if pm().get_curr_y_velocity() > 0:
			__log_upd("passed_marker PEAK but still going up - clamping velocity")
			get_player().velocity.y = 0

	# __log_upd(pm().__pp_vel())


# func _in_unhandled_inputput(event):
# 	# VERT_SPEED_BUMP = InputUtils._dev_change_param(event, VERT_SPEED_BUMP, "VERT_SPEED_BUMP",
# 	# 	0.5, "dev_speed_down", RawAction.DEV_speed_up)
# 	VERT_SPEED_BUMP = InputUtils._dev_change_t12_param(event, VERT_SPEED_BUMP, "VERT_SPEED_BUMP", 0.5)
# 	GRAVITY_DURING_JUMP = InputUtils._dev_change_t58_param(event, GRAVITY_DURING_JUMP, "GRAVITY_DURING_JUMP", 0.5)
