extends Node
class_name PlayerWeapon
# expects child weapon node with
# - area3D
# - handle - adjusted to mesh
# - weapon visual mesh - child of handle and adjusted accordingly
# - weapons properties defined
# everything can be called via  specific_weapon

@onready var specific_weapon: BaseWeapon = %SmithSword


# func _ready():


func accept_data(player: Princess):
	# PlayerWeapon knows that holder is player. Specific Weapon does not.
	#specific_weapon.target_attachment = model.bones.right_wrist_marker
	specific_weapon.holder = player # same


	assert(specific_weapon.weapon_hurt_box is Area3D, "Weapon is missing an Area3D node named 'WeaponArea'.")
	assert(specific_weapon.weapon_hurt_box.get_child(0), "The 'WeaponArea' must have a CollisionShape3D child.")
	assert(specific_weapon.weapon_handle, "Weapon is missing a node named 'Handle'.")
	
	# --- SETUP ---
	
	
	specific_weapon.visible = true
	
	
	print(specific_weapon.weapon_name)
	print(specific_weapon.holder)
	
	print_.collisions(specific_weapon.weapon_hurt_box)
