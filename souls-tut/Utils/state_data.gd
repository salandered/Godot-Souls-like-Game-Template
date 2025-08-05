extends Resource
class_name StateData


var state_name: String
var animation_name: String
var backend_animation_name: String

func _init(state_name_: String, animation_name_: String, backend_animation_name_: String = "") -> void:
    self.state_name = state_name_
    self.animation_name = animation_name_
    self.backend_animation_name = backend_animation_name_