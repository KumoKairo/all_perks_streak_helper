extends GridContainer

var addons_pool = Array()

func show_addons(addons):
	while len(addons_pool) < len(addons):
		var addon = load("res://addon.tscn").instantiate()
		addons_pool.push_back(addon)
		add_child(addon)
	
	for i in range(0, len(addons)):
		addons_pool[i].set_image(addons[i])

func _can_drop_data(at_position, data):
	print("RIGHT " + str(data))
	return true

func _drop_data(at_position, data):
	print("DROP RIGHT " + str(data))
