extends Node3D

# Building positions on the map — one per module
const BUILDING_POSITIONS = {
	"treasury": Vector3(-30, 0, -20),
	"fishing_dock": Vector3(20, 0, -30),
	"fulfillment_hall": Vector3(40, 0, 0),
	"mill": Vector3(30, 0, 20),
	"harbor": Vector3(-40, 0, 10),
	"barracks": Vector3(-20, 0, 20),
	"warehouse": Vector3(0, 0, 30),
	"construction_sites": Vector3(10, 0, -10)
}

const BUILDING_COLORS = {
	"treasury": Color(0.8, 0.7, 0.1),
	"fishing_dock": Color(0.1, 0.4, 0.8),
	"fulfillment_hall": Color(0.6, 0.3, 0.1),
	"mill": Color(0.5, 0.5, 0.5),
	"harbor": Color(0.1, 0.2, 0.6),
	"barracks": Color(0.4, 0.2, 0.1),
	"warehouse": Color(0.5, 0.4, 0.2),
	"construction_sites": Color(0.7, 0.5, 0.3)
}

var buildings = {}

func _ready() -> void:
	spawn_buildings()
	WorldState.state_updated.connect(_on_state_updated)

func spawn_buildings() -> void:
	var active = WorldState.state["map_config"]["active_buildings"]
	
	# If no active buildings defined yet, show all
	if active.is_empty():
		active = BUILDING_POSITIONS.keys()
	
	for building_id in active:
		if BUILDING_POSITIONS.has(building_id):
			_spawn_building(building_id)

func _spawn_building(building_id: String) -> void:
	var node = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(8, 10, 8)
	node.mesh = mesh
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = BUILDING_COLORS.get(building_id, Color(0.5, 0.5, 0.5))
	node.material_override = mat
	
	var pos = BUILDING_POSITIONS[building_id]
	node.position = Vector3(pos.x, 5, pos.z)
	node.name = building_id
	
	add_child(node)
	buildings[building_id] = node
	print("[buildings] spawned: ", building_id)

func _on_state_updated(module: String) -> void:
	# Future: update building visual state based on module data
	pass
