extends PlayerAction


const ANIM_R: String = A.dodge.dodge_R
const ANIM_L: String = A.dodge.dodge_L

# Speeds are not used by this action (root motion)
# but are required by DualDirection's constructor
const SPEED_R: float = 1.0
const SPEED_L: float = 1.0


var direction: DualDirection


func initialise():
	direction = DualDirection.new(SPEED_R, SPEED_L, ANIM_R, ANIM_L)
	__log_action("hello from initialise" + em.pin)

	blend_time_by_action = {
		Leg.Act.idle_to_sprint: 0.6,
		Leg.Act.run: 0.3,
		Leg.Act.fast_turn_180: 0.2
	}

func _detect_dodge_direction(input_: InputPackage) -> DualDirection.Dir:
	# Right - PRIMARY, Left - SECONDARY
	var _original_dir = input_.detect_strafe_dir()
	var dir = StrafeDir.simplify(_original_dir)
	__log_action_ent("detected dodge dir:", StrafeDir.name_(dir), pp.in_br("from " + StrafeDir.name_(_original_dir)))
	if dir == StrafeDir.E.RIGHT:
		return DualDirection.Dir.PRIMARY
	else:
		return DualDirection.Dir.SECONDARY


func on_enter_action(input_: InputPackage) -> void:
	var _dir = _detect_dodge_direction(input_)
	direction.set_direction(_dir)

func on_exit_action() -> void:
	var final_rm_speed = animator_manager.get_root_velocity().length()
	player_sm.fill_tranfer_data({"rm_speed": final_rm_speed})
	var _alt_sp = get_player().velocity.length()
	__log_action_ext("final_rm_speed/_alt_sp", final_rm_speed, _alt_sp)
	

func animate(): # ▶️
	var blend_time := 0.1
	var start_time_offset = 0.0
	
	anim = anim_container.get_by_name(direction.anim_id)
	
	start_time_offset = anim.get_marker_time_by_name(Marker.Name.FROM_RUN, 0.0)
	
	__log_anim(blend_time, start_time_offset)
	animator_manager.set_anim_to_play(anim.anim_id, blend_time, start_time_offset)
