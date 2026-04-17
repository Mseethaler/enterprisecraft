extends Node

# ── World State ───────────────────────────────────────────────────────────────
var state = {
	"meta": {},
	"map_config": {
		"active_buildings": []
	},
	"accounting": {
		"summary": {},
		"bank_transactions": {},
		"chart_of_accounts": []
	},
	"selling": {
		"pipeline": {},
		"orders": {},
		"invoices": {},
		"recent_conversions": []
	},
	"buying": {
		"suppliers": [],
		"purchase_orders": [],
		"invoices": {}
	},
	"hr": {
		"employees": [],
		"summary": {}
	},
	"projects": {
		"active": [],
		"summary": {}
	},
	"stock": {
		"physical": {},
		"time": {}
	},
	"alerts": []
}

# ── Signals ───────────────────────────────────────────────────────────────────
signal state_updated(module: String)
signal alert_added(alert: Dictionary)

# ── Public API ────────────────────────────────────────────────────────────────
func get_module(module: String) -> Dictionary:
	return state.get(module, {})

func update_module(module: String, data: Dictionary) -> void:
	if state.has(module):
		state[module].merge(data, true)
		emit_signal("state_updated", module)

func add_alert(alert: Dictionary) -> void:
	state["alerts"].append(alert)
	emit_signal("alert_added", alert)

func clear_alerts() -> void:
	state["alerts"] = []

func get_employee(email: String) -> Dictionary:
	for emp in state["hr"]["employees"]:
		if emp.get("name") == email:
			return emp
	return {}

func get_project(doc_name: String) -> Dictionary:
	for proj in state["projects"]["active"]:
		if proj.get("name") == doc_name:
			return proj
	return {}
