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
	
func load_snapshot(snapshot: Dictionary) -> void:
	print("[world_state] loading snapshot...")
	
	# Selling
	if snapshot.has("selling"):
		var s = snapshot["selling"]
		state["selling"]["pipeline"] = {
			"leads": s.get("leads", []),
			"opportunities": s.get("opportunities", []),
			"quotations": s.get("quotations", [])
		}
		state["selling"]["orders"] = {
			"sales_orders": s.get("sales_orders", []),
			"delivery_notes": s.get("delivery_notes", []),
			"delivery_trips": s.get("delivery_trips", [])
		}
		state["selling"]["invoices"] = {
			"sales_invoices": s.get("sales_invoices", []),
			"payment_entries_inbound": s.get("payment_entries_inbound", [])
		}
		state["selling"]["customers"] = s.get("customers", [])
		emit_signal("state_updated", "selling")
	
	# Buying
	if snapshot.has("buying"):
		var b = snapshot["buying"]
		state["buying"]["suppliers"] = b.get("suppliers", [])
		state["buying"]["purchase_orders"] = b.get("purchase_orders", [])
		state["buying"]["invoices"] = {
			"purchase_invoices": b.get("purchase_invoices", []),
			"payment_entries_outbound": b.get("payment_entries_outbound", [])
		}
		emit_signal("state_updated", "buying")
	
	# Accounting
	if snapshot.has("accounting"):
		var a = snapshot["accounting"]
		state["accounting"]["chart_of_accounts"] = a.get("accounts", [])
		state["accounting"]["bank_transactions"] = a.get("bank_transactions", [])
		emit_signal("state_updated", "accounting")
	
	# HR
	if snapshot.has("hr"):
		var h = snapshot["hr"]
		state["hr"]["employees"] = h.get("employees", [])
		state["hr"]["attendance"] = h.get("attendance", [])
		emit_signal("state_updated", "hr")
	
	# Projects
	if snapshot.has("projects"):
		var p = snapshot["projects"]
		state["projects"]["active"] = p.get("projects", [])
		state["projects"]["tasks"] = p.get("tasks", [])
		emit_signal("state_updated", "projects")
	
	# Stock
	if snapshot.has("stock"):
		var st = snapshot["stock"]
		state["stock"]["physical"] = {
			"items": st.get("items", [])
		}
		emit_signal("state_updated", "stock")
	
	print("[world_state] snapshot loaded — modules populated")
