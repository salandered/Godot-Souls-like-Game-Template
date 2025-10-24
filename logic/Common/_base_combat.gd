@tool
@icon("res://-assets-/x_misc/x_icons/white/icon_sword.png")

@abstract
class_name BaseCombat
extends Node


@abstract func get_active_weapon() -> BaseWeapon


func set_hit_data_to_active_weapon(hit_damage, anim_id: String) -> void:
	var _weapon := get_active_weapon()
	var hit_data := HitData.new()
	hit_data.initialise(hit_damage, anim_id, _weapon)
	_weapon.set_hit_data(hit_data)
	__log_combat(_weapon, "set hit data:", str(hit_data))


func update_is_attacking(is_attacking: bool) -> void:
	var _weapon := get_active_weapon()
	_weapon.is_attacking = is_attacking


func reset_active_weapon() -> void:
	var _weapon := get_active_weapon()
	_weapon.reset_hit_data()
	_weapon.hitbox_ignore_list.clear()
	_weapon.is_attacking = false
	__log_combat(_weapon, "reset active weapon")


func __log_combat(_weapon: BaseWeapon, ...parts: Array):
	print_.fight(_weapon.__pp_holder(), pp.list_(parts))