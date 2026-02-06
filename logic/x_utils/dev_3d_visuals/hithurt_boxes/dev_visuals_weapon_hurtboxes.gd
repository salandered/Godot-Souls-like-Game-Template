@tool
class_name DevVisualiseWeaponHurtBoxes
extends VisualiseCollShapes


@export_group("Visuals Colors")
@export var color_passive := Color(0, 1, 0, 0.50)
@export var color_attacking := Color(1, 0, 0, 0.25)

@export_group("Weapon")
@export var weapon: BaseWeapon

var _shapes: Array[CollisionShape3D] = []
var _last_attacking_state: bool = false


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		weapon
		]


func _initialise_shapes() -> void:
	if not weapon:
		return

	var hb := weapon.get_weapon_hurt_box()
	if hb:
		var col_shapes := get_descendants.collision_shapes(hb)
		_shapes.assign(col_shapes)


func _get_initial_color() -> Color:
	return color_passive


func _get_shapes() -> Array[CollisionShape3D]:
	return _shapes


func _process_visualisation(_delta: float) -> void:
	## every frame obviously
	_update_color()


func _update_color() -> void:
	var current_attacking = _is_attacking()
	
	if current_attacking != _last_attacking_state:
		var target = color_attacking if current_attacking else color_passive
		_set_visuals_color(target)
		_last_attacking_state = current_attacking


func _is_attacking() -> bool:
	if not weapon: return false
	return weapon.is_attacking()


func _conditions_to_visualise() -> bool:
	return true


func _on_SIG_dvc_value_changed_section_char_dv_imp(payload: SigPayloadParser.DVValueChangedSectionCharDVPayload) -> void:
	if payload.char_dv_type == DVS.CharDVType.WEAPON_HITBOX:
		set_enabled(payload.value)
