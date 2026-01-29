@tool
class_name MonitorPlHitSigArea
extends CommonArea

@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D


signal SIG_hit(payload: Dictionary[String, Variant])


var cooldown_sig_emit := Cooldown.new(0.2)


var common_area_config := CommonAreaConfig.new(
		MonitorType.PROCESS,
		true,
		false,
		Collision.Masks.ONLY_WEAPON_AREA,
		true
	)

func _get_common_area_config() -> CommonAreaConfig:
	return common_area_config


func _get_coll_shape() -> CollisionShape3D:
	return collision_shape_3d


## _READY
# region

func _ready_implementation() -> void:
	pass


func _ready_implementation_non_editor() -> void:
	pass

# endregion


# MONITOR HANDLERS
# region 

var _player_found_this_frame := false


var last_processed_hit_data_id: int


func on_area_entered(incoming_area: Area3D) -> void:
	if not incoming_area is WeaponHurtBox:
		return

	var _weapon_area := incoming_area as WeaponHurtBox
	var weapon: BaseWeapon = _weapon_area.my_weapon
	if not weapon:
		__log_error("weapon is null", "on_area_contact", "return")
		return
	if not weapon.is_attacking():
		return
	if not weapon.is_player():
		return
	var hit_data := weapon.get_hit_data()
	if not hit_data:
		__log_error("weapon hit data is null", "on_area_contact", "return")
		return
	if last_processed_hit_data_id != hit_data.get_instance_id():
		_emit_signal(hit_data)


func _emit_signal(hit_data: HitData):
	if not hit_data:
		return
	if cooldown_sig_emit.is_cooldown_passed(false, pp_name()):
		cooldown_sig_emit.mark_time()
		last_processed_hit_data_id = hit_data.get_instance_id()
		SigUtils.safe_emit_raw(SIG_hit, {GlobalSignal.payload_hit_data_field: hit_data})


##

func _physics_process_implementation(delta: float):
	pass
