@tool
class_name DevVisualiseCharHitBoxes
extends VisualiseCollShapes


@export_group("Visuals Colors")
@export var color_vulnerable := Color(1, 0, 0, 0.25)
@export var color_invincible := Color(0, 1, 0, 0.50)

@export_group("Combat")
@export var combat: BaseCombat

var _shapes: Array[CollisionShape3D] = []
var _last_invincible_state: bool = false


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		combat
		]


func _initialise_shapes() -> void:
	if not combat:
		return

	for item in combat._hit_boxes:
		if item is CharacterHitbox:
			_shapes.append(item._get_collision_shape())
			
	# NOTE: should be called after self initalisation
	# _update_color(true)


func _get_initial_color() -> Color:
	return color_vulnerable


func _get_shapes() -> Array[CollisionShape3D]:
	return _shapes


func _process_visualisation(_delta: float) -> void:
	## every frame obviously
	_update_color()


func _update_color() -> void:
	var current_invincible = _is_invincible()
	
	if current_invincible != _last_invincible_state:
		var target = color_invincible if current_invincible else color_vulnerable
		_set_visuals_color(target)
		_last_invincible_state = current_invincible


func _is_invincible() -> bool:
	if not combat: return false
	var character_ := combat.get_character()
	return character_.is_invincible() if character_ else false


func _conditions_to_visualise() -> bool:
	return true


func _on_SIG_dvc_value_changed_section_char_dv_imp(payload: SigPayloadParser.DVValueChangedSectionCharDVPayload) -> void:
	__log_("_on_SIG_dvc_value_changed_section_char_dv_imp", payload)
	if payload.char_dv_type == DVS.CharDVType.HITBOX:
		__log_("_on_SIG_dvc_value_changed_section_char_dv_imp", payload)
		set_enabled(payload.value)
