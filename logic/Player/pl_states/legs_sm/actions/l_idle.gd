extends LegsAction


# MotionType IDLE


func update(_input: InputPackage, _delta: float) -> void:
	player.velocity = Vector3.ZERO
