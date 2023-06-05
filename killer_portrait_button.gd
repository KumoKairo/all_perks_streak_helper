extends MarginContainer
class_name KillerPortraitButtonTemplate

signal pressed
var killer_name
var killer_icon

func set_killer_name(name):
	killer_name = name

func set_icon(icon):
	killer_icon = icon
	$Button.icon = icon

func _on_button_pressed():
	pressed.emit()
