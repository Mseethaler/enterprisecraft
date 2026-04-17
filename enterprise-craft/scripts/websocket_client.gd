extends Node3D

const WS_URL = "wss://ws.digital-sovereignty.cc/?token=64e322288bdb05cad7f8cf21abc57f2a39337a609b7989189488b9d60d5aaafa"
# const WS_URL = "wss://ws.digital-sovereignty.cc/"

var socket = WebSocketPeer.new()

func _ready() -> void:
	print("EnterpriseCraft starting...")
	connect_to_server()

func connect_to_server() -> void:
	print("Connecting to WebSocket server...")
	var tls_options = TLSOptions.client()
	var err = socket.connect_to_url(WS_URL, tls_options)
	if err != OK:
		print("Failed to initiate connection: ", err)

var reconnect_timer: float = 0.0
const RECONNECT_DELAY = 3.0

var ping_timer: float = 0.0
const PING_INTERVAL = 30.0

func _process(_delta: float) -> void:
	socket.poll()
	var state = socket.get_ready_state()
	match state:
		WebSocketPeer.STATE_CONNECTING:
			pass
		WebSocketPeer.STATE_OPEN:
			reconnect_timer = 0.0
			ping_timer += _delta
			if ping_timer >= PING_INTERVAL:
				ping_timer = 0.0
				socket.send_text("ping")
			while socket.get_available_packet_count():
				var packet = socket.get_packet()
				var json_string = packet.get_string_from_utf8()
				var json = JSON.parse_string(json_string)
				if json:
					handle_event(json)
		WebSocketPeer.STATE_CLOSING:
			pass
		WebSocketPeer.STATE_CLOSED:
			ping_timer = 0.0
			reconnect_timer += _delta
			if reconnect_timer >= RECONNECT_DELAY:
				reconnect_timer = 0.0
				print("Reconnecting...")
				socket = WebSocketPeer.new()
				connect_to_server()

func handle_event(event: Dictionary) -> void:
	print("Event received: ", event)
	DiffEngine.process_event(event)
