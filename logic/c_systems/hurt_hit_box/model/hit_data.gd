extends RefCounted
class_name HitData

var damage: float
var anim_id: StringName
var weapon_id: StringName
var anim_global_speed_scale: float
var char_state_name: StringName
var attack_dir: AttackDirection.Dir
# var is_parryable: bool
# var effects: Dictionary


func _init(
	damage_: float,
	weapon_id_: StringName,
	anim_id_: StringName,
	anim_global_speed_scale_: float,
	char_state_name_: StringName,
	attack_dir_: AttackDirection.Dir
) -> void:
	self.damage = damage_
	self.weapon_id = weapon_id_
	self.anim_id = anim_id_
	self.anim_global_speed_scale = anim_global_speed_scale_
	self.char_state_name = char_state_name_
	self.attack_dir = attack_dir_


func _to_string() -> String:
	return pp.s("HitData dmg", damage, "anim", anim_id, "Wpn", weapon_id)
