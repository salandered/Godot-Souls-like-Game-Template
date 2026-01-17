@tool
class_name SimpleTargetHitArea
extends CommonArea

@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D


signal SIG_hit(payload: Dictionary[String, Variant])


var cooldown_sig_emit := Cooldown.new(0.2)


var common_area_config := CommonAreaConfig.new(
		MonitorType.SIGNAL,
		true,
		false,
		Collision.Masks.ONLY_WEAPON_AREA,
		false
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
	_emit_signal(hit_data)


func _emit_signal(hit_data: HitData):
	if cooldown_sig_emit.is_cooldown_passed(true, pp_name()):
		cooldown_sig_emit.mark_time()
		u.safe_emit_raw(SIG_hit, {GlobalSignal.payload_damage_field: hit_data.damage if hit_data else 10.0})


##

func _physics_process_implementation(delta: float):
	pass
