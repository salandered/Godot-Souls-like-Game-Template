extends BasePHEComposite


func initialize() -> void:
	SigUtils.safe_connect(PlayerStats.SIG_dodge_combo_achieved, _on_SIG_dodge_combo_achieved)
	SigUtils.safe_connect(PlayerStats.SIG_power_combo_achieved, _on_SIG_power_combo_achieved)
	SigUtils.safe_connect(PlayerStats.SIG_thrown, _on_SIG_thrown)
	SigUtils.safe_connect(PlayerStats.SIG_player_waved, _on_SIG_player_waved)
	SigUtils.safe_connect(PlayerStats.SIG_plush_launched, _on_SIG_plush_launched)
	SigUtils.safe_connect(PlayerStats.SIG_sitting_skeleton_is_not_happy, _on_SIG_sitting_skeleton_is_not_happy)
	SigUtils.safe_connect(PlayerStats.SIG_simple_target_super_rotate, _on_SIG_simple_target_super_rotate)


var interrupted_state: StringName = Const.EMPTY_SNAME


func _interrup_with_personal_state(state_name_: StringName, n_frames_delay: int, look_at_time: float):
	if interrupted_state != Const.EMPTY_SNAME: return
	await FrameUtils.wait_process_frames(self , n_frames_delay)
	interrupted_state = state_name_
	var lam := me.get_look_at_manager()
	if lam:
		lam.look_for_duration(look_at_time)


func _on_SIG_dodge_combo_achieved():
	_interrup_with_personal_state(SITSKS.Leaf.sit_laugh_super_hard, 0, 14.0)


func _on_SIG_power_combo_achieved():
	if ra.chance(0.3):
		_interrup_with_personal_state(
			ra.pick_random(SITSKS.Leaf.sit_point, SITSKS.Leaf.cheer, SITSKS.Leaf.thumb_up),
			90, 9.0)

func _on_SIG_thrown():
	_interrup_with_personal_state(
		ra.pick_random(SITSKS.Leaf.disapprove, SITSKS.Leaf.sit_laugh_super_hard),
		60, 12.0)

func _on_SIG_player_waved():
	_interrup_with_personal_state(
		ra.pick_random(SITSKS.Leaf.cheer, SITSKS.Leaf.thumb_up),
		60,
		14.0)

func _on_SIG_plush_launched():
	_interrup_with_personal_state(
		ra.pick_random(SITSKS.Leaf.sit_clap,
			SITSKS.Leaf.sit_point,
			SITSKS.Leaf.cheer),
		180, 8.0)

func _on_SIG_sitting_skeleton_is_not_happy():
	_interrup_with_personal_state(
		ra.pick_random(SITSKS.Leaf.sit_intimidate, SITSKS.Leaf.disapprove),
		60,
		8.0)

func _on_SIG_simple_target_super_rotate():
	_interrup_with_personal_state(
		ra.pick_random(SITSKS.Leaf.sit_clap),
		90, 8.0
		)


func get_supported_substates() -> Array[StringName]:
	return [
		## idle
		SITSKS.Leaf.sit_idle_v1,
		SITSKS.Leaf.sit_idle_v2,
		SITSKS.Leaf.sit_talking,
		SITSKS.Leaf.sit_rubbing,
		SITSKS.Leaf.sit_intimidate,
		## one time
		SITSKS.Leaf.sit_point,
		SITSKS.Leaf.sit_clap,
		SITSKS.Leaf.sit_disbelief,
		SITSKS.Leaf.sit_laugh,
		SITSKS.Leaf.sit_laugh_super_hard,
		SITSKS.Leaf.cheer,
		SITSKS.Leaf.disapprove,
		SITSKS.Leaf.thumb_up,
	]


var initial_spick_weighted: Dictionary[StringName, float] = {
	SITSKS.Leaf.sit_idle_v1: 0.4,
	SITSKS.Leaf.sit_idle_v2: 0.1,
	SITSKS.Leaf.sit_intimidate: 0.2,
	SITSKS.Leaf.sit_talking: 0.25,
}


var basic_spick_weighted: Dictionary[StringName, float] = {
	## idle
	SITSKS.Leaf.sit_idle_v1: 0.5,
	SITSKS.Leaf.sit_idle_v2: 0.1,
	SITSKS.Leaf.sit_rubbing: 0.3,
	SITSKS.Leaf.sit_talking: 0.3,
	SITSKS.Leaf.sit_intimidate: 0.1,
	## one time
	SITSKS.Leaf.sit_point: 0.1,
	SITSKS.Leaf.sit_disbelief: 0.1,
	SITSKS.Leaf.sit_laugh: 0.05
}

# var not_happy_spick_weighted: Dictionary[StringName, float] = {
# 	SITSKS.Leaf.sit_intimidate: 0.4,
# }


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: StringName, _reason: String) -> VerdictPH:
	if current_substate.is_ended():
		match current_substate.state_name:
			SITSKS.Leaf.sit_idle_v1, SITSKS.Leaf.sit_idle_v2:
				_next_state = ra.snpick_weighted(basic_spick_weighted)
			_:
				_next_state = ra.snpick_weighted(basic_spick_weighted)

	if interrupted_state != Const.EMPTY_SNAME:
		if current_substate.state_name != interrupted_state:
			_next_state = interrupted_state
		interrupted_state = Const.EMPTY_SNAME


	return VerdictPH.new(_next_state, _reason)


func choose_initial_substate(_next_state: StringName, _reason: String) -> VerdictPH:
	_next_state = ra.snpick_weighted(initial_spick_weighted)
	return VerdictPH.new(SITSKS.Leaf.sit_idle_v1)
