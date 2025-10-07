extends LegsAction


const POSITION_CUTOFF_TIME := 0.5342 + 0.0 # TODO: change to marker

var initial_rotation: Quaternion
var target_angle: float
var accumulated_rotation: float = 0.0
var rotation_complete: bool = false

## TODO: some universal system for different "sub animations" in one action
var turn_direction: String = "right"


func _calculate_target_angle(input: InputPackage) -> float:
	var target_angle_: float
	if input.reverse_data.is_reversed:
		target_angle_ = - PI + 0.05 # wrapf excludes PI so we're consistent with the next branch
		prints("\n\t target ∠:", pp.rad2deg(target_angle_))
		prints("\t Reverse type: %s" % input.reverse_data.type, "Full rev data:", input.reverse_data)
	else: # Use standard input direction
		var _face_dir = player.basis.z
		var _input_dir = velocity_by_input(input, 0.016).normalized()
		var _signed_angle = _face_dir.signed_angle_to(_input_dir, Vector3.UP)
		target_angle_ = wrapf(_signed_angle, -PI, PI)
		prints("\n\t target ∠:", pp.rad2deg(target_angle_), "t ∠ before wrapf", _signed_angle)
		prints("\t _face_dir", _face_dir, "_input_dir", pp.vec3(_input_dir))
	return target_angle_


func on_enter_action(_input: InputPackage) -> void:
	prints(u.fr() + " ========= TURN_ENTER  =========")
	initial_rotation = player.quaternion
	target_angle = _calculate_target_angle(_input)
	var angle_sign = signf(target_angle)
	if angle_sign <= 0:
		turn_direction = "right"
		if angle_sign == 0: print_.warn("Turn angle is zero; defaulting to a 'right' turn.")
	else:
		turn_direction = "left"

	accumulated_rotation = 0.0
	rotation_complete = false

	prints("\t turn decision:", turn_direction)
	prints("\t Initial rotation (quaternion): %s" % initial_rotation)


func on_exit_action() -> void:
	prints(u.fr() + " ========= TURN_EXIT =========")
	var final_rm_speed = player.velocity.length()
	var turn_data = {"rm_speed": final_rm_speed}

	if not rotation_complete:
		turn_data["turn_completed"] = false
		turn_data["target_angle"] = target_angle
		turn_data["accumulated_rotation"] = accumulated_rotation
		prints("\t Exit before complete. Will populate tranfer data")

	legs_sm.transfer_data.fill(action_name, turn_data)

	__log_turn_exit(turn_data)


func update(input: InputPackage, delta: float):
	if not rotation_complete:
		var rotation_delta = animator_manager.get_root_rotation()
		# if abs(rotation_delta) > 0.001:
		# 	print(u.fr(), "  > Animation is rotating by: %.4f" % rotation_delta)
		if abs(accumulated_rotation + rotation_delta) >= abs(target_angle):
			var remaining_rotation = target_angle - accumulated_rotation
			player.rotate_y(remaining_rotation)
			rotation_complete = true
			print(u.fr() + "Turn completed at %.3fs: %.1f°" % [time_spent(), rad_to_deg(target_angle)])
		else:
			player.rotate_y(rotation_delta)
			accumulated_rotation += rotation_delta
			
	if time_spent() < POSITION_CUTOFF_TIME:
		var root_vel = animator_manager.get_root_velocity()
		player.velocity = initial_rotation * root_vel
	else:
		# not rotating is fine if turn animation has root rotation from the first frame to the last.
		move_with_input_vector(input, delta)


func animate(): # ▶️
	var blend_time := 0.2

	if turn_direction == "right":
		anim = anim_container.get_by_name(A.turn_180_R)
	else:
		anim = anim_container.get_by_name(A.turn_180_L)
	
	__log_anim(blend_time, 0.0)
	animator_manager.set_anim_to_play(anim.anim_id, blend_time, 0.0)


func __log_turn_exit(turn_data):
	var _final_rotation = player.quaternion.angle_to(initial_rotation)
	var _error_angle = accumulated_rotation - target_angle
	prints("accum rotation", pp.rad2deg(accumulated_rotation), "fin rotation", pp.rad2deg(_final_rotation))
	prints("Target:", pp.rad2deg(target_angle), "Error:", pp.rad2deg(_error_angle))
	prints("Tranfer data", pp._dict(turn_data))