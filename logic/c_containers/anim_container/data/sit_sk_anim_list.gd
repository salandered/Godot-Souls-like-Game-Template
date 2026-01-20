class_name SITSKA
extends BaseCharAnimList


class _lib:
	const _other = "other" + "/"
	const _sitting_p1 = "sitting p1" + "/"
	const _sitting_p2 = "sitting p2" + "/"


## idle
const idle_v1 := _lib._sitting_p2 + "Sit Idle v1"
const idle_active_v1 := _lib._sitting_p2 + "Sit idle v1 active"
const idle_freezed_v2 := _lib._sitting_p1 + "Sit Idle freezed v2"
const idle_v2 := _lib._sitting_p2 + "Sit Idle v2"
const rubbing := _lib._sitting_p1 + "Sit Rubbing Arm"
const talking := _lib._sitting_p1 + "Sit Talking"
const intimidate := _lib._sitting_p2 + "Sit Intimidate"

## one time
const point := _lib._sitting_p1 + "Sit And Pointing"
const clap := _lib._sitting_p2 + "Sit Clap"
const disbelief_light := _lib._sitting_p1 + "Sit Disbelief light"
const disbelief_hard := _lib._sitting_p2 + "Sit Disbelief hard"
const laugh_light := _lib._sitting_p2 + "Sit Laughing light"
const laugh_hard := _lib._sitting_p2 + "Sit Laughing hard"

# other
const sit_attack := _lib._sitting_p2 + "Sit Lower Pistol"
const death := _lib._other + "Standing Death B"

# class react:
# 	const react_from_L := _lib._other + "react large from left"
# 	const react_from_R := _lib._other + "react large from right"
# 	const body_impact := _lib._other + "C-body-impact"


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
	AnimationData.new(intimidate),

	# one time
	AnimationData.new(point),
	AnimationData.new(clap),
	AnimationData.new(disbelief_light),
	AnimationData.new(disbelief_hard),
	AnimationData.new(laugh_hard),
	AnimationData.new(laugh_light),

	## other
	AnimationData.new(sit_attack),
	AnimationData.new(death),
	## react
	# AnimationData.new(react.react_from_L),
	# AnimationData.new(react.react_from_R),
	# AnimationData.new(react.body_impact),

]
