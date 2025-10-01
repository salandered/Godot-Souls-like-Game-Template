extends Resource
class_name PlayerActionData

var state_name: String
var action_name: String
var anim_id: String

func _init(
		state_name_: String,
		action_name_: String,
		anim_id_: String,
	) -> void:
	self.state_name = state_name_
	self.action_name = action_name_
	self.anim_id = anim_id_