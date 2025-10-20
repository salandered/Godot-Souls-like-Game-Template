@tool
@icon("res://-assets-/x_misc/x_icons/red/icon_sword.png")
extends BaseWeapon
class_name SmithSword

@onready var _weapon_hurt_box: WeaponHurtBox = $WeaponHurtBox
@onready var visuals: Node3D = $Visuals


func _ready():
	## here the specific weapon SmithSword assignes all necessary weapon attributes
	var mesh: MeshInstance3D = visuals.get_child(0)
	assert(mesh and mesh is MeshInstance3D)
	
	weapon_hurt_box = _weapon_hurt_box
	weapon_visuals = mesh
	weapon_name = "smith_sword"
	
	_input_to_state = {
		CombatAction.light_attack_pressed: PS.axe_slice_1,
		CombatAction.light_attack_pressed_when_move: PS.attack_from_run
	}

	super._ready()
