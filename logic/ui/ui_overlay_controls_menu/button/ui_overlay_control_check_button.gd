extends CheckButton
class_name UIOverlayControlCheckButton


@export var dv_value_type: DevVisualsConfig.ValueType = DevVisualsConfig.ValueType.UNKNOWN
@export var tied_buttons: Array[UIOverlayControlCheckButton] = []
@onready var ui_overlay_control_check_button_sig_wrapper: UIOverlayControlCheckButtonSigWrapper = %UIOverlayControlCheckButtonSigWrapper


func _ready():
	if ui_overlay_control_check_button_sig_wrapper:
		for item: UIOverlayControlCheckButton in tied_buttons:
			SigUtils.safe_connect(item.toggled, _on_tied_button_toggled)


func _on_tied_button_toggled(toggle: bool):
	set_pressed_no_signal(toggle)
	if ui_overlay_control_check_button_sig_wrapper:
		ui_overlay_control_check_button_sig_wrapper._on_parent_toggled(toggle)
