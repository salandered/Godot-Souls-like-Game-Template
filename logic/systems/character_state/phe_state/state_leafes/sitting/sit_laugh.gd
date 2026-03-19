extends BasePHELeaf


var ANIM_LIGHT := SITSKA.laugh_light
var ANIM_HARD := SITSKA.laugh_hard


var _anim_light: AnimationData
var _anim_hard: AnimationData


func initialize() -> void:
	_anim_light = anim_container.get_by_anim_id(ANIM_LIGHT)
	_anim_hard = anim_container.get_by_anim_id(ANIM_HARD)


func on_enter_state() -> void:
	if PREV_LEAF == state_name:
		anim = _anim_hard
	else:
		anim = _anim_light if ra.coinflip() else _anim_hard
	__log_ent("Chose anim", anim.anim_id, "based on PREV_LEAF", PREV_LEAF)
