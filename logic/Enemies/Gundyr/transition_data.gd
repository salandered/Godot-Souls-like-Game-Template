extends Resource
class_name VerdictHSM

## Empty "" means no switching
var target_state: String
## for log purposes
var _comment: String

## VerdictHSM.new() means no needs_switch
func _init(target_state_: String = "", comment_: String = ""):
	_comment = comment_
	target_state = target_state_


func needs_switch() -> bool:
	return target_state != ""