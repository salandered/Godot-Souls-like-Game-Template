@tool
@icon("res://-assets-/x_misc/x_icons/white/icon_sword.png")
extends BaseCombat
class_name HSMECombat

@onready var me: HSMECharacter = $".."


func get_active_weapon() -> BaseWeapon:
	return me.active_weapon
