extends BaseVerdict
class_name VerdictPH


func _init(next_state_: String = "", reason_: String = "", comment_: String = ""):
	self.next_state = next_state_
	self._reason = reason_
	self._comment = comment_


func needs_switch() -> bool:
	return next_state != ""