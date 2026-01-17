extends Node
class_name FirstTutorial


@onready var tutorial_ui: TutorialUI = %TutorialUI
@onready var tutorial_labels: VBoxContainer = %TutorialLabels

@onready var first_tutorial_panel: PanelContainer = %FirstTutorialPanel

@onready var legend: MarginContainer = %Legend
@onready var _1_controls: MarginContainer = %"1Controls"
@onready var _2_mechanics_overview: MarginContainer = %"2MechanicsOverview"
@onready var _3_attack_mechanic: MarginContainer = %"3AttackMechanic"
@onready var _4_target_lock_mechanic: MarginContainer = %"4TargetLockMechanic"
@onready var _5_health_stamina_mechanic: MarginContainer = %"5HealthStaminaMechanic"
@onready var _6_additional_movement_tips: MarginContainer = %"6AdditionalMovementTips"

func _ready():
	if _1_controls:
		tutorial_ui.register_panel(1, _1_controls)
	if _2_mechanics_overview:
		tutorial_ui.register_panel(2, _2_mechanics_overview)
	if _3_attack_mechanic:
		tutorial_ui.register_panel(3, _3_attack_mechanic)
	if _4_target_lock_mechanic:
		tutorial_ui.register_panel(4, _4_target_lock_mechanic)
	if _5_health_stamina_mechanic:
		tutorial_ui.register_panel(5, _5_health_stamina_mechanic)
	if _6_additional_movement_tips:
		tutorial_ui.register_panel(6, _6_additional_movement_tips)
	if legend:
		legend.show()

	disable_tutorial()
	
func disable_tutorial():
	tutorial_ui.hide_all()
	first_tutorial_panel.visible = false


func enable_tutorial():
	first_tutorial_panel.visible = true
	legend.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_0:
		if first_tutorial_panel.visible:
			disable_tutorial()
		else:
			enable_tutorial()
