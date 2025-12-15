extends Node3D
class_name FlickerFire

@export var radius: float = 3.6
@export var attenuation: float = 2.5
@export var energy: float = 3.8
@export var volumetric_fog_energy: float = 1.0

@export var speed_scale: float = 1.0
@export var play_sound: bool = true


@export var __csg: bool = false

@onready var omni_light_3d: OmniLight3D = %OmniLight3D
@onready var animation_player: AnimationPlayer = $OmniLight3D/AnimationPlayer
@onready var csg_sphere_3d: CSGSphere3D = $OmniLight3D/CSGSphere3D
@onready var asp_fire: AudioStreamPlayer3D = %Fire

const TORCH = preload("uid://cv6knp2vadwvf")

var asp_config = ASPConfig.new(-0.5, -0.37, 3.0, 12, 2, 0.5, BusID.GAME_SFX, TORCH)

func _ready():
	omni_light_3d.omni_range = radius
	omni_light_3d.omni_attenuation = attenuation
	omni_light_3d.light_energy = energy
	omni_light_3d.light_volumetric_fog_energy = volumetric_fog_energy
	
	if animation_player:
		animation_player.play("flicker", -1, speed_scale)
		animation_player.seek(randf_range(0.0, 3.0), true)
	
	if play_sound and asp_fire:
		asp_config.set_up_asp(asp_fire)
		asp_fire.play()

	csg_sphere_3d.visible = __csg
