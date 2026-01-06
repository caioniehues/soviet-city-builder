class_name CameraController
extends Node3D
## RTS-style camera controller with pan, zoom, and rotation.
##
## Attach this to a Node3D that will act as the camera rig.
## The Camera3D should be a child of this node.

# Movement settings
@export_group("Movement")
@export var pan_speed: float = 20.0
@export var pan_acceleration: float = 8.0
@export var edge_scroll_enabled: bool = true
@export var edge_scroll_margin: int = 20
@export var edge_scroll_speed: float = 15.0

# Zoom settings
@export_group("Zoom")
@export var zoom_speed: float = 2.0
@export var zoom_smoothing: float = 8.0
@export var min_zoom: float = 10.0
@export var max_zoom: float = 100.0
@export var default_zoom: float = 30.0

# Rotation settings
@export_group("Rotation")
@export var rotation_speed: float = 0.005
@export var rotation_smoothing: float = 8.0
@export var min_pitch: float = -80.0
@export var max_pitch: float = -20.0
@export var default_pitch: float = -45.0

# Bounds (optional)
@export_group("Bounds")
@export var use_bounds: bool = false
@export var bounds_min: Vector2 = Vector2(-1000, -1000)
@export var bounds_max: Vector2 = Vector2(1000, 1000)

# Internal state
var _camera: Camera3D
var _current_velocity: Vector3 = Vector3.ZERO
var _target_zoom: float
var _current_zoom: float
var _target_rotation: Vector2  # x = yaw, y = pitch
var _current_rotation: Vector2
var _is_rotating: bool = false
var _last_mouse_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	_camera = _find_camera()
	if not _camera:
		push_error("CameraController: No Camera3D child found!")
		return

	# Initialize zoom
	_target_zoom = default_zoom
	_current_zoom = default_zoom
	_camera.position.z = default_zoom

	# Initialize rotation
	_target_rotation = Vector2(rotation.y, deg_to_rad(default_pitch))
	_current_rotation = _target_rotation
	rotation.x = _target_rotation.y


func _process(delta: float) -> void:
	if not _camera:
		return

	_handle_keyboard_pan(delta)
	_handle_edge_scroll(delta)
	_handle_zoom(delta)
	_handle_rotation(delta)
	_apply_bounds()


func _unhandled_input(event: InputEvent) -> void:
	# Mouse wheel zoom
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed:
			match mouse_event.button_index:
				MOUSE_BUTTON_WHEEL_UP:
					_target_zoom = clampf(_target_zoom - zoom_speed, min_zoom, max_zoom)
				MOUSE_BUTTON_WHEEL_DOWN:
					_target_zoom = clampf(_target_zoom + zoom_speed, min_zoom, max_zoom)
				MOUSE_BUTTON_MIDDLE:
					_is_rotating = true
					_last_mouse_position = mouse_event.position
		else:
			if mouse_event.button_index == MOUSE_BUTTON_MIDDLE:
				_is_rotating = false

	# Mouse drag rotation
	if event is InputEventMouseMotion and _is_rotating:
		var motion := event as InputEventMouseMotion
		var delta := motion.position - _last_mouse_position
		_last_mouse_position = motion.position

		_target_rotation.x -= delta.x * rotation_speed
		_target_rotation.y = clampf(
			_target_rotation.y - delta.y * rotation_speed,
			deg_to_rad(min_pitch),
			deg_to_rad(max_pitch)
		)


func _handle_keyboard_pan(delta: float) -> void:
	var input_dir := Vector3.ZERO

	if Input.is_action_pressed("camera_forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("camera_backward"):
		input_dir.z += 1
	if Input.is_action_pressed("camera_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("camera_right"):
		input_dir.x += 1

	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		# Transform direction based on camera yaw
		var rotated_dir := input_dir.rotated(Vector3.UP, rotation.y)
		_current_velocity = _current_velocity.lerp(
			rotated_dir * pan_speed,
			pan_acceleration * delta
		)
	else:
		_current_velocity = _current_velocity.lerp(Vector3.ZERO, pan_acceleration * delta)

	position += _current_velocity * delta


func _handle_edge_scroll(delta: float) -> void:
	if not edge_scroll_enabled:
		return

	var viewport := get_viewport()
	if not viewport:
		return

	var mouse_pos := viewport.get_mouse_position()
	var screen_size := viewport.get_visible_rect().size
	var edge_dir := Vector3.ZERO

	if mouse_pos.x < edge_scroll_margin:
		edge_dir.x -= 1
	elif mouse_pos.x > screen_size.x - edge_scroll_margin:
		edge_dir.x += 1

	if mouse_pos.y < edge_scroll_margin:
		edge_dir.z -= 1
	elif mouse_pos.y > screen_size.y - edge_scroll_margin:
		edge_dir.z += 1

	if edge_dir != Vector3.ZERO:
		edge_dir = edge_dir.normalized()
		var rotated_dir := edge_dir.rotated(Vector3.UP, rotation.y)
		position += rotated_dir * edge_scroll_speed * delta


func _handle_zoom(delta: float) -> void:
	_current_zoom = lerpf(_current_zoom, _target_zoom, zoom_smoothing * delta)
	_camera.position.z = _current_zoom


func _handle_rotation(delta: float) -> void:
	_current_rotation = _current_rotation.lerp(_target_rotation, rotation_smoothing * delta)
	rotation.y = _current_rotation.x
	rotation.x = _current_rotation.y


func _apply_bounds() -> void:
	if not use_bounds:
		return

	position.x = clampf(position.x, bounds_min.x, bounds_max.x)
	position.z = clampf(position.z, bounds_min.y, bounds_max.y)


func _find_camera() -> Camera3D:
	for child in get_children():
		if child is Camera3D:
			return child
	return null


# Public API

## Move camera to a specific world position
func move_to(target_position: Vector3, instant: bool = false) -> void:
	if instant:
		position = target_position
		_current_velocity = Vector3.ZERO
	else:
		# Could implement smooth transition here
		position = target_position


## Set zoom level (clamped to min/max)
func set_zoom(zoom_level: float, instant: bool = false) -> void:
	_target_zoom = clampf(zoom_level, min_zoom, max_zoom)
	if instant:
		_current_zoom = _target_zoom
		_camera.position.z = _current_zoom


## Reset camera to default state
func reset() -> void:
	position = Vector3.ZERO
	_target_zoom = default_zoom
	_current_zoom = default_zoom
	_target_rotation = Vector2(0, deg_to_rad(default_pitch))
	_current_rotation = _target_rotation
	_current_velocity = Vector3.ZERO
