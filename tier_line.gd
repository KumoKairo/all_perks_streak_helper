extends ColorRect
class_name TierLine

@export var tier_background_color: Color
@export var tier_letter_color: Color
@export var tier_letter: String

func _ready():
	$TierLetter.color = tier_background_color
	$TierLetter/Label.text = tier_letter
	$TierLetter/Label.add_theme_color_override("font_color", tier_letter_color)

func _can_drop_data(at_position, data):
	print(data)
	return true

func _drop_data(at_position, data):
	print("DROP " + str(data))
