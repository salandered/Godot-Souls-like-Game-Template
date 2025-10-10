extends RefCounted
class_name BaseVerdict


var next_state: String
## dev
var _comment: String


func _init(next_state_: String = "", comment_: String = ""):
	self.next_state = next_state_
	self._comment = comment_


func _speak_freely():
	var name_ = get_script().get_global_name()
	if _comment:
		print_.prefix("I, " + name_ + "⚖️", "have something important to say: " + _comment)
