extends RefCounted

# var level_path = "res://level/level.tscn"


# var entrypoint: Entrypoint


# == LOADING
# @onready var loading = ui.get_node("Loading")
# @onready var loading_progress = loading.get_node("Progress")
# @onready var loading_done_timer = loading.get_node("DoneTimer")

# func _process(_delta):
# 	if loading.visible:
# 		var progress = []
# 		var status = ResourceLoader.load_threaded_get_status(level_path, progress)
# 		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
# 			loading_progress.value = progress[0] * 100
# 		elif status == ResourceLoader.THREAD_LOAD_LOADED:
# 			loading_progress.value = 100
# 			set_process(false)
# 			loading_done_timer.start()
# 		else:
# 			print("Error while loading level: " + str(status))
# 			main_ui.show()
# 			loading.hide()

# func _on_loading_done_timer_timeout():
# 	emit_signal("replace_main_scene", ResourceLoader.load_threaded_get(level_path))

# func _on_play_pressed():
# 	print("Play button pressed")
#   TODO: when level wont be preloaded in entrypoint.
#   main_ui.hide()
#   loading.show()
#   ResourceLoader.load_threaded_request(level_path, "", true)

# == WORLD ENV IN MENU
# @onready var world_environment = $WorldEnvironment
# in ready(): Settings.apply_graphics_settings(get_window(), world_environment.environment, self)


# == SSIL

# @onready var ssil_menu = settings_menu.get_node("SSIL")
# @onready var ssil_disabled = ssil_menu.get_node("Disabled")
# @onready var ssil_medium = ssil_menu.get_node("Medium")
# @onready var ssil_high = ssil_menu.get_node("High")
#	if Settings.config_file.get_value("rendering", "ssil_quality") == -1:
	# 	ssil_disabled.button_pressed = true
	# elif Settings.config_file.get_value("rendering", "ssil_quality") == RenderingServer.ENV_SSIL_QUALITY_MEDIUM:
	# 	ssil_medium.button_pressed = true
	# elif Settings.config_file.get_value("rendering", "ssil_quality") == RenderingServer.ENV_SSIL_QUALITY_HIGH:
	# 	ssil_high.button_pressed = true

	# if Settings.config_file.get_value("rendering", "ssil_quality") == -1:
	# 	environment.ssil_enabled = false
	# elif Settings.config_file.get_value("rendering", "ssil_quality") == RenderingServer.ENV_SSIL_QUALITY_MEDIUM:
	# 	environment.ssil_enabled = true
	# 	RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_MEDIUM, false, 0.5, 2, 50, 300)
	# else:
	# 	environment.ssil_enabled = true
	# 	RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_HIGH, true, 0.5, 2, 50, 300)
	# if ssil_disabled.button_pressed:
	# 	Settings.config_file.set_value("rendering", "ssil_quality", -1)
	# elif ssil_medium.button_pressed:
	# 	Settings.config_file.set_value("rendering", "ssil_quality", RenderingServer.ENV_SSIL_QUALITY_MEDIUM)
	# elif ssil_high.button_pressed:
	# 	Settings.config_file.set_value("rendering", "ssil_quality", RenderingServer.ENV_SSIL_QUALITY_HIGH)