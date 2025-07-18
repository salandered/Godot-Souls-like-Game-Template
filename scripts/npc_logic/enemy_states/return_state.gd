extends LimboState

## Returning to default behaviour (like just go towards spawn place after giving up a chase)

@onready var anim_tree = %AnimationTree
const NOT_DEFAULT_TARGET := &"NOT_DEFAULT_TARGET"
const RETURNED := &"RETURNED"


func _enter() -> void:
	var npc := agent
	print("|| NPC entered ", name)
	npc.target = npc.default_target
	
	
func _update(_delta: float) -> void:
	var npc := agent
	npc.apply_gravity(_delta)
	anim_tree.set_movement()

	npc.rotate_character()
	npc.update_direction()
	npc.free_movement(_delta)
	evaluate_state()

	npc.move_and_slide()

func evaluate_state():
	var npc := agent

	var near = (npc.get_target_distance() < 0.3)
	if near:
		get_root().dispatch(RETURNED)