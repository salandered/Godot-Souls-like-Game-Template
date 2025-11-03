extends BaseVerdict
class_name VerdictPH


var _switch_on_same: bool = false
var _override_commit: bool = false

func _init(next_state_: String = "", reason_: String = "", switch_on_same_: bool = false, override_commit_: bool = false):
	self.next_state = next_state_
	self._reason = reason_
	self._comment = "-no comment in VerdictPH-"
	set_special_flags(switch_on_same_, override_commit_)


func set_special_flags(switch_on_same_: bool = false, override_commit_: bool = false):
	self._switch_on_same = switch_on_same_
	self._override_commit = override_commit_


func override_commit_raised() -> bool:
	if _override_commit: print_.note(true, "override_commit_raised returns true")
	return _override_commit
	
	
func switch_on_same_raised() -> bool:
	if _switch_on_same: print_.note(true, "_switch_on_same_raised returns true")
	return _switch_on_same


func needs_switch() -> bool:
	var _r: bool = false
	if next_state != "":
		_r = true
	return _r