extends Node3D
@onready var hips: BoneAttachment3D = %Hips


## A smaller value is smoother/lazier, a larger value is tighter/snappier.
@export var follow_speed: float = 4

func _process(delta: float) -> void:
	var target_position := Vector3(hips.global_position.x, self.global_position.y, hips.global_position.z)
	
	self.global_position = self.global_position.lerp(target_position, follow_speed * delta)

	# self.global_position.y = lerp(self.global_position.y, hips.global_position.y, follow_speed * delta / 8)


# func _input(event):
# 	self.global_position.y = u._dev_change_t34_param(event, self.global_position.y, "self.global_position.y", 0.2)
