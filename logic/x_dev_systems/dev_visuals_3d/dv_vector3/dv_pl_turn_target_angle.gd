@tool
class_name DVTurnTargetAngle
extends BaseDevVisualiseVector3

@export var vector_length := 1.5
@export var character: BaseCharacter

var _turn_data: TurnData


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		_turn_data
	]


func _initialise_implementation_in_game() -> void:
	super._initialise_implementation_in_game()
	
	_turn_data = Groups.get_first_leg_turn_by_group(self )


func _conditions_to_visualise() -> bool:
	if not _turn_data or _turn_data.turn_completed:
		reset_visuals()
		return false
	return true


func get_target_vector() -> Vector3:
	if not _turn_data or not character:
		return Vector3.ZERO
		
	var current_forward := character.global_transform.basis * Vector3.BACK
	var remaining_angle := _turn_data.target_angle - _turn_data.accum_rotation
	
	return current_forward.rotated(Vector3.UP, remaining_angle) * vector_length