extends RefCounted
class_name BaseVerdict


var next_state: String
## dev
var _comment: String
## not dev! this order because of legacy reasons :( 
	## dont put dev vars in base class i suppose
var _reason: String


func _init(next_state_: String = "", comment_: String = "", reason_: String = ""):
	self.next_state = next_state_
	self._comment = comment_
	self._reason = reason_


func get_reason() -> String:
	return _reason


func reset_next_state():
	next_state = ""


## Deliberately only update_reason and not a set_reason.
## _reason should a log of decisions. 
func update_reason(reason_: String):
	_reason = _reason + " | " + reason_


func _speak_freely():
	var name_: Variant = get_script().get_global_name()
	if _comment:
		print_.dev("I, " + str(name_) + "⚖️", "have something important to say: " + _comment)
