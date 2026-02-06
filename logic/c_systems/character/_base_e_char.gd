#@tool
#@icon("res://-assets-/x_icons/red/icon_skull.png")

@abstract
class_name BaseEnemyCharacter
extends BaseCharacter

@export_group("Player")
@export var player: Princess

#
var camera_target: EnemyCameraTarget


@onready var coll_collider: CollisionShape3D = %CollCollider


func initialise_base_char_implementation() -> void:
	add_to_group(Groups.Chars.BASE_ENEMY_CHARACTER)
	_initialise_cam_target()
	_initialise_coll_collider()


func _initialise_cam_target() -> void:
	camera_target = CamTargetUtils.initialise_cam_target(self )


func _initialise_coll_collider():
	if coll_collider:
		var original_shape := coll_collider.shape
		if not error_.null_object(original_shape, "CollisionShape3D has no shape!"):
			if original_shape is not CapsuleShape3D:
				__log_warn("shape is not CapsuleShape3D. Not supported")
			else:
				# Duplicate to avoid shared resource issues
				coll_collider.shape = original_shape.duplicate()
	else:
		__log_warn("no coll_collider")


func _initialise_look_at_systems():
	_look_at_manager = ArrayUtils.get_only_one_or_null(get_descendants.look_at_manager(self ))
	var _target_marker := player.get_look_at_char_marker() if player else null
	if _look_at_manager and _target_marker:
		_look_at_manager.initialise(_target_marker, get_look_at_char_marker())
	else:
		__log_(em.note, "_look_at_manager won't be initialised", _target_marker, self )


##

var look_at_systems_initialised: bool = false


## used for delayed initialisation
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if not look_at_systems_initialised:
		_initialise_look_at_systems()
		look_at_systems_initialised = true


##
	
func is_player() -> bool:
	return false
