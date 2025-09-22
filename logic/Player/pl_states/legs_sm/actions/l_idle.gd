# anim setting simple
# legs animator - LegsSimple Modifer

# MotionType IDLE


# LegsIdleAction.gd (only if needed)
extends LegsAction

func update(_input: InputPackage, _delta: float) -> void:
	player.velocity = Vector3.ZERO
