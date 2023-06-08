extends ColorRect
class_name TierLine

signal receive_dropped_addon

@export var tier_background_color: Color
@export var tier_letter_color: Color
@export var tier_letter: String

@export var hbox: HBoxContainer

func _ready():
	$TierLetter.color = tier_background_color
	$TierLetter/Label.text = tier_letter
	$TierLetter/Label.add_theme_color_override("font_color", tier_letter_color)

func _can_drop_data(_at_position, data):
	return true

func _drop_data(_at_position, data):
	data.drag_object.get_parent().remove_child(data.drag_object)
	$HBoxContainer.add_child(data.drag_object)
	receive_dropped_addon.emit(data, self)
	
func clear():
	_on_back_button_pressed()

func _on_back_button_pressed():
	for i in range(0, $HBoxContainer.get_child_count()):
		$HBoxContainer.get_child(i).queue_free()

