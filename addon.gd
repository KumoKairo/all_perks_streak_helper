extends Control
class_name AddonImage

signal start_drag

var addon_info
var drag_preview

func set_addon_info(addon):
	addon_info = addon
	$AddonImage.texture = addon_info.texture
	
func _can_drop_data(_at_position, data):
	return get_parent().get_parent().get_parent().name == "Tiers"
	
func _drop_data(_at_position, data):
	if data.drag_object == self:
		return
	
	if(get_parent().has_node(data.drag_object.get_path())):
		data.drag_object.get_parent().remove_child(data.drag_object)
		get_parent().add_child(data.drag_object)
		
	get_parent().move_child(data.drag_object, get_index())
	
func _get_drag_data(at_position):
	var data = {}
	data["drag_object"] = self
	
	drag_preview = load("res://dragged_addon.tscn").instantiate()
	drag_preview.texture = $AddonImage.texture
	get_node("/root/Control/AddonsArea").add_child(drag_preview)
	
	start_drag.emit(self)
	return data
