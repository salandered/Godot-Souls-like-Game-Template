extends VBoxContainer
class_name LogsUIPanel


@onready var signal_info_panel: MarginContainer = %SignalInfoPanel
@onready var sig_info_label: RichTextLabel = %SigInfoLabel
@onready var all_logs_panel: MarginContainer = %AllLogsPanel
@onready var all_logs_label: RichTextLabel = %AllLogsLabel
@onready var error_logs_panel: MarginContainer = %ErrorLogsPanel
@onready var error_logs_label: RichTextLabel = %ErrorLogsLabel
