extends Camera3D

const PAN_SPEED = 20.0
const ZOOM_SPEED = 5.0
const ZOOM_MIN = 10.0
const ZOOM_MAX = 80.0

func _process(delta: float) -> void:
	_handle_pan(delta)

func _handle_pan(delta: float) -> void:
	var move = Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		move.z -= 1
	if Input.is_key_pressed(KEY_S):
		move.z += 1
	if Input.is_key_pressed(KEY_A):
		move.x -= 1
	if Input.is_key_pressed(KEY_D):
		move.x += 1
	position += move * PAN_SPEED * delta

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			position.y = clamp(position.y - ZOOM_SPEED, ZOOM_MIN, ZOOM_MAX)
			position.z = clamp(position.z - ZOOM_SPEED * 0.5, ZOOM_MIN * 0.5, ZOOM_MAX * 0.5)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			position.y = clamp(position.y + ZOOM_SPEED, ZOOM_MIN, ZOOM_MAX)
			position.z = clamp(position.z + ZOOM_SPEED * 0.5, ZOOM_MIN * 0.5, ZOOM_MAX * 0.5)
