extends Node

# ── Route incoming events to the correct handler ──────────────────────────────
func process_event(event: Dictionary) -> void:
	var module = event.get("module", "")
	var doctype = event.get("doctype", "")
	var docname = event.get("docname", "")
	var payload = event.get("payload", {})
	var trigger = event.get("event_type", "")

	print("[diff] processing: ", doctype, " — ", docname, " — ", trigger)

	match module:
		"selling":
			_handle_selling(doctype, docname, payload, trigger)
		"buying":
			_handle_buying(doctype, docname, payload, trigger)
		"accounting":
			_handle_accounting(doctype, docname, payload, trigger)
		"hr":
			_handle_hr(doctype, docname, payload, trigger)
		"projects":
			_handle_projects(doctype, docname, payload, trigger)
		"stock":
			_handle_stock(doctype, docname, payload, trigger)
		_:
			print("[diff] unhandled module: ", module)

# ── Module handlers ───────────────────────────────────────────────────────────
func _handle_selling(doctype: String, docname: String, payload: Dictionary, trigger: String) -> void:
	match doctype:
		"Lead":
			_upsert_in_list(WorldState.state["selling"]["pipeline"], "leads_list", docname, payload)
			# Confirm pending unit
			var um = get_tree().get_first_node_in_group("unit_manager")
			if um:
				um.set_unit_confirmed(docname)
			var log = get_tree().get_first_node_in_group("command_log")
			if log:
				log.log_command("convert_lead", docname, "confirmed")
		"Opportunity":
			_upsert_in_list(WorldState.state["selling"]["pipeline"], "opportunities_list", docname, payload)
		"Sales Order":
			_upsert_in_list(WorldState.state["selling"]["orders"], "orders_list", docname, payload)
		"Sales Invoice":
			_upsert_in_list(WorldState.state["selling"]["invoices"], "invoices_list", docname, payload)
		_:
			print("[diff] unhandled selling doctype: ", doctype)
	WorldState.emit_signal("state_updated", "selling")

func _handle_buying(doctype: String, docname: String, payload: Dictionary, trigger: String) -> void:
	match doctype:
		"Purchase Order":
			_upsert_list(WorldState.state["buying"]["purchase_orders"], docname, payload)
		_:
			print("[diff] unhandled buying doctype: ", doctype)
	WorldState.emit_signal("state_updated", "buying")

func _handle_accounting(doctype: String, docname: String, payload: Dictionary, trigger: String) -> void:
	match doctype:
		"Bank Transaction":
			_upsert_list(WorldState.state["accounting"]["chart_of_accounts"], docname, payload)
			if payload.get("status") == "Unreconciled":
				WorldState.add_alert({
					"type": "action_required",
					"module": "accounting",
					"doctype": "Bank Transaction",
					"docname": docname,
					"message": "Unreconciled bank transaction requires attention.",
					"severity": "medium"
				})
		_:
			print("[diff] unhandled accounting doctype: ", doctype)
	WorldState.emit_signal("state_updated", "accounting")

func _handle_hr(doctype: String, docname: String, payload: Dictionary, trigger: String) -> void:
	match doctype:
		"Employee":
			_upsert_list(WorldState.state["hr"]["employees"], docname, payload)
		_:
			print("[diff] unhandled hr doctype: ", doctype)
	WorldState.emit_signal("state_updated", "hr")

func _handle_projects(doctype: String, docname: String, payload: Dictionary, trigger: String) -> void:
	match doctype:
		"Project":
			_upsert_list(WorldState.state["projects"]["active"], docname, payload)
			if payload.get("percent_complete", 0) == 100:
				print("[diff] project completed: ", docname)
		"Task":
			print("[diff] task updated: ", docname)
		_:
			print("[diff] unhandled projects doctype: ", doctype)
	WorldState.emit_signal("state_updated", "projects")

func _handle_stock(doctype: String, docname: String, payload: Dictionary, trigger: String) -> void:
	print("[diff] stock event: ", doctype, " — ", docname)
	WorldState.emit_signal("state_updated", "stock")

# ── Utility: upsert a record in a list by name ────────────────────────────────
func _upsert_list(list: Array, docname: String, payload: Dictionary) -> void:
	for i in range(list.size()):
		if list[i].get("name") == docname:
			list[i].merge(payload, true)
			return
	list.append(payload)

func _upsert_in_list(dict: Dictionary, key: String, docname: String, payload: Dictionary) -> void:
	if not dict.has(key):
		dict[key] = []
	_upsert_list(dict[key], docname, payload)
