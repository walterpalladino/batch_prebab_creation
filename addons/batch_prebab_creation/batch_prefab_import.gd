class_name BatchPrefabImport
#class BatchPrefabImport:
	
	
	
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

#var parent : Node

var models_folder_name : String
var prefabs_folder_name : String



func _init(models_dir : String, prefabs_dir : String, model_extensions : Array[String], prefab_extension : String ):
	
	#self.parent = parent
	self.models_dir = models_dir
	self.prefabs_dir = prefabs_dir
	self.model_extensions = model_extensions
	self.prefab_extension = prefab_extension
	

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
		
		#var thread : Thread = Thread.new()
		#thread.start(Callable(process_file).bind(files[i]))
		#thread.wait_to_finish()
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
		
		check_or_create_path(prefab_path_only)
		
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
		_root_name = _inherits._bundled["names"][0];
	var scene := PackedScene.new();
	scene._bundled = {"base_scene": 0, "conn_count": 0, "conns": [], "editable_instances": [], 
				"names": [_root_name], "node_count": 1, "node_paths": [], 
				"nodes": [-1, -1, 2147483647, 0, -1, 0, 0], 
				"variants": [_inherits], "version": 2};
	return scene;
