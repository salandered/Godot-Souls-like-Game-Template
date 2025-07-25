extends CharacterBody3D


@export var input_gatherer: InputGatherer
@export var model: PlayerModel
@export var visuals: PlayerVisuals
@export var camera_mount: Node3D
@export var collider: CollisionShape3D
@onready var camera_focus: Node3D = %CameraFocus
@onready var fancy_camera: FancyCamera = %FancyCamera


func _ready():
	#Print.print_ready(self)
	visuals.accept_model(model)


func _physics_process(delta):
	# CONTROLLER (INPUT)
	var input := input_gatherer.gather_input()
	
	# MODEL (SIMULATION)
	model.update(input, delta)
	
	# VISUALISE (PRESENTATION)
	# Visuals -> follow parent transformations
	
	#input.queue_free() ep 4
