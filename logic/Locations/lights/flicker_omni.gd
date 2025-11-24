extends Node3D

@export var radius: float = 3.6
@export var attenuation: float = 2.5
@export var energy: float = 3.8
@export var volumetric_fog_energy: float = 1.0

@export var __csg: bool= true

@onready var omni_light_3d: OmniLight3D = %OmniLight3D
@onready var animation_player: AnimationPlayer = $OmniLight3D/AnimationPlayer
@onready var csg_sphere_3d: CSGSphere3D = $OmniLight3D/CSGSphere3D


func _ready():
	omni_light_3d.omni_range = radius
	omni_light_3d.omni_attenuation = attenuation
	omni_light_3d.light_energy = energy
	omni_light_3d.light_volumetric_fog_energy = volumetric_fog_energy
	animation_player.play("flicker")
	
	csg_sphere_3d.visible = __csg
	
		
