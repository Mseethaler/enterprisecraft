extends Control

var current_doctype: String = ""
var current_docname: String = ""
var current_data: Dictionary = {}

@onready var button_container = $Panel/VBoxContainer

const COMMANDS = {
	"Lead": ["Convert to Opportunity", "Mark as Lost", "View Details"],
	"Opportunity": ["Create Quotation", "Mark as Lost", "View Details"],
	"Sales Order": ["Create Invoice", "View Details"],
	"Project": ["View Tasks", "View Details"],
	"Employee": ["View Details"],
	"fishing_dock": ["View Pipeline"],
	"treasury": ["View Accounts", "Issue Dividend"],
	"construction_sites": ["View Projects"],
	"warehouse": ["View Stock"],
	"barracks": ["View Employees"],
	"harbor": ["View Orders"],
	"fulfillment_hall": ["View Orders"],
	"mill": ["View Subscriptions"],
}

func _ready() -> void:
	hide()
	var input = get_tree().get_first_node_in_group("input_manager")
	if input:
		input.unit_clicked.connect(_on_unit_clicked)
		input.building_clicked.connect(_on_building_clicked)

func _on_unit_clicked(doctype: String, docname: String, data: Dictionary, screen_pos: Vector2) -> void:
	current_doctype = doctype
	current_docname = docname
	current_data = data
	_show_menu(doctype, screen_pos)

func _on_building_clicked(building_id: String, screen_pos: Vector2) -> void:
	current_doctype = building_id
	current_docname = building_id
	current_data = {}
	_show_menu(building_id, screen_pos)

func _show_menu(key: String, screen_pos: Vector2) -> void:
	# Clear old buttons
	for child in button_container.get_children():
		child.queue_free()

	var commands = COMMANDS.get(key, ["View Details"])
	for cmd in commands:
		var btn = Button.new()
		btn.text = cmd
		btn.pressed.connect(_on_command_pressed.bind(cmd))
		button_container.add_child(btn)

	position = screen_pos
	show()

func _on_command_pressed(command: String) -> void:
	print("[context] command: ", command, " on ", current_docname)
	CommandManager.issue_command(command, current_doctype, current_docname, current_data)
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			hide()
			
