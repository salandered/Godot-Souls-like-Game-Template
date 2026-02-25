class_name TweenConfig
extends RefCounted


## by default: fast start, smooth slowdown

var trans_type: Tween.TransitionType
var ease_type: Tween.EaseType


func _init(trans_type_: Tween.TransitionType = Tween.TRANS_SINE, ease_type_: Tween.EaseType = Tween.EASE_OUT) -> void:
	self.trans_type = trans_type_
	self.ease_type = ease_type_
