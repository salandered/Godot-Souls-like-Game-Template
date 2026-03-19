@tool
class_name DVPlayerRootVelocity
extends BaseDevVisualizeVector3


var _animator: PlayerModifierAnimator


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		_animator
	]


func _initialize_implementation_in_game() -> void:
	super._initialize_implementation_in_game()
	
	_animator = Groups.get_first_pl_mod_animator_by_group(self )


func get_target_vector() -> Vector3:
	if not _animator or not _animator.root_animator:
		return Vector3.ZERO
		
	return _animator.root_animator.get_root_velocity(true)
