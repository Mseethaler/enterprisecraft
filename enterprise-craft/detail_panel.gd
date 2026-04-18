extends CanvasLayer

@onready var title_label = $VBoxContainer/HBoxContainer/TitleLabel
@onready var close_button = $VBoxContainer/HBoxContainer/CloseButton
@onready var content_label = $VBoxContainer/ScrollContainer/ContentLabel

func _ready() -> void:
	hide()
	close_button.pressed.connect(hide)
	content_label.bbcode_enabled = true
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.95)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	$VBoxContainer.add_theme_stylebox_override("panel", style)

func open(doctype: String, docname: String, doc: Dictionary) -> void:
	title_label.text = "%s — %s" % [doctype, docname]
	content_label.text = _format_document(doc)
	show()
	var viewport_size = get_viewport().get_visible_rect().size
	var vbox = $VBoxContainer
	var bg = $ColorRect
	vbox.position = Vector2(viewport_size.x * 0.1, viewport_size.y * 0.1)
	vbox.size = Vector2(viewport_size.x * 0.8, viewport_size.y * 0.8)
	bg.position = vbox.position
	bg.size = vbox.size

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
		lines.append("[color=gray]%s:[/color] %s" % [key, str(value)])
	return "\n".join(lines)
