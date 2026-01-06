class_name FeelingBarConfig
extends RefCounted


##  Duration (sec) for main bar animation (snappiness). Default: 0.2
var anim_main_bar_dur: float
## Duration (sec) for ghost bar to catch up. Default: 0.8
var ghost_dur: float
##  Delay (sec) before ghost bar starts moving. Default: 0.5
var ghost_delay: float
## Duration (sec) for UI fade out. Default: 1.0
var fadeout_duration: float

var ghost_trans: Tween.TransitionType
var ghost_ease: Tween.EaseType

func _init(
	anim_main_bar_dur_: float = 0.2,
	ghost_dur_: float = 0.8,
	ghost_delay_: float = 0.5,
	fadeout_duration_: float = 1.0,
	ghost_trans_: Tween.TransitionType = Tween.TRANS_QUAD,
	ghost_ease_: Tween.EaseType = Tween.EASE_OUT
) -> void:
	self.anim_main_bar_dur = anim_main_bar_dur_
	self.ghost_dur = ghost_dur_
	self.ghost_delay = ghost_delay_
	self.fadeout_duration = fadeout_duration_
	self.ghost_trans = ghost_trans_
	self.ghost_ease = ghost_ease_
