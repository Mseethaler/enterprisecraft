extends CanvasLayer

@onready var cash_label = $CashLabel
@onready var alert_label = $AlertLabel
@onready var selection_panel = $SelectionPanel
@onready var selection_name = $SelectionPanel/VBoxContainer/Name
@onready var selection_doctype = $SelectionPanel/VBoxContainer/Doctype
@onready var selection_status = $SelectionPanel/VBoxContainer/Status

func _ready() -> void:
	WorldState.state_updated.connect(_on_state_updated)
	WorldState.alert_added.connect(_on_alert_added)
	selection_panel.hide()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.85)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 4
	style.content_margin_bottom = 25
	selection_panel.add_theme_stylebox_override("panel", style)

func _on_state_updated(module: String) -> void:
	if module == "accounting":
		var cash = WorldState.state["accounting"]["summary"].get("cash_position", 0.0)
		cash_label.text = "Cash: $" + str(snappedf(cash, 0.01))

func _on_alert_added(_alert: Dictionary) -> void:
	var count = WorldState.state["alerts"].size()
	alert_label.text = "Alerts: " + str(count)

func show_selection(doctype: String, docname: String, data: Dictionary) -> void:
	selection_name.text = docname
	selection_doctype.text = doctype
	selection_status.text = data.get("status", "")
	selection_panel.show()

func hide_selection() -> void:
	selection_panel.hide()
