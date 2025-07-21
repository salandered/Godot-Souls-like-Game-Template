extends Combo

@export var root_state: BasePlayerState

@export var panic_click_block: float

@export var primary_input: String
@export var next_attack: String


func _ready():
	triggered_state = next_attack


func is_triggered(input: InputPackage):
	if input.actions.has(primary_input) and root_state.works_longer_than(panic_click_block):
		return true
	return false
