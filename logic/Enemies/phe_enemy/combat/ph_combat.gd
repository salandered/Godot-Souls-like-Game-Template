@tool
@icon("res://-assets-/x_misc/x_icons/white/icon_sword.png")
extends BaseCombat
class_name PHCombat

@onready var me: PHCharacter = $".."


func is_player() -> bool:
	return false


func get_me() -> BaseCharacter:
	return me


func get_combat_name() -> String:
	return "Enemy Combat"


func get_active_weapon() -> BaseWeapon:
	return me.active_weapon
