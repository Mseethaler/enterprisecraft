extends CanvasLayer

@onready var cash_label = $CashLabel
@onready var alert_label = $AlertLabel

func _ready() -> void:
	WorldState.state_updated.connect(_on_state_updated)
	WorldState.alert_added.connect(_on_alert_added)

func _on_state_updated(module: String) -> void:
	if module == "accounting":
		var cash = WorldState.state["accounting"]["summary"].get("cash_position", 0.0)
		cash_label.text = "Cash: $" + str(snappedf(cash, 0.01))

func _on_alert_added(_alert: Dictionary) -> void:
	var count = WorldState.state["alerts"].size()
	alert_label.text = "Alerts: " + str(count)
