extends LegsAction
@onready var general_skeleton: Skeleton3D = %GeneralSkeleton
@onready var fancy_camera: FancyCamera = %FancyCamera
@onready var camera_focus: Node3D = %CameraFocus


const POSITION_CUTOFF_TIME := 0.5342 + 0.0
const POSITION_FADE_TIME := 0.1 # Smooth blend out

var initial_rotation: Quaternion
var target_angle: float
var accumulated_rotation: float = 0.0
var rotation_complete: bool = false


func on_exit_action() -> void:
	var final_rm_speed = player.velocity.length()
	var turn_data = {"rm_speed": final_rm_speed}

	if not rotation_complete:
		print(u.fr() + "[TURN_180] Exit before complete. Transferring state to next action: acc_rot and target_a.")
		turn_data["turn_completed"] = false
		turn_data["target_angle"] = target_angle
		turn_data["accumulated_rotation"] = accumulated_rotation

	legs_sm.transfer_data.fill(action_name, turn_data)

	var final_rotation = player.quaternion.angle_to(initial_rotation)
	var error_angle = accumulated_rotation - target_angle
	print(u.fr() + " ========= [TURN_EXIT] =========")
	print("accumulated_rotation: %.1f°" % rad_to_deg(accumulated_rotation))
	print("final_rotation: %.1f°" % rad_to_deg(final_rotation))
	print("Target was: %.3f rad (%.1f°)" % [target_angle, rad_to_deg(target_angle)])
	print("Error: %.1f°" % rad_to_deg(error_angle))
	print("Final speed: %.2f" % final_rm_speed)


func on_enter_action(_input: InputPackage) -> void:
	initial_rotation = player.quaternion
	var input_dir := velocity_by_input(_input, 0.016).normalized()
	var current_facing = player.basis.z
	target_angle = current_facing.signed_angle_to(input_dir, Vector3.UP)
	
	target_angle = wrapf(target_angle, -PI, PI)
	
	accumulated_rotation = 0.0
	rotation_complete = false

	print(u.fr() + "========= [TURN_ENTER]  =========")
	print("Target: %.1f°" % rad_to_deg(target_angle))
	print("Input dir: %s (%.1f°)" % [input_dir, rad_to_deg(target_angle)])
	print("Initial rotation: %s" % initial_rotation)


func update(input: InputPackage, delta: float):
	var rotation_delta = animator_manager.get_root_rotation()
	if not rotation_complete:
		# Check if this rotation would overshoot
		if abs(accumulated_rotation + rotation_delta) >= abs(target_angle):
			# Apply only what's needed to reach target
			var remaining_rotation = target_angle - accumulated_rotation
			player.rotate_y(remaining_rotation)
			rotation_complete = true
			print(u.fr() + "[TURN_180] Complete at %.3fs: %.1f°" % [time_spent(), rad_to_deg(target_angle)])
		else:
			# Apply full animation rotation
			player.rotate_y(rotation_delta)
			accumulated_rotation += rotation_delta

	var root_vel = animator_manager.get_root_velocity()
	
	if time_spent() < POSITION_CUTOFF_TIME:
		player.velocity = initial_rotation * root_vel
	else:
		# not rotating at is fine if turn animation has root rotation from the first frame to the last.
		move_with_input_vector(input, delta)

	print(u.fr() + "[TURN_UPDATE] t=%.3f rot_delta=%.4f" % [
		time_spent(),
		rotation_delta,
	])


func animate(): # ▶️
	var blend_time := 0.2
	var start_time_offset := 0.0
	__log_anim(blend_time, start_time_offset)
	animator_manager.set_anim_to_play(anim.anim_id, blend_time, start_time_offset)
