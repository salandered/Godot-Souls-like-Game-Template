extends BasePHELeaf


var _target_duration: float = 0.0


var ANIM_USUAL := SITSKA.idle_v1
var ANIM_ACTIVE := SITSKA.idle_active_v1


var _anim_usual: AnimationData
var _anim_active: AnimationData


func initialise() -> void:
	_anim_usual = anim_container.get_by_anim_id(ANIM_USUAL)
	_anim_active = anim_container.get_by_anim_id(ANIM_ACTIVE)
	blend_time.set_specific(0.4)


func on_enter_state() -> void:
	if PREV_LEAF == state_name:
		anim = _anim_active
	else:
		anim = _anim_usual if ra.coinflip else _anim_active
	__log_ent("Chose anim", anim.anim_id, "based on PREV_LEAF and coinflip", PREV_LEAF)

	_target_duration = ra.frange(7.0, 16.0)

func is_ended() -> bool:
	return works_longer_than(_target_duration)
