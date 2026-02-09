extends ControlSystem
class_name FirstTutorial


@onready var tutorial_ui: TutorialUI = %TutorialUI

@onready var legend: RichTextLabel = %Legend
@onready var _1_controls: RichTextLabel = %"Controls"
@onready var _2_mechanics_overview: RichTextLabel = %"MechanicsOverview"
@onready var _3_attack_mechanic: RichTextLabel = %"AttackMechanic"
@onready var _4_target_lock_mechanic: RichTextLabel = %"TargetLockMechanic"
@onready var _5_health_stamina_mechanic: RichTextLabel = %"HealthStaminaMechanic"
@onready var _6_additional_movement_tips: RichTextLabel = %"AdditionalMovementTips"
@onready var ui_overlay_controls: RichTextLabel = %UIDVMenu


func __hard_dependencies() -> Array:
	return [
		tutorial_ui
	]


func _ready():
	if tutorial_ui:
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
		if ui_overlay_controls:
			tutorial_ui.register_panel(7, ui_overlay_controls)
		
		tutorial_ui.initialise()
	
	if legend:
		legend.show()

	set_tutorial_enable(false)

	__perform_validation(true)
	

func set_tutorial_enable(value: bool):
	if value:
		visible = true
	else:
		visible = false


func _unhandled_input(event: InputEvent) -> void:
	match InputUtils.get_keycode(event):
		KEY_T:
			if GlobalUIInfo.debug_fancy_cam_panel \
				and GlobalUIInfo.debug_fancy_cam_panel.debug_fancy_cam_panel_manager \
				and GlobalUIInfo.debug_fancy_cam_panel.debug_fancy_cam_panel_manager.is_panel_visible():
				return
			set_tutorial_enable(not visible)
			get_viewport().set_input_as_handled()
