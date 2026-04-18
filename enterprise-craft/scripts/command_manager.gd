extends Node

# Command type mapping per context menu label
const COMMAND_MAP = {
	"Convert to Opportunity": {
		"command_type": "convert_lead",
		"module": "selling",
		"doctype": "Lead"
	},
	"Mark as Lost": {
		"command_type": "advance_stage",
		"module": "selling",
		"params": {"new_stage": "Do Not Contact"}
	},
	"Create Quotation": {
		"command_type": "create_quotation",
		"module": "selling",
		"doctype": "Opportunity"
	},
	"Create Invoice": {
		"command_type": "submit_invoice",
		"module": "selling",
		"doctype": "Sales Order"
	},
	"Issue Dividend": {
		"command_type": "issue_dividend",
		"module": "accounting",
		"doctype": "Treasury"
	},
	"View Details": {
		"command_type": "inspect",
		"module": ""
	}
}

var _cmd_counter: int = 0

func issue_command(label: String, doctype: String, docname: String, _data: Dictionary = {}) -> void:
	if not COMMAND_MAP.has(label):
		return
	var cmd_def = COMMAND_MAP[label]
	if cmd_def["command_type"] == "inspect":
		DocumentFetcher.fetch(doctype, docname, func(doc):
			var detail_panel = get_tree().get_first_node_in_group("detail_panel")
			if detail_panel:
				detail_panel.open(doctype, docname, doc)
		)
		return

	var unit_manager = get_tree().get_first_node_in_group("unit_manager")
	if unit_manager:
		unit_manager.set_unit_pending(docname)

	# Log as pending
	var log = get_tree().get_first_node_in_group("command_log")
	if log:
		log.log_command(cmd_def["command_type"], docname, "pending")

	_cmd_counter += 1
	var command = {
		"command_id": "CMD-%s-%04d" % [Time.get_datetime_string_from_system().replace(":", ""), _cmd_counter],
		"command_type": cmd_def.get("command_type", ""),
		"module": cmd_def.get("module", ""),
		"doctype": doctype,
		"docname": docname,
		"params": cmd_def.get("params", {}),
		"issued_by": "commander",
		"timestamp": Time.get_datetime_string_from_system()
	}
	print("[cmd] issuing: ", command)
	_send_command(command)

func _send_command(command: Dictionary) -> void:
	var ws = get_tree().get_first_node_in_group("websocket_client")
	if ws == null:
		print("[cmd] no websocket client found")
		return
	var json = JSON.stringify(command)
	ws.socket.send_text(json)
	print("[cmd] sent: ", command["command_type"], " on ", command["docname"])
	
