extends CharacterBody3D
class_name SECharacter

@export_group("Player")
@export var player: CharacterBody3D


@export_group("SE params")
@export var speed: float = 3
@export var return_speed: float = 9

@export var aggro_radius: float = 8
@export var attack_radius: float = 2
@export var deaggro_radius: float = 10
@export var animator: SEAnimator
@export var right_weapon: WeaponOh
@export var resources: EnemyResources
@onready var container = $StatesContainer as SEStatesContainer

var spawn_point: Vector3

const CURRENT = "_current"

var current_state: BaseSEState


func _ready():
	collision_layer = Collision.Layers.OTHER_CHAR_COL
	collision_mask = Collision.Mask.OTHER_CHAR_COL
	
	container.me = self
	spawn_point = global_position
	container.accept_states()
	current_state = container.states["idle"]
	switch_to("idle")


func _physics_process(delta):
	var verdict = current_state.check_transition(delta)
	if not verdict == CURRENT:
		switch_to(verdict)
	current_state._update(delta)


func switch_to(state: String):
	print_.prefix("SE", current_state.state_name + " -> " + state)
	current_state._on_exit_state()
	current_state = container.states[state]
	current_state._on_enter_state()
