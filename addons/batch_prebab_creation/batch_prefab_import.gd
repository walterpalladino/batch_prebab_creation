class_name BatchPrefabImport
	
	
#	Information related to the file to process
class FileInformation:

	var name : String
	var extension : String
	var partial_path : String
	var full_file_name_with_path : String

	func _init(name, extension, partial_path, full_file_name_with_path ):
		self.name = name
		self.extension = extension
		self.partial_path = partial_path
		self.full_file_name_with_path = full_file_name_with_path



var files : Array[FileInformation] = []

var models_dir : String
var prefabs_dir : String
var model_extensions : Array[String]
var prefab_extension : String


var models_folder_name : String
var prefabs_folder_name : String

var overwrite_material : String
var overwrite_existing_prefabs : bool


func _init(models_dir : String, prefabs_dir : String, model_extensions : Array[String], prefab_extension : String, overwrite_material : String, overwrite_existing_prefabs : bool):
	
	self.models_dir = models_dir
	self.prefabs_dir = prefabs_dir
	self.model_extensions = model_extensions
	self.prefab_extension = prefab_extension
	
	self.overwrite_material = overwrite_material
	self.overwrite_existing_prefabs = overwrite_existing_prefabs


func batch_import():
	
	files.clear()
	
	models_folder_name = models_dir.trim_prefix("res://")
	prefabs_folder_name = prefabs_dir.trim_prefix("res://")

	read_folder_content(models_dir)
	#list_files_to_process()	#	Debuging purpose
	process_file_list()
	
	#	Refresh FilesSystem dock  
	EditorInterface.get_resource_filesystem().scan()
	


func list_files_to_process():
	print("-----------------")
	if files.size() == 0:
		print("No files to be processed")
	else:
		for i in files.size():
			print("[" + str(i) + "] " + files[i].full_file_name_with_path)
	print("-----------------")



func read_folder_content(path) -> int:

	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				read_folder_content(path + "/" + file_name)
			else:

				if model_extensions.has( file_name.get_extension().to_lower() ):
					
					var partial_path = path.trim_prefix("res://")
					partial_path = partial_path.trim_prefix(models_folder_name)
					partial_path = partial_path.trim_prefix("/")
					
					var fileInformation : FileInformation = FileInformation.new(file_name.get_basename(), file_name.get_extension().to_lower(), partial_path, path + "/" + file_name )
					
					files.append( fileInformation )
			
			file_name = dir.get_next()
			
		return 0
	else:
		print("An error occurred when trying to access the path.")
		return 1


func process_file_list():

	if files.size() == 0:
		print("No files to be processed")

	for i in files.size():
		process_file(files[i])


func process_file(file : FileInformation) -> int:
		
	var model_path = file.full_file_name_with_path
	
	var prefab_path = "res://" + prefabs_folder_name + "/" + file.partial_path + "/" + file.name + "." + prefab_extension
	var prefab_path_only = "res://" + prefabs_folder_name + "/" + file.partial_path 
	
	var prefab : PackedScene = await load(model_path)
	if prefab == null:
		print("Error: Model could not be loaded")
		return 2
	else:

		if check_prefab_exists(prefab_path) && !overwrite_existing_prefabs:
			#	File ignored
			return 0
		
		check_or_create_path(prefab_path_only)
		
		#	Update materials
		if overwrite_material:
			#print("overwrite material : " + file.name)
			var material = await ResourceLoader.load(overwrite_material)
			if !material:
				print("Error: Material could not be loaded : " + overwrite_material)
				return 10
			prefab = overwrite_materials(prefab, material)
		else:
			prefab = create_inherited_scene(prefab)

		var error_code = ResourceSaver.save(prefab, prefab_path, ResourceSaver.FLAG_CHANGE_PATH)
		if error_code != OK:
			print("An error occurred while saving the scene to disk.")
			print(error_code)
			return 3

		return 0
		
					
func check_or_create_path(path:String) -> int:
	
	var dir = DirAccess.open(path)
	
	if !dir:
		#	If the path do not exists should be created
		#print("Path should be created")
		var error_code = DirAccess.make_dir_recursive_absolute(path) 
		if error_code != OK:
			#print(error_code)
			print("Error: Folder could not be created. " + path)
			return 4
		else:
			#	Refresh folders in editor after running
			EditorInterface.get_resource_filesystem().scan()
			return 0
	else:
		#	Path already exists
		return 0



#	https://github.com/godotengine/godot-proposals/issues/3907
func create_inherited_scene(_inherits: PackedScene, _root_name: String = "") -> PackedScene:
	
	if(_root_name == ""):
		_root_name = _inherits._bundled["names"][0]
	var scene := PackedScene.new();
	scene._bundled = {
				"base_scene": 0, 
				"conn_count": 0, 
				"conns": [], 
				"editable_instances": [], 
				"names": [_root_name], 
				"node_count": 1, 
				"node_paths": [], 
				"nodes": [-1, -1, 2147483647, 0, -1, 0, 0], 
				"variants": [_inherits], 
				"version": 3};
	return scene;



func overwrite_materials(prefab : PackedScene, material : Material) -> PackedScene:
	print("Overwrite Material")
	
	var root = prefab.instantiate()
	root = overwrite_materials_in_node(root, material)
	
	var mod_prefab = PackedScene.new()
	mod_prefab.pack(root)
	
	return mod_prefab


func overwrite_materials_in_node(node : Node, material : Material) -> Node:

	for child in node.get_children():
		child = overwrite_materials_in_node(child, material)

	if node is MeshInstance3D:
		node.set_surface_override_material(0, material)
		
	return node
	
	
func check_prefab_exists(prefab_path : String):
	return FileAccess.file_exists(prefab_path)
