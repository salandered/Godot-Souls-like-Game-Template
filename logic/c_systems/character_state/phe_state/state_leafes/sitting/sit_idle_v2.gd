extends BasePHELeaf


var _target_duration: float = 0.0


var ANIM_FREEZED := SITSKA.idle_freezed_v2
var ANIM_USUAL := SITSKA.idle_v2


var _anim_freezed: AnimationData
var _anim_usual: AnimationData


func is_ended() -> bool:
	return works_longer_than(_target_duration)


func initialise() -> void:
	_anim_freezed = anim_container.get_by_anim_id(ANIM_FREEZED)
	_anim_usual = anim_container.get_by_anim_id(ANIM_USUAL)


func on_enter_state() -> void:
	anim = ra.pick_weighted([_anim_freezed, _anim_usual], [0.2, 0.8])
	if not anim:
		anim = _anim_usual

	_target_duration = ra.float_range(5.0, 14.0)
