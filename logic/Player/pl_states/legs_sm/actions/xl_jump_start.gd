extends LegsAction

# @export var VERTICAL_SPEED_ADDED: float = 2.5
# @export var JUMP_TIMING: float = 0.10 # seconds into the clip to add vertical speed
# @export var AIR_HANDOFF: float = 0.44 # seconds into the clip to switch to Air

# var elapsed: float = 0.0
# var impulsed: bool = false

# func on_enter_action(previous_action: LegsAction, input: InputPackage) -> void:
# 	elapsed = 0.0
# 	impulsed = false

# func update(input: InputPackage, delta: float) -> void:
# 	elapsed += delta

# 	if not impulsed and elapsed >= JUMP_TIMING:
# 		player.velocity.y += VERTICAL_SPEED_ADDED
# 		impulsed = true

# 	# After takeoff window, let AirLegs take over (midair steering)
# 	if elapsed >= AIR_HANDOFF:
# 		legs_sm.switch_to(PS.leg_midair_behavior, input)
