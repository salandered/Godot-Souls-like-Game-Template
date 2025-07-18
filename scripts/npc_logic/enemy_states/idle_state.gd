extends LimboState

@onready var anim_tree = %AnimationTree
# const TO_CHASE := &"TO_CHASE"


func _enter() -> void:
	print("|| NPC entered ", name)
	print("    > target ", agent.target)

func _update(_delta: float) -> void:
	var npc := agent

	npc.apply_gravity(_delta)
	anim_tree.set_movement()
	# Idle just stands for now ->
	# npc.rotate_character()
	# npc.update_direction()
	# npc.free_movement(_delta)

	# evaluate_state()

	npc.move_and_slide()


# func evaluate_state(): ## depending on distance to target, run or walk
# 	if agent.target == agent.default_target:
# 		# as expected
# 		return