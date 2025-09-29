extends Resource
class_name PlayerActionData

var state_name: String
var action_name: String
var animation_name: String
# TODO: blend_time to AnimationData
var blend_time: float

func _init(
		state_name_: String,
		action_name_: String,
		animation_name_: String,
		blend_time_: float = 0.2,
	) -> void:
	self.state_name = state_name_
	self.action_name = action_name_
	self.animation_name = animation_name_
	self.blend_time = blend_time_