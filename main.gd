extends Control

const ADDONS_DIR = "assets/images/addons/"
const PORTRAIT_FILE = "Portrait.png"

@export var portraits_grid: GridContainer
@export var addons_area: Control
@export var addons_grid_container: AddonsGridContainer
@export var killer_portrait_image: TextureRect
@export var crop_screenshit_area: Control

var killer_addons = {}
var current_killer_name: String

var killers_and_addons_data = {}
var tier_lines = {}

func _ready():
	var dir = get_base_images_dir() 
	var folders = get_addon_folders(dir)
	add_killer_portrait_buttons(folders)
	for tier_line in $AddonsArea/KillerAndTierList/TierList/Tiers.get_children():
		tier_line.receive_dropped_addon.connect(apply_current_addons_data)
		
	for tier in $AddonsArea/KillerAndTierList/TierList/Tiers.get_children():
		tier_lines[tier.name] = tier
		
func add_killer_portrait_buttons(folders):
	for folder in folders:
		var dir = DirAccess.open(folder)
		var ordered_killer_name = dir.get_current_dir().get_file()
		var killer_name = ordered_killer_name.substr(4)
		var has_portrait = dir.file_exists(PORTRAIT_FILE)
		if has_portrait:
			var new_button = load("res://killer_portrait_button.tscn").instantiate()
			new_button.set_icon(load_external_tex(folder + "/" + PORTRAIT_FILE))
			new_button.set_killer_name(killer_name, ordered_killer_name)
			new_button.pressed.connect(_on_killer_button_pressed.bind(new_button))
			portraits_grid.add_child(new_button)
			init_addons_for_killer(killer_name, dir)

func init_addons_for_killer(killer_name, dir: DirAccess):
	killer_addons[killer_name] = Array()
	dir.list_dir_begin()
	var dir_path = dir.get_current_dir() + "/"
	var file_name = dir.get_next()
	while file_name != "":
		if file_name != PORTRAIT_FILE and not file_name.ends_with(".import"):
			var full_path = dir_path + file_name
			var addon_texture = load_external_tex(full_path)
			killer_addons[killer_name].push_back({"texture": addon_texture, "name": file_name})
		file_name = dir.get_next()

func _on_killer_button_pressed(button):
	current_killer_name = button.killer_ordered_name
	portraits_grid.hide()
	addons_area.show()
	killer_portrait_image.texture = button.killer_icon
	
	if not killers_and_addons_data.has(current_killer_name):
		killers_and_addons_data[current_killer_name] = {}
	
	addons_grid_container.show_addons(killer_addons[button.killer_name], killers_and_addons_data[current_killer_name])
	for tier_line in tier_lines:
			if killers_and_addons_data[current_killer_name].has(tier_line):
				var addons = addons_grid_container.unparent_and_give_addons(killers_and_addons_data[current_killer_name][tier_line])
				for a in addons:
					tier_lines[tier_line].hbox.add_child(a)
					

func get_base_images_dir():
	var base_dir = ""
	if OS.has_feature("editor"):
		var dir = DirAccess.open("res://").get_current_dir()
		base_dir = ProjectSettings.globalize_path(dir)
	else:
		base_dir = OS.get_executable_path().get_base_dir() 
		
	return base_dir + ADDONS_DIR
	
func get_addon_folders(path):
	var paths = Array()
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				paths.push_back(path + file_name)
			file_name = dir.get_next()
	return paths

func load_external_tex(path):
	var image = Image.load_from_file(path)
	var texture = ImageTexture.create_from_image(image)
	return texture
	
func apply_current_addons_data(data, tier_line):
	var tier_lines_parent = $AddonsArea/KillerAndTierList/TierList/Tiers
	
	killers_and_addons_data[current_killer_name] = {
		"S": tier_lines_parent.get_node("S/HBoxContainer").get_children().map(get_addon_name),
		"A": tier_lines_parent.get_node("A/HBoxContainer").get_children().map(get_addon_name),
		"B": tier_lines_parent.get_node("B/HBoxContainer").get_children().map(get_addon_name),
		"C": tier_lines_parent.get_node("C/HBoxContainer").get_children().map(get_addon_name),
		"D": tier_lines_parent.get_node("D/HBoxContainer").get_children().map(get_addon_name),
		"F": tier_lines_parent.get_node("F/HBoxContainer").get_children().map(get_addon_name)
	}

func _on_back_button_pressed():
	current_killer_name = ""
	portraits_grid.show()
	addons_area.hide()
	
func get_addon_name(a):
	return a.addon_info.name

func _on_save_pressed():
	var save_data = JSON.stringify(killers_and_addons_data)
	var file = FileAccess.open("save.json", FileAccess.WRITE)
	file.store_string(save_data)
	file.close()
	$PopupMessage.show_text("Saved everything to 'save.json' file. Back it up just in case")

func _on_load_pressed():
	pass

func _on_share_pressed():
	var crop_top_left = crop_screenshit_area.get_rect().position
	var crop_size = crop_screenshit_area.get_rect().size
	var image = get_viewport().get_texture().get_image().get_region(Rect2i(crop_top_left, crop_size))
	image.save_png(current_killer_name + ".png")
	$PopupMessage.show_text("Saved current tierlist image to '%s.png'" % current_killer_name)
