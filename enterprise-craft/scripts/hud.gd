extends CanvasLayer

@onready var cash_label = $CashLabel
@onready var alert_label = $AlertLabel
@onready var selection_panel = $SelectionPanel
@onready var selection_name = $SelectionPanel/Name
@onready var selection_doctype = $SelectionPanel/Doctype
@onready var selection_status = $SelectionPanel/Status

func _ready() -> void:
	WorldState.state_updated.connect(_on_state_updated)
	WorldState.alert_added.connect(_on_alert_added)
	selection_panel.hide()

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
