extends RefCountedStaticLogger
# here are all utils which dont have their separate more focused module
class_name TypeCast


## INTERNAL
# region

static func __print_err_msg(item: Variant, array: Array, pp_type_name: String) -> Array:
	__log_warn(pp.s("Array contains non", pp.in_q(pp_type_name), " value:", pp.in_q(item)),
				"TypeCast",
				"return empty array",
				"Input array", pp.array_(array))
	return array


## based on typeof. Needs TYPE enum as type_enum
static func _safe_validate_primitive(array: Array, type_enum: int, type_log_name: String) -> Array:
	for item in array:
		if typeof(item) != type_enum:
			__print_err_msg(item, array, type_log_name)
			return []
	return array


## based on is_instance_of. It also handles inheritance correctly (e.g. subclasses of Area3D)
static func _safe_validate_class(array: Array, type_class: Variant, type_log_name: String, ignore_null: bool = false) -> Array:
	for item in array:
		if item == null and ignore_null:
			continue
		if not is_instance_of(item, type_class):
			__print_err_msg(item, array, type_log_name)
			return []
	return array

#endregion


# region: primitives


static func array_of_string(array: Array[Variant]) -> Array[String]:
	var list_casted: Array[String] = []
	list_casted.assign(_safe_validate_primitive(array, TYPE_STRING, "String"))
	return list_casted


static func array_of_int(array: Array[Variant]) -> Array[int]:
	var list_casted: Array[int] = []
	list_casted.assign(_safe_validate_primitive(array, TYPE_INT, "int"))
	return list_casted


static func array_of_float(array: Array[Variant]) -> Array[float]:
	var list_casted: Array[float] = []
	list_casted.assign(_safe_validate_primitive(array, TYPE_FLOAT, "float"))
	return list_casted


# endregion


# region: built in classes

static func array_of_objects(array: Array, ignore_null: bool = false) -> Array[Object]:
	var list_casted: Array[Object] = []
	list_casted.assign(_safe_validate_class(array, Object, "Object", ignore_null))
	return list_casted


static func array_of_collision_shape(array: Array) -> Array[CollisionShape3D]:
	var list_casted: Array[CollisionShape3D] = []
	list_casted.assign(_safe_validate_class(array, CollisionShape3D, "CollisionShape3D"))
	return list_casted

static func array_of_marker_3d(array: Array) -> Array[Marker3D]:
	var list_casted: Array[Marker3D] = []
	list_casted.assign(_safe_validate_class(array, Marker3D, "Marker3D"))
	return list_casted

static func array_of_world_environment(array: Array) -> Array[WorldEnvironment]:
	var list_casted: Array[WorldEnvironment] = []
	list_casted.assign(_safe_validate_class(array, WorldEnvironment, "WorldEnvironment"))
	return list_casted
	
static func array_of_fog_volume(array: Array) -> Array[FogVolume]:
	var list_casted: Array[FogVolume] = []
	list_casted.assign(_safe_validate_class(array, FogVolume, "FogVolume"))
	return list_casted


static func array_of_directional_light_3d(array: Array) -> Array[DirectionalLight3D]:
	var list_casted: Array[DirectionalLight3D] = []
	list_casted.assign(_safe_validate_class(array, DirectionalLight3D, "DirectionalLight3D"))
	return list_casted


static func array_of_mesh_instances(array: Array) -> Array[MeshInstance3D]:
	var list_casted: Array[MeshInstance3D] = []
	list_casted.assign(_safe_validate_class(array, MeshInstance3D, "MeshInstance3D"))
	return list_casted

static func array_of_audio_stream_player_3d(array: Array) -> Array[AudioStreamPlayer3D]:
	var list_casted: Array[AudioStreamPlayer3D] = []
	list_casted.assign(_safe_validate_class(array, AudioStreamPlayer3D, "AudioStreamPlayer3D"))
	return list_casted


# endregion


# region custom classes


static func array_of_anim_marker(array: Array) -> Array[AnimMarker]:
	var list_casted: Array[AnimMarker] = []
	list_casted.assign(_safe_validate_class(array, AnimMarker, "AnimMarker"))
	return list_casted

static func array_of_audio_track_data(array: Array) -> Array[AudioTrackKey]:
	var list_casted: Array[AudioTrackKey] = []
	list_casted.assign(_safe_validate_class(array, AudioTrackKey, "AudioTrackKey"))
	return list_casted

static func array_of_base_weapon(array: Array) -> Array[BaseWeapon]:
	var list_casted: Array[BaseWeapon] = []
	list_casted.assign(_safe_validate_class(array, BaseWeapon, "BaseWeapon"))
	return list_casted

static func array_of_base_combat(array: Array) -> Array[BaseCombat]:
	var list_casted: Array[BaseCombat] = []
	list_casted.assign(_safe_validate_class(array, BaseCombat, "BaseCombat"))
	return list_casted

static func array_of_char_hit_box(array: Array) -> Array[CharacterHitbox]:
	var list_casted: Array[CharacterHitbox] = []
	list_casted.assign(_safe_validate_class(array, CharacterHitbox, "CharacterHitbox"))
	return list_casted

static func array_of_enemy_camera_target(array: Array) -> Array[EnemyCameraTarget]:
	var list_casted: Array[EnemyCameraTarget] = []
	list_casted.assign(_safe_validate_class(array, EnemyCameraTarget, "EnemyCameraTarget"))
	return list_casted


# endregion


# UI

static func array_of_pause_menu_controller(array: Array) -> Array[M_PauseMenuController]:
	var list_casted: Array[M_PauseMenuController] = []
	list_casted.assign(_safe_validate_class(array, M_PauseMenuController, "M_PauseMenuController"))
	return list_casted


# region: __LOGS


static func pp_name() -> String:
	return "TypeCaster"

static func __LOG_B() -> bool:
	return false

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())

# endregion