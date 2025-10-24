extends BaseEnemyCharacter
class_name PHCharacter


## It's all:
## - SM
## - Base state
## - Root state
@export var state_machine: BasePHState

@export_group("Container Fields")
@export var animator: AnimationPlayer
@export var states_data_repo: GundyrStatesData
@export var phe_feelings: PHEFeelings
@export var weapons: Array[PHWeapon]
@export var active_weapon: PHWeapon
@onready var container: PHContainer = $StatesContainer
@onready var combat: PHCombat = %Combat


func get_current_state() -> BasePHState:
	return state_machine.current_lower_state

func react_on_hit(hit_data: HitData) -> void:
	get_current_state()._react_on_hit(hit_data)


func get_player() -> Princess:
	return player


func _ready():
	collision_layer = Collision.Layers.OTHER_CHAR_COL
	collision_mask = Collision.Mask.OTHER_CHAR_COL_MASK

	container.me = self
	container.accept_states()

	# state_machine.current_state = container.get_state_by_name(PHEState.awaken)
	state_machine._on_enter()


func _physics_process(delta):
	state_machine._update(delta)
	# state_machine.current_state
