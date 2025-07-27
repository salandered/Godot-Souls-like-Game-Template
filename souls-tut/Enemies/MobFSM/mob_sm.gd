extends Node

@export var animation_player: AnimationPlayer
@export var character: CharacterBody3D
@export var right_weapon: WeaponOh
@export var resources: EnemyResources

var states: Dictionary # { String : AIState }
var current_state: AIState


func _ready():
	character.spawn_point = character.global_position
	accept_states()
	current_state = states["idle"]
	switch_to("idle")


func _physics_process(delta):
	var verdict = current_state.check_transition(delta)
	if verdict[0]:
		switch_to(verdict[1])
	current_state.update(delta)


func switch_to(next_state_name: String):
	print(current_state.state_name + " -> " + next_state_name)
	current_state.on_exit()
	current_state = states[next_state_name]
	current_state.mark_enter_state()
	current_state.on_enter()
	animation_player.play(current_state.animation)


func accept_states():
	for child in get_children():
		if child is AIState:
			states[child.state_name] = child
			child.animator = animation_player
			child.character = character
			child.player = character.player
			child.spawn_point = character.spawn_point
			child.right_weapon = right_weapon
			child.resources = resources
