extends GridContainer
class_name AddonsGridContainer

func show_addons(addons, save_state):
	while get_child_count() < len(addons):
		var addon = load("res://addon.tscn").instantiate()
		addon.start_drag.connect(_on_addon_start_drag)
		add_child(addon)
		
	for i in range(0, get_child_count()):
		get_child(i).set_addon_info(addons[i])

func _can_drop_data(_at_position, data):
	return true

func _drop_data(_at_position, data):
	data.drag_object.get_parent().remove_child(data.drag_object)
	add_child(data.drag_object)
#	for pooled_addon in addons_pool:
#		if data.addon_name == pooled_addon.addon_info.name and not pooled_addon.is_visible_in_tree():
#			pooled_addon.show()

func _on_addon_start_drag(addon):
	pass
	#show_or_hide_addon(addon)
	
func show_or_hide_addon(addon):
	pass
#	for pooled_addon in addons_pool:
#		if addon.addon_info.name == pooled_addon.addon_info.name and pooled_addon.is_visible_in_tree():
#			pooled_addon.hide()
#			break

func unparent_and_give_addons(addon_names):
	var filtered_children = get_children().filter(func(a): return addon_names.has(a.addon_info.name))
	for child in filtered_children:
		remove_child(child)
	return filtered_children
