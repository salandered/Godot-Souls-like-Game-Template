class_name SITSKA
extends BaseCharAnimList


class _lib:
	const _other = "other" + "/"
	const _sitting_p1 = "sitting p1" + "/"
	const _sitting_p2 = "sitting p2" + "/"
	const _sitting_p3 = "sitting p3" + "/"


## idle
const idle_v1: StringName = _lib._sitting_p2 + "Sit Idle v1"
const idle_active_v1: StringName = _lib._sitting_p2 + "Sit idle v1 active"
const idle_freezed_v2: StringName = _lib._sitting_p1 + "Sit Idle freezed v2"
const idle_v2: StringName = _lib._sitting_p2 + "Sit Idle v2"
const rubbing: StringName = _lib._sitting_p1 + "Sit Rubbing Arm"
const talking: StringName = _lib._sitting_p1 + "Sit Talking"
const talking_w_leg: StringName = _lib._sitting_p3 + "Sitting Talking"
const intimidate: StringName = _lib._sitting_p2 + "Sit Intimidate"

## one time
const point: StringName = _lib._sitting_p1 + "Sit And Pointing"
const clap: StringName = _lib._sitting_p2 + "Sit Clap"
const disbelief_light: StringName = _lib._sitting_p1 + "Sit Disbelief light"
const disbelief_hard: StringName = _lib._sitting_p2 + "Sit Disbelief hard"
const head_down: StringName = _lib._sitting_p3 + "Sitting head down"
const laugh_light: StringName = _lib._sitting_p2 + "Sit Laughing light"
const laugh_hard: StringName = _lib._sitting_p2 + "Sit Laughing hard"
const laugh_super_hard: StringName = _lib._sitting_p3 + "Sitting Laughing super hard"
const cheer: StringName = _lib._sitting_p3 + "Cheering While Sitting"
const disapprove: StringName = _lib._sitting_p3 + "Sitting Disapproval"
const thumb_up: StringName = _lib._sitting_p3 + "Sitting Thumbs Up"

## one time stand
const cheer_stand: StringName = _lib._sitting_p3 + "Fist Pump"
const clap_stand: StringName = _lib._sitting_p3 + "Standing Clap"

# other
const sit_attack: StringName = _lib._sitting_p2 + "Sit Lower Pistol"
const death: StringName = _lib._other + "Standing Death B"

# class react:
# 	const react_from_L :StringName= _lib._other + "react large from left"
# 	const react_from_R :StringName= _lib._other + "react large from right"
# 	const body_impact :StringName= _lib._other + "C-body-impact"


func get_list_of_animations() -> Array[AnimationData]:
	return _list_of_animations


var _list_of_animations: Array[AnimationData] = [
	
	## idle
	AnimationData.new(idle_v1),
	AnimationData.new(idle_active_v1),
	AnimationData.new(idle_freezed_v2),
	AnimationData.new(idle_v2),
	AnimationData.new(rubbing),
	AnimationData.new(talking),
	AnimationData.new(talking_w_leg),
	AnimationData.new(intimidate),

	# one time
	AnimationData.new(point),
	AnimationData.new(clap),
	AnimationData.new(disbelief_light),
	AnimationData.new(disbelief_hard),
	AnimationData.new(head_down),
	AnimationData.new(laugh_light),
	AnimationData.new(laugh_hard),
	AnimationData.new(laugh_super_hard),
	AnimationData.new(cheer),
	AnimationData.new(disapprove),
	AnimationData.new(thumb_up),

	## stand
	AnimationData.new(cheer_stand),
	AnimationData.new(clap_stand),

	## other
	AnimationData.new(sit_attack),
	AnimationData.new(death),
	## react
	# AnimationData.new(react.react_from_L),
	# AnimationData.new(react.react_from_R),
	# AnimationData.new(react.body_impact),

]
