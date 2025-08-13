# plugin.gd
@tool
extends EditorPlugin

# This is a reference to your context menu script.
var animation_extractor_plugin: EditorContextMenuPlugin

func _enter_tree():
	# Instantiate your context menu plugin from the script.
	# The .new() method creates an instance of the class defined in the script.
	animation_extractor_plugin = preload("res://addons/custom_anim/animation_extractor.gd").new()
	
	# Register the plugin with the editor.
	# The first argument, a slot, is often optional or can be set to 0.
	# We simply pass the instantiated plugin.
	add_context_menu_plugin(0, animation_extractor_plugin)
	
	print("Animation Extractor plugin activated.")

func _exit_tree():
	# Check if the plugin exists before trying to remove it.
	if animation_extractor_plugin:
		# Use remove_context_menu_plugin to unregister it.
		remove_context_menu_plugin(animation_extractor_plugin)
		# Clean up the object instance to free up memory.
		animation_extractor_plugin = null
	
	print("Animation Extractor plugin deactivated.")
