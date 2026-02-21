@tool
class_name M_InputOptionsMenu
extends ControlLogger

const ALREADY_ASSIGNED_TEXT: String = "{key} already assigned to {action}."
const ONE_INPUT_MINIMUM_TEXT: String = "%s must have at least one key or button assigned."
const KEY_DELETION_TEXT: String = "Are you sure you want to remove {key} from {action}?"

@onready var assignment_placeholder_text = %KeyAssignmentDialog.dialog_text
@onready var x_mouse_sense: M_OptionControl = %XMouseSense
@onready var y_mouse_sense: M_OptionControl = %YMouseSense


var last_input_readable_name


func _horizontally_align_popup_labels() -> void:
	%KeyAssignmentDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$KeyDeletionDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$OneInputMinimumDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$AlreadyAssignedDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$ResetConfirmationDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _ready() -> void:
	if u.is_editor(): return
	_update_ui()
	_horizontally_align_popup_labels()


func _update_ui():
	x_mouse_sense.value = M_AppSettings.get_x_sense()
	y_mouse_sense.value = M_AppSettings.get_y_sense()


func _add_action_event() -> void:
	var last_input_event = %KeyAssignmentDialog.last_input_event
	
	last_input_readable_name = %KeyAssignmentDialog.last_input_text
	__log_("InputMenu", "Sending to list -> Name:", last_input_readable_name, "Event:", last_input_event)
	
	%InputActionsList.add_action_event(last_input_readable_name, last_input_event)
	

func _on_reset_button_pressed() -> void:
	$ResetConfirmationDialog.popup_centered()


func _on_key_assignment_dialog_confirmed() -> void:
	__log_("InputMenu", "Dialog confirmed signal received.")
	_add_action_event()

func _open_key_assignment_dialog(action_name: String, readable_input_name: String = assignment_placeholder_text) -> void:
	if not has_node("KeyAssignmentDialog"):
		__log_warn("Node not found", "_open_key_assignment_dialog", "Check scene tree", "%KeyAssignmentDialog missing")
		return

	__log_("InputMenu", "Opening Popup...")
	
	%KeyAssignmentDialog.title = tr("Assign Key for {action}").format({action = action_name})
	%KeyAssignmentDialog.dialog_text = readable_input_name
	%KeyAssignmentDialog.get_ok_button().disabled = true
	%KeyAssignmentDialog.popup_centered()


func _popup_already_assigned(action_name, input_name) -> void:
	$AlreadyAssignedDialog.dialog_text = tr(ALREADY_ASSIGNED_TEXT).format({key = input_name, action = action_name})
	$AlreadyAssignedDialog.popup_centered.call_deferred()

func _popup_minimum_reached(action_name: String) -> void:
	$OneInputMinimumDialog.dialog_text = ONE_INPUT_MINIMUM_TEXT % action_name
	$OneInputMinimumDialog.popup_centered.call_deferred()


func _on_input_actions_list_already_assigned(action_name, input_name) -> void:
	_popup_already_assigned(action_name, input_name)


func _on_input_actions_list_minimum_reached(action_name) -> void:
	_popup_minimum_reached(action_name)


func _on_input_actions_list_button_clicked(action_name, readable_input_name) -> void:
	__log_("InputMenu", "Button clicked for:", action_name, "Current Key:", readable_input_name)
	
	_open_key_assignment_dialog(action_name, readable_input_name)


func _on_reset_confirmation_dialog_confirmed() -> void:
	%InputActionsList.reset()


func _on_x_mouse_sense_setting_changed(value: Variant) -> void:
	M_AppSettings.set_x_sense(value)
