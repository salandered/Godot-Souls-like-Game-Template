extends Combo_

# That is example of hardcoded combo implementation.
# Node structure was:
	# Slash1
	#   - ToSlash2
# Being replaced by ConsecutiveAttack which is parametrised with primary_input, next_attack etc

# @onready var slash_1 = $".." as Slash1State

# const PANIC_CLICK_PREVENTION = 0.1

# func _ready():
# 	triggered_state = "slash_2"


# func is_triggered(input: InputPackage):
# 	if input.actions.has("slash_1") and slash_1.works_longer_than(PANIC_CLICK_PREVENTION):
# 		return true
# 	return false

# region: Slash2ToSlash3
# extends Combo_

# @onready var slash_2 = $".." as Slash2State

# const PANIC_CLICK_PREVENTION = 0.1

# func _ready():
# 	triggered_state = "slash_3"

# func is_triggered(input: InputPackage):
# 	if input.actions.has("slash_1") and slash_2.works_longer_than(PANIC_CLICK_PREVENTION):
# 		return true
# 	return false
# endregion