extends Resource
class_name PSData


var state_name: String
var priority: int
var legs_behavior_name: String

func _init(
		state_name_: String,
		priority_: int,
		legs_behavior_name_: String
	) -> void:
	self.state_name = state_name_
	self.priority = priority_
	self.legs_behavior_name = legs_behavior_name_
