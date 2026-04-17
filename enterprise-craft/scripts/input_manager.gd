extends Node

@export var camera: Camera3D
@export var ray_length: float = 1000.0

signal unit_clicked(doctype: String, docname: String, data: Dictionary, screen_position: Vector2)
signal building_clicked(building_id: String, screen_position: Vector2)

func _ready() -> void:
	# Find camera automatically if not set
	if camera == null:
		camera = get_tree().get_first_node_in_group("main_camera")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_handle_right_click(event.position)

func _handle_right_click(screen_pos: Vector2) -> void:
	if camera == null:
		print("[input] no camera found")
		return

	var space_state = get_viewport().get_world_3d().direct_space_state
	var origin = camera.project_ray_origin(screen_pos)
	var direction = camera.project_ray_normal(screen_pos)
	var end = origin + direction * ray_length

	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)

	if result:
		var hit = result.collider
		print("[input] hit: ", hit.name)

		if hit.has_meta("doctype"):
			var doctype = hit.get_meta("doctype")
			var docname = hit.get_meta("docname")
			var data = hit.get_meta("data")
			print("[input] unit clicked: ", doctype, " — ", docname)
			emit_signal("unit_clicked", doctype, docname, data, screen_pos)
		else:
			print("[input] building clicked: ", hit.name)
			emit_signal("building_clicked", hit.name, screen_pos)
	else:
		print("[input] no hit")
