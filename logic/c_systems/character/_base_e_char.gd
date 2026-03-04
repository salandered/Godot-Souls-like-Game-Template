@abstract
class_name BaseEnemyCharacter
extends BaseCharacter

@export_group("Player")
@export var player: Princess

var camera_target: EnemyCameraTarget


@onready var coll_collider: CollisionShape3D = %CollCollider


func initialize_base_char_implementation() -> void:
	add_to_group(Groups.Chars.BASE_ENEMY_CHARACTER)
	_initialize_cam_target()
	_initialize_coll_collider()


func _initialize_cam_target() -> void:
	camera_target = CamTargetUtils.initialize_cam_target(self )


func _initialize_coll_collider():
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


func _initialize_look_at_systems():
	_look_at_manager = ArrayUtils.get_only_one_or_null(get_descendants.look_at_manager(self ))
	var _target_marker := player.get_look_at_char_marker() if player else null
	if _look_at_manager and _target_marker:
		_look_at_manager.initialize(_target_marker, get_look_at_char_marker())
	else:
		__log_(em.note, "_look_at_manager won't be initialized", _target_marker, self )


##

var look_at_systems_initialized: bool = false


## used for delayed initialization
func _physics_process(delta: float) -> void:
	if eu.is_editor(): return

	if not look_at_systems_initialized: # bad design, redo
		_initialize_look_at_systems()
		look_at_systems_initialized = true


##
	
func is_player() -> bool:
	return false
