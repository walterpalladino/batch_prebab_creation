# import_plugin.gd
@tool
extends EditorPlugin

enum Presets { DEFAULT }

func _get_importer_name():
	return "batch_model_prefab"
	
func _get_visible_name():
	return "Model Prefab"

func _get_recognized_extensions():
	return ["mtxt"]
	
func _get_save_extension():
	return "tscn"	

func _get_resource_type():
	return "PackedScene"
	
func _get_priority() -> float:
	return 2
	
func _get_import_order() -> int:
	return 2
	
func _get_import_options(path, preset_index):
	return []

func _get_option_visibility(path, option_name, options):
	return true
	

func _get_preset_name(preset_index):
	match preset_index:
		Presets.DEFAULT:
			return "Default"
		_:
			return "Unknown"
				
func _get_preset_count():
	return Presets.size()

func _import(source_file, save_path, options, r_platform_variants, r_gen_files):
	pass
	
		
