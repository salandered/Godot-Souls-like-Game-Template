extends BaseEnemyCharacter
class_name SECharacter


@export_group("SE params")
@export var pursuit_speed: float = 3
@export var follow_speed: float = 1.5
@export var backtrack_speed: float = 3

@export var sight_distance: float = 25.0
@export var fight_distance: float = 8.0
@export var hearing_distance: float = 5.0
@export var attack_distance: float = 2.2

@export var sight_angle_degrees: float = 45.0 # total FOV

@export_group("Systems")
@export var animator: SEAnimator
@export var awareness: EnemyAwareness
@export var right_weapon: BaseWeapon
@export var feelings: EnemyFeelings
@export var combat: SECombat
@onready var container = %StatesContainer as SEStatesContainer
@onready var traits_container: TraitsContainer = %TraitsContainer


@export var raw_traits_resource: EnemyTraitsResource

var spawn_point: Vector3


var current_state: BaseSEState


func get_current_state() -> BaseSEState:
	return current_state

func react_on_hit(hit_data: HitData) -> void:
	current_state.react_on_hit(hit_data)


func _ready():
	collision_layer = Collision.Layers.OTHER_CHAR_COL
	collision_mask = Collision.Mask.OTHER_CHAR_COL_MASK
	
	spawn_point = global_position
	traits_container.accept_traits()
	
	container.me = self
	container.accept_states()
	awareness.me = self
	awareness.initialise()
	feelings.me = self

	current_state = container.state_by_name("idle")
	switch_to(SEState.idle)
	

func _physics_process(delta):
	var verdict = current_state._check_transition(delta)
	if not verdict.is_current():
		switch_to(verdict.next_state)
	player.dev_labels._label_enemy_info(self)
	current_state._update(delta)


func switch_to(state: String):
	print_.se("↪️", current_state.state_name + pp.arr + state)
	current_state._on_exit_state()
	current_state = container.state_by_name(state)
	current_state._on_enter_state()
