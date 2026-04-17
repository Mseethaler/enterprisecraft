extends Node3D

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

const MODULE_BUILDINGS = {
	"selling": "fishing_dock",
	"buying": "harbor",
	"accounting": "treasury",
	"hr": "barracks",
	"projects": "construction_sites",
	"stock": "warehouse"
}

var buildings = {}
var alert_timers = {}

func _ready() -> void:
	spawn_buildings()
	WorldState.state_updated.connect(_on_state_updated)

func _process(delta: float) -> void:
	for building_id in alert_timers.keys():
		alert_timers[building_id] -= delta
		if alert_timers[building_id] <= 0:
			alert_timers.erase(building_id)
			_set_idle(building_id)

func spawn_buildings() -> void:
	var active = WorldState.state["map_config"]["active_buildings"]
	if active.is_empty():
		active = BUILDING_POSITIONS.keys()
	for building_id in active:
		if BUILDING_POSITIONS.has(building_id):
			_spawn_building(building_id)

func _spawn_building(building_id: String) -> void:
	# Wrap in StaticBody3D for raycast collision
	var body = StaticBody3D.new()
	body.name = building_id
	body.set_meta("building_id", building_id)

	var mesh_node = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(8, 10, 8)
	mesh_node.mesh = mesh

	var mat = StandardMaterial3D.new()
	mat.albedo_color = BUILDING_COLORS.get(building_id, Color(0.5, 0.5, 0.5))
	mat.emission_enabled = true
	mat.emission = Color(0, 0, 0)
	mesh_node.material_override = mat

	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(8, 10, 8)
	collision.shape = shape

	body.add_child(mesh_node)
	body.add_child(collision)

	var pos = BUILDING_POSITIONS[building_id]
	body.position = Vector3(pos.x, 5, pos.z)

	add_child(body)
	buildings[building_id] = body
	print("[buildings] spawned: ", building_id)

func _on_state_updated(module: String) -> void:
	var building_id = MODULE_BUILDINGS.get(module, "")
	if building_id != "" and buildings.has(building_id):
		_trigger_alert(building_id)

func _trigger_alert(building_id: String) -> void:
	if not buildings.has(building_id):
		return
	var building = buildings[building_id]
	if building == null:
		return
	var mesh_node = building.get_child(0) as MeshInstance3D
	if mesh_node == null:
		return
	var mat = mesh_node.material_override as StandardMaterial3D
	if mat == null:
		return
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.4, 0.0)
	mat.emission_energy_multiplier = 0.5
	alert_timers[building_id] = 3.0
	print("[buildings] alert: ", building_id)

func _set_idle(building_id: String) -> void:
	if not buildings.has(building_id):
		return
	var building = buildings[building_id]
	if building == null:
		return
	var mesh_node = building.get_child(0) as MeshInstance3D
	if mesh_node == null:
		return
	var mat = mesh_node.material_override as StandardMaterial3D
	if mat == null:
		return
	mat.emission_enabled = false
	mat.emission = Color(0, 0, 0)
	print("[buildings] idle: ", building_id)
