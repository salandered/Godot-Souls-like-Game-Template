extends BaseEnemyCharacter
class_name HSMECharacter


## It's all:
## - SM
## - Base state
## - Root state
@onready var state_machine = %RootHSMState as BaseHSMEState

@export_group("Container Fields")
@export var animator: AnimationPlayer
@export var states_data_repo: GundyrStatesData
@export var resources: HFSMResources
@export var weapons: Array[BaseWeapon]
@onready var container: HSMStatesContainer = $StatesContainer


func get_current_state() -> BaseHSMEState:
	return state_machine.current_state

func react_on_hit(hit_data: HitData) -> void:
	get_current_state()._react_on_hit(hit_data)


func get_player() -> Princess:
	return player


func _ready():
	collision_layer = Collision.Layers.OTHER_CHAR_COL
	collision_mask = Collision.Mask.OTHER_CHAR_COL_MASK

	container.me = self
	container.accept_states()

	state_machine.player = player
	state_machine._on_enter()


func _physics_process(delta):
	state_machine._update(delta)
