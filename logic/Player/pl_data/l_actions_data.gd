extends Resource
class_name LegActionData

var action_name: String
var anim_id: String
var motion_type: String

func _init(
		action_name_: String,
		anim_id_: String,
		motion_type_: String,
	) -> void:
	self.action_name = action_name_
	self.anim_id = anim_id_
	self.motion_type = motion_type_
