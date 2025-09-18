extends Node
class_name RightPlayerWeapon

@onready var specific_weapon: BaseWeapon = %SmithSword


func accept_data(player: Princess):
	# RightPlayerWeapon knows that holder is player. Specific Weapon does not.
	specific_weapon.holder = player # same

	specific_weapon.visible = true
	
	print(specific_weapon.weapon_name)
	print(specific_weapon.holder)
	
	print_.collisions(specific_weapon.weapon_hurt_box)
