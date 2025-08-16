# anim setting simple
# legs animator - LegsSimple Modifer

# MotionType IDLE


# LegsIdleAction.gd (only if needed)
extends LegsAction

func update(_input: InputPackage, _delta: float) -> void:
	player.velocity = Vector3.ZERO
	# no move_and_slide() here; let Player tick it once if you prefer, or keep it here—just be consistent
