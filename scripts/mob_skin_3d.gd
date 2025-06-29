## A base class for all the mobs. Contains the common core logic.
##
## There is no need to create an instance of this class. It is meant to be
## subclassed by the actual mob classes.[br]
## There's very little common logic in this class; at the moment, the only common 
## piece of functionality is the ability to play animations.
class_name MobSkin3D extends Node3D

## Signal to be dispatched when the animation finishes playing.
signal animation_finished(animation_name: String)

## Plays the animation with the given name. If the animation name doesn't exist, the function silently returns.
func play(_animation_name: String) -> void:
	return
