extends BaseAttackAction


var fade_interpolator := FloatLinearInterpolator.new()
var fade_time: float = 0.4 # how long to fade extra velocity
var extra_speed: float = 0.0

var global_extra_speed := 1.0


func initialise() -> void:
	hit_damage = 9
	blend_time_by_action = {
		Leg.Act.run: 0.4,
		Leg.Act.sprint: 0.4
	}
	start_time_offset = anim.get_marker_time_by_name(Marker.Name_.FROM_RUN, 0.1)


func on_enter_action(input_: InputPackage) -> void:
	match PREV_ACTION:
		Leg.Act.run:
			global_extra_speed = 1
			fade_time = 0.3
		Leg.Act.sprint:
			global_extra_speed = 2
			fade_time = 0.4
	var _inherited_speed := pm().get_curr_velocity_len()
	var rm_start_speed := animator_manager.calculate_animation_start_root_velocity(anim, start_time_offset, true)
	extra_speed = max(0.0, _inherited_speed - rm_start_speed + global_extra_speed)
	fade_interpolator.initialise(1.0, 0.0, fade_time)

	# __log_action_ent(
	# 	"inheritedSp: %.2f, startOffset: %.2f, AnimRMStartSp: %.2f, ExtraSp: %.2f" %
	# 	[_inherited_speed, start_time_offset, rm_start_speed, extra_speed])


func update(input_: InputPackage, delta: float):
	if tracks_input_vector():
		pm().rotate_with_input_vector(input_, delta)
	# pm().move_with_root(delta)
	player_sm.combat.update_is_attacking(weapon_hurts())
	# pm().rotate_with_input_vector(input_, delta)
	_move_with_root(delta)


func _move_with_root(delta: float) -> void:
	var root_vel := animator_manager.get_root_velocity(true, false)
	var fade_factor := fade_interpolator.get_current_value()
	var extra_vel_local := Vector3(0, 0, extra_speed * fade_factor) # Animation +Z
	var final_local_vel := root_vel + extra_vel_local
	
	get_player().velocity = get_player().get_quaternion() * final_local_vel
	
	# if fade_factor > 0.0:
	# 	__log_action(
	# 		"RootVel.z: %.2f, Fade: %.2f, ExtraVel.z: %.2f, FinLocal.z: %.2f, FinalGlSp: %.2f" %
	# 		[root_vel.z, fade_factor, extra_vel_local.z, final_local_vel.z, get_curr_speed()])
	fade_interpolator.update(delta)
