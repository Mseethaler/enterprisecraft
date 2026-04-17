extends RichTextLabel

const MAX_ENTRIES = 10
var entries = []

func _ready() -> void:
	bbcode_enabled = true
	text = ""

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
	var entry = "[color=%s]%s %s → %s [color=gray]%s[/color][/color]" % [color, icon, command_type, docname, time]
	entries.append(entry)

	if entries.size() > MAX_ENTRIES:
		entries.pop_front()

	text = "\n".join(entries)
