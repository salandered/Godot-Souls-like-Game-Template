@tool

@abstract
class_name FighterArmWeapon
extends BaseWeapon


func initialize_implementation() -> void:
	pass


func is_player() -> bool:
	return false


func validate_visuals():
	pass

## SFX


func _for_init_asp_container() -> BaseWeaponASPConfigContainer:
	return FighterArmASPConfigContainer.new()

func get_sad_container() -> WeaponSADContainer:
	return WeaponSADContainer.new()
