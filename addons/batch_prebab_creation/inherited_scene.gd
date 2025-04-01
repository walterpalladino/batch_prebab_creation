class_name  InheritedScene
	
const NO_PARENT_SAVED = 0x7FFFFFFF
const NAME_INDEX_BITS = 18
const NAME_MASK = (1 << 18) - 1 

const FLAG_ID_IS_PATH = (1 << 30)
const TYPE_INSTANTIATED = 0x7FFFFFFF # 2147483647
const FLAG_INSTANCE_IS_PLACEHOLDER = (1 << 30)
const FLAG_PATH_PROPERTY_IS_NODE = (1 << 30)
const FLAG_PROP_NAME_MASK = FLAG_PATH_PROPERTY_IS_NODE - 1
const FLAG_MASK = (1 << 24) - 1

static func PARENT(id: int) -> int:
	return id

static func OWNER(id: int) -> int:
	return id

static func NAME_INDEX(index: int) -> int:
	return index << NAME_INDEX_BITS

static func INSTANCE(id: int) -> int:
	return id

static func PROPERTIES(count: int) -> int:
	return count

static func GROUPS(count: int) -> int:
	return count

static func IS_PATH(id: int) -> int:
	return id | FLAG_ID_IS_PATH

static func PROP_NAME(id: int) -> int:
	return id

static func PROP_VALUE(id: int) -> int:
	return id

static func to_inherited_scene(scene_name: String, scene: PackedScene) -> PackedScene:

	var _bundled = {
	"names": [scene_name],
	"variants": [scene],
	"node_count": 1,
	"nodes": [
	  PARENT(-1),
	  OWNER(-1),
	  TYPE_INSTANTIATED,
	  NAME_INDEX(0),
	  INSTANCE(-1),
	  PROPERTIES(0),
	  GROUPS(0)
	],
	"conn_count": 0,
	"conns": [],
	"node_paths": [],
	"editable_instances": [],
	"base_scene": 0,
	"version": 3,
	 }
	scene = PackedScene.new()
	scene._bundled = _bundled
	return scene

static func to_inherited_scene_with_material(scene_name: String, scene: PackedScene, material: Material) -> PackedScene :
	
	#var scene_name = scene._bundled["names"][0]
	var _bundled = {
	"names": [scene_name, scene_name, "material_override"],
	"variants": [scene, material],
	"node_count": 2, # size of "nodes" array
	"nodes": [
	  #------------------------
	  PARENT(-1),
	  OWNER(-1),
	  TYPE_INSTANTIATED,
	  NAME_INDEX(0),
	  INSTANCE(-1),
	  PROPERTIES(0),
	  GROUPS(0),
	  #------------------------
	  IS_PATH(PARENT(0)), # node_paths[0]
	  OWNER(-1),
	  TYPE_INSTANTIATED,
	  NAME_INDEX(1),
	  INSTANCE(-1),
	  PROPERTIES(1),
	  PROP_NAME(2), PROP_VALUE(1), # material_override = nodes[1]? variants[1]?
	  GROUPS(0)
	  #------------------------
	],
	"conn_count": 0,
	"conns": [],
	"node_paths": [^"."], # IS_PATH(PARENT(0))
	"editable_instances": [],
	"base_scene": 0,
	"version": 3,
	}
	
	scene = PackedScene.new()
	scene._bundled = _bundled
	return scene
