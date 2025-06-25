extends CharacterBody3D

var SPEED = 2

@onready var sprite_3d: Sprite3D = $Sprite3D

@onready var player: PlayerController = $"../../IAMEllipse"

#@onready var player = get_tree().get_first_nodes_in_group("Player")[0]
@onready var bt_player: BTPlayer = $BTPlayer


func move(target_pos, delta):
	var dir = Vector3(
		target_pos.x - global_transform.origin.x,
		0,
		target_pos.z - global_transform.origin.z
	).normalized()
	
	velocity.x = dir.x * SPEED
	velocity.z = dir.z * SPEED
	
	update_flip(dir.x)


func fly_away(delta, dir: int):
	velocity.y = 5
	velocity.x = dir

func update_flip(x_dir: float):
	sprite_3d.flip_h = x_dir < 0


func player_is_close() -> bool:
	# it's not good to have player variable in every bird and checking for player every physics frame, 
	# instead I'd use Area3D with "body_entered" signal. Also that would make birds react to 
	# different agents besides player, which makes birds more alive.
	if player == null:
		return false
	var distance = global_transform.origin.distance_to(player.global_transform.origin)
	return distance < 5
	
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if player_is_close():
		# accessing blackboard via node BTPlayer
		bt_player.blackboard.set_var("state", "scared")
		# I looked in to it and if you use DynamicSelector as the root (the one that contains the fly-away) 
		# it will re-evalauate all conditions before continue to run the current node. 
		# Super simple, no need for restart. In fact that is the more correct way of making a selector. 
		# I suppose LimboAI is giving you a more optimised option with the plain Selector.
		bt_player.restart()
	
	move_and_slide()
