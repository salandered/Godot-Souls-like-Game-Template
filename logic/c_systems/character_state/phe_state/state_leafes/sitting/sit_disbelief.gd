extends BasePHELeaf


var ANIM_LIGHT := SITSKA.disbelief_light
var ANIM_HARD := SITSKA.disbelief_hard
var ANIM_HEAD_DOWN := SITSKA.head_down


var _anim_light: AnimationData
var _anim_hard: AnimationData
var _anim_head_down: AnimationData


func initialise() -> void:
	_anim_light = anim_container.get_by_anim_id(ANIM_LIGHT)
	_anim_hard = anim_container.get_by_anim_id(ANIM_HARD)
	_anim_head_down = anim_container.get_by_anim_id(ANIM_HEAD_DOWN)


func on_enter_state() -> void:
	anim = ra.pick_random(_anim_light, _anim_hard, _anim_head_down)
	__log_ent("Chose anim", anim.anim_id)
