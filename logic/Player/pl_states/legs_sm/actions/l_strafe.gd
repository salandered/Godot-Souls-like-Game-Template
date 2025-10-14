extends LegsAction


enum StrafeDir {LEFT, RIGHT}
var curr_dir: StrafeDir = StrafeDir.RIGHT


var dir_change_cooldown := DelayTimer.new()
const DIR_CHANGE_COOLDOWN := 0.1

func initialise():
	dir_change_cooldown.initialise(DIR_CHANGE_COOLDOWN)
	SPEED = 1.05


func _update_strafe_direction(input: InputPackage, on_enter: bool = false) -> StrafeDir:
	var intended_orbit = input.orbit_input
	var new_dir = StrafeDir.RIGHT if intended_orbit > 0.0 else StrafeDir.LEFT
	if new_dir != curr_dir or on_enter:
		print_.lsm_action(action_name, pp.s("orb-inp/decison", intended_orbit, new_dir))
	return new_dir


func on_enter_action(_input: InputPackage) -> void:
	var initial_dir = _update_strafe_direction(_input, true)
	curr_dir = initial_dir
	dir_change_cooldown.reset()

func on_exit_action() -> void:
	curr_dir = StrafeDir.RIGHT


func update(input: InputPackage, delta: float) -> void:
	look_at_target(delta)

	strafe_with_input_vector(input, delta, SpeedConfig.new(1, SPEED))
	
	if dir_change_cooldown.update(delta):
		var new_strafe_dir = _update_strafe_direction(input)
		if new_strafe_dir != curr_dir:
			curr_dir = new_strafe_dir
			_change_animate()
			dir_change_cooldown.reset()


## overrides
func animate(): # ▶️
	var blend_time := 0.2

	anim = anim_container.get_by_name(A.strafe_R if curr_dir == StrafeDir.RIGHT else A.strafe_L)
	
	__log_anim(blend_time)
	animator_manager.set_anim_to_play(anim.anim_id, blend_time)


## custom invention of the current action
func _change_animate():
	var time_spent_on_prev_anim = effective_time_spent()
	
	anim = anim_container.get_by_name(A.strafe_R if curr_dir == StrafeDir.RIGHT else A.strafe_L)
	
	var blend_time := 0.1
	var start_offset = time_spent_on_prev_anim
	
	__log_anim(blend_time, start_offset)
	animator_manager.set_anim_to_play(anim.anim_id, blend_time, start_offset)
