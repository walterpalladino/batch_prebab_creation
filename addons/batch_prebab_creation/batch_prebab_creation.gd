@tool
extends EditorPlugin

const BatchPrefabImport = preload("./batch_prefab_import.gd")


var import_options_dialog : Control

var models_dir_dialog
var prefabs_dir_dialog
var overwrite_material_dialog


var models_dir : String
var prefabs_dir : String

var overwrite_material : String

var model_extensions : Array[String] = ["fbx", "gltf"]
var prefab_extension : String = "tscn"

var models_dir_value : Label
var prefabs_dir_value : Label

var overwrite_existing_prefabs : bool
var overwrite_existing_prefabs_value : CheckBox
var overwrite_material_value : Label

var gltf_option_value : CheckBox
var glb_option_value : CheckBox
var obj_option_value : CheckBox
var fbx_option_value : CheckBox

var status : Label



func _enter_tree() -> void:
	# Initialization of the plugin goes here.

	import_options_dialog = preload("res://addons/batch_prebab_creation/importer_options_dialog.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, import_options_dialog)

	models_dir_dialog = FileDialog.new()
	models_dir_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	models_dir_dialog.access = FileDialog.ACCESS_RESOURCES
	models_dir_dialog.dir_selected.connect(on_ModelsDirDialog_file_selected)
	models_dir_dialog.title = "Choose Models (Origin) folder..."
	
	prefabs_dir_dialog = FileDialog.new()
	prefabs_dir_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	prefabs_dir_dialog.access = FileDialog.ACCESS_RESOURCES
	prefabs_dir_dialog.dir_selected.connect(on_PrefabsDirDialog_file_selected)
	prefabs_dir_dialog.title = "Choose Prefabs (Destination) folder..."

	overwrite_material_dialog = FileDialog.new()
	overwrite_material_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	overwrite_material_dialog.access = FileDialog.ACCESS_RESOURCES
	overwrite_material_dialog.file_selected.connect(on_OverwriteMaterialDialog_file_selected)
	overwrite_material_dialog.canceled.connect(on_OverwriteMaterialDialog_file_canceled)
	overwrite_material_dialog.title = "Choose Overwrite Material..."
	overwrite_material_dialog.add_filter("*.tres", "Material")
	
	var viewport = get_editor_interface().get_base_control()
	
	viewport.add_child(models_dir_dialog)
	viewport.add_child(prefabs_dir_dialog)
	viewport.add_child(overwrite_material_dialog)
	
	import_options_dialog.get_node("VBoxContainer/Actions/Import").connect("pressed", on_import_pressed)
	import_options_dialog.get_node("VBoxContainer/VBoxContainer/models_folder/models_folder_action").connect("pressed", on_models_folder_action_pressed)
	import_options_dialog.get_node("VBoxContainer/VBoxContainer/prefabs_folder/prefab_folder_action").connect("pressed", on_prefabs_folder_action_pressed)
	
	models_dir_value = import_options_dialog.get_node("VBoxContainer/VBoxContainer/models_folder/models_folder_value")
	prefabs_dir_value = import_options_dialog.get_node("VBoxContainer/VBoxContainer/prefabs_folder/prefabs_folder_value")
	
	gltf_option_value = import_options_dialog.get_node("VBoxContainer/VBoxContainer/models_formats/gltf_option")
	glb_option_value = import_options_dialog.get_node("VBoxContainer/VBoxContainer/models_formats/glb_option")
	obj_option_value = import_options_dialog.get_node("VBoxContainer/VBoxContainer/models_formats/obj_option")
	fbx_option_value = import_options_dialog.get_node("VBoxContainer/VBoxContainer/models_formats/fbx_option")

	import_options_dialog.get_node("VBoxContainer/VBoxContainer/overwrite_material/overwrite_material_action").connect("pressed", on_overwrite_material_action_pressed)
	overwrite_material_value = import_options_dialog.get_node("VBoxContainer/VBoxContainer/overwrite_material/overwrite_material_value")
	
	overwrite_existing_prefabs_value = import_options_dialog.get_node("VBoxContainer/VBoxContainer/overwrite_existing_prefabs/overwrite_existing_prefabs_option")
	status = import_options_dialog.get_node("VBoxContainer/status")
	

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.

	remove_control_from_docks(import_options_dialog)
	if import_options_dialog:
		import_options_dialog.queue_free()
	if models_dir_dialog:
		models_dir_dialog.queue_free()
	if prefabs_dir_dialog:
		prefabs_dir_dialog.queue_free()


func on_ModelsDirDialog_file_selected(dir : String):
	models_dir = dir
	models_dir_value.text = dir


func on_PrefabsDirDialog_file_selected(dir : String):
	prefabs_dir = dir
	prefabs_dir_value.text = dir


func on_OverwriteMaterialDialog_file_selected(file : String):
	print(file)
	overwrite_material = file
	overwrite_material_value.text = file
	
	
func on_OverwriteMaterialDialog_file_canceled():
	overwrite_material = ''
	overwrite_material_value.text = '<Overwrite Material>'

	
func on_import_pressed():

	if models_dir.is_empty() || prefabs_dir.is_empty():
		status.set("theme_override_colors/font_color", Color.RED)
		status.text = "Missing folders information"
	else:

		gather_models_format_options()
		
		overwrite_existing_prefabs = overwrite_existing_prefabs_value.button_pressed
		
		if (model_extensions.size() == 0):
			status.set("theme_override_colors/font_color", Color.RED)
			status.text = "Should select at least one model format"
		else:	
			var importer = BatchPrefabImport.new(models_dir, prefabs_dir, model_extensions, prefab_extension, overwrite_material, overwrite_existing_prefabs)
			importer.batch_import()	
			
			status.set("theme_override_colors/font_color", Color.GREEN)
			status.text = "Models processed"

	
func gather_models_format_options():
	
	model_extensions.clear()
	
	if gltf_option_value.button_pressed:
		model_extensions.append("gltf")
	if glb_option_value.button_pressed:
		model_extensions.append("glb")
	if obj_option_value.button_pressed:
		model_extensions.append("obj")
	if fbx_option_value.button_pressed:
		model_extensions.append("fbx")
	
	
func on_models_folder_action_pressed():
	models_dir_dialog.popup_centered(Vector2(600,600))

	
func on_prefabs_folder_action_pressed():
	prefabs_dir_dialog.popup_centered(Vector2(600,600))
		

func on_overwrite_material_action_pressed():
	overwrite_material_dialog.popup_centered(Vector2(600,600))
	
