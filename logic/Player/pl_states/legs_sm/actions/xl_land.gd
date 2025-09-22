extends LegsAction

# @export var TRANSITION_TIMING: float = 0.20
# var elapsed: float = 0.0

# func on_enter_action(previous_action: LegsAction, input: InputPackage) -> void:
# 	elapsed = 0.0

# func update(input: InputPackage, delta: float) -> void:
# 	elapsed += delta
# 	# Optional settle: keep vertical non-positive
# 	player.velocity.y = minf(0.0, player.velocity.y)
# 	# After this action, RunLegs.update() will continue with idle/run
