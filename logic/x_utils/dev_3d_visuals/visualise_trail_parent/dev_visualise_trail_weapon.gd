@tool
class_name DevVisualiseTrailWeapon
extends DevVisualiseTrail


@export_subgroup("Weapon Settings")
@export var only_attacking: bool = true


var _cached_hurtbox: WeaponHurtBox


func __hard_validation() -> bool:
	# validation passes if we found a WeaponHurtBox
	return is_instance_valid(_cached_hurtbox)


func initialise_implementation_both_editor_and_game() -> void:
	super.initialise_implementation_both_editor_and_game()
	
	if _parent_node is WeaponHurtBox:
		_cached_hurtbox = _parent_node as WeaponHurtBox
		
	elif _parent_node is Marker3D:
		var grandparent = _parent_node.get_parent()
		if grandparent is WeaponHurtBox:
			_cached_hurtbox = grandparent as WeaponHurtBox


func _conditions_to_visualise() -> bool:
	## no complex logic if in editor
	if Engine.is_editor_hint():
		return true
		
	if not is_instance_valid(_cached_hurtbox):
		return false

	var weapon := _cached_hurtbox._get_my_weapon()
	if not is_instance_valid(weapon):
		return false
	
	if only_attacking and not weapon.is_attacking():
		return false

	return true
