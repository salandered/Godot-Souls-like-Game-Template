@tool
class_name DVTurnAccumRotation
extends BaseDevVisualizeVector3

@export var vector_length := 1.5
@export var character: BaseCharacter

var _turn_data: TurnData


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		_turn_data
	]


func _initialize_implementation_in_game() -> void:
	super._initialize_implementation_in_game()
	
	_turn_data = Groups.get_first_leg_turn_by_group(self )


func _conditions_to_visualize() -> bool:
	if not _turn_data or _turn_data.turn_completed:
		reset_visuals()
		return false
	return true


func get_target_vector() -> Vector3:
	if not _turn_data or not character:
		return Vector3.ZERO
		
	var current_forward := character.global_transform.basis * Vector3.BACK
	return current_forward * vector_length
