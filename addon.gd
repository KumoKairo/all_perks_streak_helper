extends Control

func set_image(image):
	$AddonImage.texture = image
	
func _get_drag_data(at_position):
	var data = {}
	data["some"] = "thing"
	print(at_position)
	return data
