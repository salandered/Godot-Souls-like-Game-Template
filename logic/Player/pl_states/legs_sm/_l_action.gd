## Legs_behaviors states have the type called Legs_Actions, and legs_actions are instantiated once and live in a shared pool instead of being a copy per behavior. 
extends BaseAction
class_name LegsAction

var legs_sm: LegsSM

var motion_type: String ## see MotionType

var SPEED: float = 3.0
var TURN_SPEED: float = 2.0
var SPEED_SCALE: float = 1.0

func sync_with_prev_loco_anim(next_anim_correction: float = 0.0) -> float:
	var result_offset = -1
	# NOTE: Action is switched, but animator still treats an anim from prev action as "current" 
	#       (before current action hits set_anim_to_play)
	var prev_anim_progress = animator_manager.get_current_anim_effective_progress()
	var prev_anim = legs_sm.prev_action.anim
	var prev_l_leg_contact = prev_anim.get_marker_by_name(M.MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT)
	var next_l_leg_contact = anim.get_marker_by_name(M.MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT)
	if prev_l_leg_contact and next_l_leg_contact:
		# print("~~prev_l_leg_contact and next_l_leg_contact", prev_l_leg_contact.time, next_l_leg_contact.time)
		result_offset = AnimHelpers.calculate_synced_anim_offset(
			prev_anim_progress,
			prev_anim.duration,
			prev_l_leg_contact.time,
			anim.duration,
			next_l_leg_contact.time + next_anim_correction
		)
	return result_offset

## Not abstract! It can be empty. (double action)
func update(_input: InputPackage, _delta: float):
	pass

func _on_exit_action() -> void:
	legs_sm.prev_action = self
	# print_.lsm_action("", pp.s("prev_action_name is set to ", pp.in_q(curr_action_name)))
	on_exit_action()


## to override
func on_exit_action() -> void:
	pass
	

## can be overriden. 
## Use cases: mute playing animation or using situational blend_time.
func animate(): # ▶️
	__log_anim(default_blend_time, 0.0)
	animator_manager.set_anim_to_play(anim_id, default_blend_time)


func velocity_by_input(input: InputPackage, delta: float) -> Vector3:
	# todo: oh fuck what is this dependency
	return player.model.player_sm.__velocity_by_input(input, delta)


func __log_anim(blend_time, start_time_offset):
	print_.lsm_action_anim(action_name, anim_name, legs_sm.prev_action.action_name, blend_time, start_time_offset)