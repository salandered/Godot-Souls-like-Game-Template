extends CharacterBody3D
class_name SECharacter

@export_group("Player")
@export var player: Princess


@export_group("SE params")
@export var pursuit_speed: float = 3
@export var follow_speed: float = 1.5
@export var backtrack_speed: float = 3

@export var sight_distance: float = 25.0
@export var fight_distance: float = 8.0
@export var hearing_distance: float = 5.0
@export var attack_distance: float = 2.2

@export var sight_angle_degrees: float = 45.0 # total FOV

@export var animator: SEAnimator
@export var awareness: EnemyAwareness
@export var right_weapon: BaseWeapon
@export var resources: EnemyResources
@onready var container = $StatesContainer as SEStatesContainer
@onready var traits_container: TraitsContainer = $TraitsContainer


@export var raw_traits_resource: EnemyTraitsResource

var spawn_point: Vector3

const CURRENT = "_current"
const CURRENT_NEW_ITER = "_current_new_iter"

var current_state: BaseSEState


func _ready():
	collision_layer = Collision.Layers.OTHER_CHAR_COL
	collision_mask = Collision.Mask.OTHER_CHAR_COL_MASK
	container.me = self
	spawn_point = global_position
	traits_container.accept_traits()
	container.accept_states()
	current_state = container.states["idle"]
	switch_to("idle")
	

func _physics_process(delta):
	var verdict = current_state._check_transition(delta)
	if not verdict == CURRENT and not verdict == CURRENT_NEW_ITER:
		switch_to(verdict)
	player.dev_labels._label_enemy_info(self)
	current_state._update(delta)


func switch_to(state: String):
	print_.prefix(">SE", current_state.state_name + " -> " + state)
	current_state._on_exit_state()
	current_state = container.states[state]
	current_state._on_enter_state()
