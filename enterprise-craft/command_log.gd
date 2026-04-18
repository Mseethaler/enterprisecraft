extends RichTextLabel

const MAX_ENTRIES = 10
const ENTRY_LIFETIME = 8.0

var entries = []

func _ready() -> void:
	bbcode_enabled = true
	text = ""

func _process(delta: float) -> void:
	if entries.is_empty():
		return
	var changed = false
	for entry in entries:
		entry["age"] += delta
	entries = entries.filter(func(e): return e["age"] < ENTRY_LIFETIME)
	_rebuild()

func log_command(command_type: String, docname: String, status: String) -> void:
	var color = "white"
	var icon = "○"
	match status:
		"pending":
			color = "yellow"
			icon = "◌"
		"confirmed":
			color = "green"
			icon = "●"
		"failed":
			color = "red"
			icon = "✕"
	var time = Time.get_time_string_from_system()
	entries.append({
		"text": "[color=%s]%s %s → %s [color=gray]%s[/color][/color]" % [color, icon, command_type, docname, time],
		"age": 0.0
	})
	if entries.size() > MAX_ENTRIES:
		entries.pop_front()
	_rebuild()

func _rebuild() -> void:
	text = "\n".join(entries.map(func(e): return e["text"]))
