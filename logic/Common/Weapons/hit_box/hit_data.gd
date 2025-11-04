extends RefCounted
class_name HitData

var damage: float
var anim_id: String
var weapon: BaseWeapon
# var is_parryable: bool
# var effects: Dictionary


func _init(
	damage_: float,
	weapon_: BaseWeapon,
	anim_id_: String,
	# is_parryable_: bool = false,
	# effects_: Dictionary = {}
) -> void:
	self.damage = damage_
	self.weapon = weapon_
	self.anim_id = anim_id_
	# is_parryable = is_parryable_
	# effects = effects_

func _to_string() -> String:
	return pp.s("HitData dmg", damage, "anim", anim_id, "weapon_name", weapon.weapon_name)
