extends Node3D

# Active units on the map keyed by docname
var units = {}

const COLOR_PENDING = Color(1.0, 1.0, 0.0)
const COLOR_confirmed = Color(0.2, 1.0, 0.2)
const COLOR_ERROR = Color(1.0, 0.1, 0.1)

var pending_units = {}
var shimmer_timers = {}

func _process(delta: float) -> void:
	for docname in shimmer_timers.keys():
		shimmer_timers[docname] += delta
		if units.has(docname):
			var body = units[docname]
			var mesh = body.get_child(0) as MeshInstance3D
			if mesh:
				var mat = mesh.material_override as StandardMaterial3D
				if mat:
					var pulse = (sin(shimmer_timers[docname] * 6.0) + 1.0) / 2.0
					mat.emission_enabled = true
					mat.emission = Color(1.0, 1.0, 0.0) * pulse
					mat.emission_energy_multiplier = 0.8

func set_unit_pending(docname: String) -> void:
	if not units.has(docname):
		return
	pending_units[docname] = true
	shimmer_timers[docname] = 0.0
	print("[units] pending: ", docname)

func set_unit_confirmed(docname: String) -> void:
	if not units.has(docname):
		return
	pending_units.erase(docname)
	shimmer_timers.erase(docname)
	_flash_unit(docname, Color(0.2, 1.0, 0.2), 1.0)
	print("[units] confirmed: ", docname)

func set_unit_error(docname: String) -> void:
	if not units.has(docname):
		return
	pending_units.erase(docname)
	shimmer_timers.erase(docname)
	_flash_unit(docname, Color(1.0, 0.1, 0.1), 1.5)
	print("[units] error: ", docname)

func _flash_unit(docname: String, color: Color, duration: float) -> void:
	if not units.has(docname):
		return
	var body = units[docname]
	var mesh = body.get_child(0) as MeshInstance3D
	if mesh == null:
		return
	var mat = mesh.material_override as StandardMaterial3D
	if mat == null:
		return
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 0.8
	await get_tree().create_timer(duration).timeout
	if not pending_units.has(docname):
		mat.emission_enabled = false
		mat.emission = Color(0, 0, 0)

const UNIT_COLORS = {
	"Lead": Color(0.2, 0.6, 1.0),
	"Opportunity": Color(0.1, 0.9, 0.3),
	"Sales Order": Color(0.9, 0.6, 0.1),
	"Project": Color(0.8, 0.3, 0.8),
	"Task": Color(0.5, 0.8, 0.5),
	"Employee": Color(0.9, 0.7, 0.4)
}

const SPAWN_ZONES = {
	"Lead": Vector3(20, 0, -30),
	"Opportunity": Vector3(25, 0, -25),
	"Sales Order": Vector3(40, 0, 0),
	"Project": Vector3(10, 0, -10),
	"Task": Vector3(10, 0, -10),
	"Employee": Vector3(-20, 0, 20)
}

func _ready() -> void:
	WorldState.state_updated.connect(_on_state_updated)

func _on_state_updated(module: String) -> void:
	match module:
		"selling":
			_sync_leads()
		"projects":
			_sync_projects()
		"hr":
			_sync_employees()

func _sync_leads() -> void:
	var leads = WorldState.state["selling"]["pipeline"].get("leads", [])
	for lead in leads:
		var docname = lead if lead is String else lead.get("name", "")
		if docname == "":
			continue
		if not units.has(docname):
			_spawn_unit(docname, "Lead", {"name": docname})
		else:
			_update_unit(docname, {"name": docname})

func _sync_projects() -> void:
	var projects = WorldState.state["projects"]["active"]
	for project in projects:
		var docname = project if project is String else project.get("name", "")
		if docname == "":
			continue
		if not units.has(docname):
			_spawn_unit(docname, "Project", {"name": docname})
		else:
			_update_unit(docname, {"name": docname})

func _sync_employees() -> void:
	var employees = WorldState.state["hr"]["employees"]
	for emp in employees:
		var docname = emp if emp is String else emp.get("name", "")
		if docname == "":
			continue
		if not units.has(docname):
			_spawn_unit(docname, "Employee", {"name": docname})
		else:
			_update_unit(docname, {"name": docname})

func _spawn_unit(docname: String, doctype: String, data: Dictionary) -> void:
	var body = StaticBody3D.new()
	body.name = docname
	body.set_meta("doctype", doctype)
	body.set_meta("docname", docname)
	body.set_meta("data", data)

	var mesh_node = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = 1.5
	mesh.height = 3.0
	mesh_node.mesh = mesh

	var mat = StandardMaterial3D.new()
	mat.albedo_color = UNIT_COLORS.get(doctype, Color(0.8, 0.8, 0.8))
	mesh_node.material_override = mat

	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 1.5
	collision.shape = shape

	body.add_child(mesh_node)
	body.add_child(collision)

	var base = SPAWN_ZONES.get(doctype, Vector3.ZERO)
	var offset = Vector3(randf_range(-10, 10), 1.5, randf_range(-10, 10))
	body.position = base + offset

	add_child(body)
	units[docname] = body
	print("[units] spawned: ", doctype, " — ", docname)

func _update_unit(docname: String, data: Dictionary) -> void:
	if units.has(docname):
		units[docname].set_meta("data", data)
		print("[units] updated: ", docname)

func despawn_unit(docname: String) -> void:
	if units.has(docname):
		units[docname].queue_free()
		units.erase(docname)
		print("[units] despawned: ", docname)
