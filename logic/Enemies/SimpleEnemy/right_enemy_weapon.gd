extends Node
## Behaves similar to right_player_weapon. See it for details
class_name RightEnemyWeapon

@onready var specific_weapon: BaseWeapon = %SmithSword

# func _ready():

var me: SECharacter

func accept_data(me_: SECharacter):
	me = me_
	# Only context aware properties are set up here
	specific_weapon.holder = me_
	specific_weapon.visible = true
	
	print(specific_weapon.weapon_name)
	print(specific_weapon.holder)
	
	print_.collisions(specific_weapon.weapon_hurt_box)
