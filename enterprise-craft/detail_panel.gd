extends CanvasLayer

@onready var title_label = $VBoxContainer/HBoxContainer/TitleLabel
@onready var close_button = $VBoxContainer/HBoxContainer/CloseButton
@onready var content_label = $VBoxContainer/ScrollContainer/MarginContainer/ContentLabel

var _current_doctype: String = ""
var _current_docname: String = ""

func _ready() -> void:
	hide()
	close_button.pressed.connect(hide)
	
	content_label.bbcode_enabled = true
	content_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	content_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.95)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	$VBoxContainer.add_theme_stylebox_override("panel", style)

func is_panel_open() -> bool:
	return visible

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			hide()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_SPACE:
			if _current_doctype != "" and _current_docname != "":
				DocumentFetcher.fetch(_current_doctype, _current_docname, func(doc):
					open(_current_doctype, _current_docname, doc)
				)
			get_viewport().set_input_as_handled()

func open(doctype: String, docname: String, doc: Dictionary) -> void:
	_current_doctype = doctype
	_current_docname = docname
	title_label.text = "%s — %s" % [doctype, docname]
	content_label.text = _format_document(doc)
	show()
	
	await get_tree().process_frame
	
	var viewport_size = get_viewport().get_visible_rect().size
	var panel_w = viewport_size.x * 0.75
	var panel_h = viewport_size.y * 0.68
	var panel_x = viewport_size.x * 0.125
	var panel_y = viewport_size.y * 0.15
	
	$ColorRect.position = Vector2(panel_x, panel_y)
	$ColorRect.size = Vector2(panel_w, panel_h)
	
	var vbox = $VBoxContainer
	vbox.position = Vector2(panel_x, panel_y)
	vbox.custom_minimum_size = Vector2(panel_w, panel_h)
	vbox.size = Vector2(panel_w, panel_h)
	vbox.clip_contents = true
	
	await get_tree().process_frame
	
	var hbox = $VBoxContainer/HBoxContainer
	var spacer = $VBoxContainer/Control
	var scroll = $VBoxContainer/ScrollContainer
	var used_height = hbox.size.y + spacer.size.y
	var scroll_h = panel_h - used_height
	var scroll_w = panel_w
	
	scroll.size = Vector2(scroll_w, scroll_h)
	scroll.custom_minimum_size = Vector2(scroll_w, scroll_h)
	
	var margin = $VBoxContainer/ScrollContainer/MarginContainer
	var label_w = scroll_w - margin.get_theme_constant("margin_left") - margin.get_theme_constant("margin_right")
	content_label.size = Vector2(label_w, 0)
	
	await get_tree().process_frame
	content_label.custom_minimum_size = Vector2(label_w, content_label.get_content_height())

func _strip_html(text: String) -> String:
	var result = ""
	var inside_tag = false
	for ch in text:
		if ch == "<":
			inside_tag = true
		elif ch == ">":
			inside_tag = false
		elif not inside_tag:
			result += ch
	return result.strip_edges()

func _format_document(doc: Dictionary) -> String:
	var lines = []
	for key in doc.keys():
		var value = doc[key]
		if value == null:
			continue
		if value is String and value == "":
			continue
		if value is int and value == 0:
			continue
		if value is float and value == 0.0:
			continue
		if value is Dictionary or value is Array:
			continue
		var display_value = str(value)
		if value is String and value.contains("<"):
			display_value = _strip_html(value)
		lines.append("[color=gray]%s:[/color] [color=white]%s[/color]" % [key, display_value])
	return "\n".join(lines)
