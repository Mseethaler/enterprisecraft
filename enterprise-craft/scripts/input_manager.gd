extends Node

var hud = null
@export var camera: Camera3D
@export var ray_length: float = 1000.0

var _selected_doctype: String = ""
var _selected_docname: String = ""
var _selected_data: Dictionary = {}

signal unit_clicked(doctype: String, docname: String, data: Dictionary, screen_position: Vector2)
signal building_clicked(building_id: String, screen_position: Vector2)

func _ready() -> void:
	hud = get_tree().get_first_node_in_group("hud")
	if camera == null:
		camera = get_tree().get_first_node_in_group("main_camera")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE and _selected_docname != "":
			DocumentFetcher.fetch(_selected_doctype, _selected_docname, func(doc):
				var detail_panel = get_tree().get_first_node_in_group("detail_panel")
				if detail_panel:
					detail_panel.open(_selected_doctype, _selected_docname, doc)
			)
			get_viewport().set_input_as_handled()
			return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_left_click(event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_handle_right_click(event.position)

func _handle_left_click(screen_pos: Vector2) -> void:
	if camera == null:
		return
	var result = _raycast(screen_pos)
	if result:
		var hit = result.collider
		if hit.has_meta("doctype"):
			_selected_doctype = hit.get_meta("doctype")
			_selected_docname = hit.get_meta("docname")
			_selected_data = hit.get_meta("data")
			print("[input] selected: ", _selected_doctype, " — ", _selected_docname)
			if hud:
				hud.show_selection(_selected_doctype, _selected_docname, _selected_data)
		elif hit.has_meta("building_id"):
			var building_id = hit.get_meta("building_id")
			_selected_doctype = "Building"
			_selected_docname = building_id
			_selected_data = {}
			print("[input] building selected: ", building_id)
			if hud:
				hud.show_selection("Building", building_id, {})
		else:
			_clear_selection()
	else:
		_clear_selection()

func _handle_right_click(screen_pos: Vector2) -> void:
	if camera == null:
		print("[input] no camera found")
		return
	var result = _raycast(screen_pos)
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

func _clear_selection() -> void:
	_selected_doctype = ""
	_selected_docname = ""
	_selected_data = {}
	if hud:
		hud.hide_selection()

func _raycast(screen_pos: Vector2) -> Dictionary:
	var space_state = get_viewport().get_world_3d().direct_space_state
	var origin = camera.project_ray_origin(screen_pos)
	var direction = camera.project_ray_normal(screen_pos)
	var end = origin + direction * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	return get_viewport().get_world_3d().direct_space_state.intersect_ray(query)
