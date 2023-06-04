extends Control

func _ready():
	var dir = get_base_images_dir() 
	print(dir)
	get_folders_count(dir)
	var tex = load_external_tex(dir + "Nurse/Nurse.png")
	print(tex)

func get_base_images_dir():
	var base_dir = ""
	if OS.has_feature("editor"):
		var dir = DirAccess.open("res://").get_current_dir()
		base_dir = ProjectSettings.globalize_path(dir)
	else:
		base_dir = OS.get_executable_path().get_base_dir() 
		
	return base_dir + "assets/images/addons/"
	
func get_folders_count(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func load_external_tex(path):
	var image = Image.load_from_file(path)
	var texture = ImageTexture.create_from_image(image)
	return texture
