@tool
extends EditorPlugin

#const package_import_dialog_class := preload("./package_import_dialog.gd")
const import_options_dialog = preload("res://addons/batch_prebab_creation/importer_options_dialog.tscn")

var import_options_dialog_instance

#var import_plugin 
#var dialog = preload("res://addons/batch_prebab_creation/importer_options.tscn")

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	#add_tool_menu_item("Batch Prefab Creation...", self.show_importer)
	#import_plugin = preload("import_plugin.gd").new()

	#add_control_to_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_LEFT, toolbar)

	#add_import_plugin(import_plugin)
	#dialog = FileDialog.new()
	import_options_dialog_instance = import_options_dialog.instantiate()
	add_tool_menu_item("Batch Prefab Creation...", self.show_importer)
	
	EditorInterface.get_editor_main_screen().add_child(import_options_dialog_instance)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	#remove_tool_menu_item("Batch Prefab Creation...")
	#remove_control_from_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_LEFT, toolbar)
	#toolbar.free()
	#remove_import_plugin(import_plugin)
	#import_plugin = null
	if import_options_dialog_instance:
		import_options_dialog_instance.queue_free()
	remove_tool_menu_item("Batch Prefab Creation...")
	#dialog.free()

func show_importer():
	#if package_import_dialog != null and package_import_dialog.paused:
	#	package_import_dialog.show_importer_logs()
	#	return
	#package_import_dialog = package_import_dialog_class.new()
	#package_import_dialog.show_importer(self)
	print("show importer here...")
	#add_child(dialog)
	#dialog.popup()
