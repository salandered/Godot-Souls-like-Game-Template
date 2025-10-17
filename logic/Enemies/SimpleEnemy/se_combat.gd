@tool
@icon("res://-assets-/x_misc/x_icons/white/icon_sword.png")
extends Node
class_name SECombat

@onready var me: SECharacter = $".."


func _active_weapon() -> BaseWeapon:
	return me.right_weapon


func set_hit_data(hit_damage, anim_id: String) -> void:
	var hit_data = HitData.new()
	hit_data.initialise(hit_damage, anim_id, _active_weapon())
	_active_weapon()._hit_data = hit_data
	print_.se_fight("SECombat", "set hit data: " + str(hit_data))


func update_is_attacking(is_attacking: bool) -> void:
	_active_weapon().is_attacking = is_attacking


func reset_active_weapon() -> void:
	_active_weapon()._hit_data = null
	_active_weapon().hitbox_ignore_list.clear()
	_active_weapon().is_attacking = false
	
	print_.se_fight("SECombat", "reset active weapon")
