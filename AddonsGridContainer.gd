extends GridContainer
class_name AddonsGridContainer

signal on_dropped_addon_on_addon

func show_addons(addons, save_state):
	while get_child_count() < len(addons):
		var addon = load("res://addon.tscn").instantiate()
		addon.start_drag.connect(_on_addon_start_drag)
		addon.drop_received.connect(_on_addon_drop_received)
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

func _on_addon_drop_received():
	on_dropped_addon_on_addon.emit()
	
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
	# we are doing it imperatively instead of using .filter to maintain the order of addons
	var filtered_children = Array()
	var children = get_children()
	# N^2 booo you're fired (it's alright, I couldn't find a proper .find() method that takes a predicate
	for addon_name in addon_names:
		for child in children:
			if child.addon_info.name == addon_name:
				filtered_children.append(child)
				
	for child in filtered_children:
		remove_child(child)
	return filtered_children
