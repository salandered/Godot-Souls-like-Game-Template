extends CharacterBody3D
class_name Spell


var caster: CharacterBody3D
var spell_name: String

var hitbox_ignore_list: Array[Area3D]


func _ready():
	collision_layer = Collision.Layers.WEAPON_AREA
	collision_mask = Collision.Mask.WEAPON_AREA_MASK
	
	# if not hitbox_ignore_list:
	# 	hitbox_ignore_list = []
	
	# if not caster:
	# 	print_.error("Spell has no caster assigned. This is a bug.")
	# 	return
	
	# # Initialize the spell with the caster's name
	# spell_name = "Spell of " + caster.name

func get_hit_data() -> SpellHitData:
	print("someone tries to get hit by default Spell")
	return SpellHitData.blank()


func target_contacted(character: CharacterBody3D):
	queue_free()
