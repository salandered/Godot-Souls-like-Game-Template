extends Node

signal signal_one(first: int)


func _ready():
	signal_one.connect(_on_test_one_arg)
	
	signal_one.emit("abc")
	
	prints("all ok ")
	get_tree().quit()

func _on_test_one_arg(a: String):
	prints(a)
