@tool
@icon("res://-assets-/x_misc/x_icons/white/icon_sword.png")
extends BaseCombat
class_name PHECombat

@onready var me: PHCharacter = $".."
@onready var bones: EnemyBones = %bones

var weapons: Dictionary = {} # weapon_name <String> to weapon <PHEWeapon>
var active_weapon: PHEWeapon


func initialise():
	## currently weapons are all under %bones
	var _weapons = get_descendants.base_weapons(bones) as Array[PHEWeapon]
	if len(_weapons) != 2:
		__log_warn("len(weapons) != 2", "initialise", "nothing", len(_weapons))
	for weapon in _weapons:
		weapons[weapon.weapon_name] = weapon


func is_player() -> bool:
	return false


func get_character() -> BaseCharacter:
	return me


func get_combat_name() -> String:
	return "Enemy Combat"


func get_active_weapon() -> PHEWeapon:
	return active_weapon


func set_active_weapon(weapon_name: String):
	var _weapon = u.safe_get_dict_key(weapons, weapon_name, null, Fallback.WARN_CRUCIAL, "set_active_weapon")
	active_weapon = _weapon
