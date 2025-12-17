extends Node


@onready var tutorial_manager = %TutorialOverlay

@onready var legend: MarginContainer = %Legend
@onready var controls: MarginContainer = %Controls
@onready var high_lights: MarginContainer = %HighLights
@onready var additional_movement_tips: MarginContainer = %AdditionalMovementTips

func _ready():
	if legend:
		tutorial_manager.register_panel(0, legend)
	if controls:
		tutorial_manager.register_panel(1, controls)
	if high_lights:
		tutorial_manager.register_panel(2, high_lights)
	if additional_movement_tips:
		tutorial_manager.register_panel(3, additional_movement_tips)
	if legend:
		legend.show()
