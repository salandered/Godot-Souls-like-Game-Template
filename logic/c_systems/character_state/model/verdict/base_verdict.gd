extends RefCounted
class_name BaseVerdict


var next_state: StringName
var _reason: String


func _init(next_state_: StringName = "", reason_: String = ""):
	self.next_state = next_state_
	self._reason = reason_


func get_reason() -> String:
	return _reason


func reset_next_state() -> void:
	next_state = ""


## Deliberately only update_reason and not a set_reason.
## _reason should be a log of decisions. 
func update_reason(reason_: String):
	_reason = _reason + " | " + reason_
