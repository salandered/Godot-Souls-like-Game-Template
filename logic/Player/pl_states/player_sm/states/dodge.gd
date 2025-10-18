extends PlayerState


const ANIM_R: String = A.dodge.dodge_R
const ANIM_L: String = A.dodge.dodge_L

# Speeds are not used by this action (root motion)
# but are required by DualDirection's constructor
const SPEED_R: float = 1.0
const SPEED_L: float = 1.0

var curr_direction: DualDirection


func initialise():
	curr_direction = DualDirection.new(SPEED_R, SPEED_L, ANIM_R, ANIM_L)


func check_transition(input_: InputPackage) -> PLVerdict:
	if not player.is_on_floor():
		return PLVerdict.new(PS.midair)

	
	if current_action.time_remaining() <= 0.0:
		var verdict = best_next_state_from_input(input_)
		print_.psm_check_trans(state_name, pp.s("time_remaining < 0.0 => choosing best input"))
		return verdict

	return PLVerdict.new("")


func update(input_: InputPackage, delta: float) -> void:
	# look_at_target(delta)
	# current_action.move_with_root(player, delta)
	pass

# func animate(): # ▶️
# 	var blend_time := 0.1
# 	anim = anim_container.get_by_name(curr_direction.anim_id)
# 	__log_anim(blend_time)
# 	animator_manager.set_anim_to_play(anim.anim_id, blend_time)
