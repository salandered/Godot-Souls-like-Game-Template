extends Node
class_name RightEnemyWeapon

# Behaves similar to right_player_weapon. See it for details

@onready var specific_weapon: BaseWeapon = %SmithSword

# func _ready():

@onready var simple_enemy: SECharacter = $"../.."

func accept_model_data():
	specific_weapon.holder = simple_enemy


	assert(specific_weapon.weapon_hurt_box is Area3D, "Weapon is missing an Area3D node named 'WeaponArea'.")
	assert(specific_weapon.weapon_hurt_box.get_child(0), "The 'WeaponArea' must have a CollisionShape3D child.")
	assert(specific_weapon.weapon_handle, "Weapon is missing a node named 'Handle'.")
	
	# --- SETUP ---
		
	specific_weapon.visible = true
	
	
	print(specific_weapon.weapon_name)
	print(specific_weapon.holder)
	
	print_.collisions(specific_weapon.weapon_hurt_box)
