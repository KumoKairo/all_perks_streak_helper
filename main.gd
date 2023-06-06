extends Control

const ADDONS_DIR = "assets/images/addons/"
const PORTRAIT_FILE = "Portrait.png"

@export var portraits_grid: GridContainer
@export var addons_area: Control
@export var main_scroll_container: ScrollContainer
@export var addons_grid_container: AddonsGridContainer
@export var killer_portrait_image: TextureRect

var killer_addons = {}
var tier_lines = Array()

func _ready():
	var dir = get_base_images_dir() 
	var folders = get_addon_folders(dir)
	add_killer_portrait_buttons(folders)
	var tiers = $AddonsArea/KillerAndTierList/TierList/Tiers.get_children(false)
	tier_lines.append_array(tiers)
	for tier_line in tier_lines:
		tier_line.receive_dropped_addon.connect(_on_dropped_addon_on_tier_line)
	print(tier_lines)
	
func add_killer_portrait_buttons(folders):
	for folder in folders:
		var dir = DirAccess.open(folder)
		var killer_name = dir.get_current_dir().get_file().substr(4)
		var has_portrait = dir.file_exists(PORTRAIT_FILE)
		if has_portrait:
			var new_button = load("res://killer_portrait_button.tscn").instantiate()
			new_button.set_icon(load_external_tex(folder + "/" + PORTRAIT_FILE))
			new_button.set_killer_name(killer_name)
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
	portraits_grid.hide()
	addons_area.show()
	killer_portrait_image.texture = button.killer_icon
	addons_grid_container.show_addons(killer_addons[button.killer_name])

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

func _on_back_button_pressed():
	portraits_grid.show()
	addons_area.hide() # Replace with function body.

#================
func _on_dropped_addon_on_tier_line(data, tier_line):
	print(tier_line)
	print(data)
