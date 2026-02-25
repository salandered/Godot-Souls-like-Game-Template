extends BasePHELeaf


var _target_duration: float = 0.0


var ANIM_TALK := SITSKA.talking
var ANIM_TALK_W_LEG := SITSKA.talking_w_leg


var _anim_talk: AnimationData
var _anim_talk_w_leg: AnimationData


func initialise() -> void:
	_anim_talk = anim_container.get_by_anim_id(ANIM_TALK)
	_anim_talk_w_leg = anim_container.get_by_anim_id(ANIM_TALK_W_LEG)


func on_enter_state() -> void:
	_target_duration = ra.frange(6.0, 40.0)
	anim = ra.pick_random(_anim_talk, _anim_talk_w_leg)
	__log_ent("Chose anim", anim.anim_id)


func is_ended() -> bool:
	var _r := false
	if works_longer_than(_target_duration):
		return true
	elif time_remaining() < TIME_REMAINING_TO_END:
		return true
	return _r