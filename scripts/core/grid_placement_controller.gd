class_name GridPlacementController
extends Node
## Handles mouse-to-world raycasting and grid coordinate calculation.

signal grid_position_changed(grid_pos: Vector3i)

@export var ground_collision_mask: int = 1

var _camera: Camera3D
var _current_grid_pos: Vector3i = Vector3i.ZERO
var _current_world_pos: Vector3 = Vector3.ZERO
var _is_valid_position: bool = false


func _ready() -> void:
	_camera = get_viewport().get_camera_3d()


func _physics_process(_delta: float) -> void:
	_update_raycast()


func _update_raycast() -> void:
	if not _camera:
		_camera = get_viewport().get_camera_3d()
		if not _camera:
			return

	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = _camera.project_ray_origin(mouse_pos)
	var ray_direction: Vector3 = _camera.project_ray_normal(mouse_pos)
	var ray_end: Vector3 = ray_origin + ray_direction * 1000.0

	var space_state: PhysicsDirectSpaceState3D = get_viewport().get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collision_mask = ground_collision_mask

	var result: Dictionary = space_state.intersect_ray(query)

	if result.is_empty():
		_is_valid_position = false
		return

	_is_valid_position = true
	_current_world_pos = result.position

	var new_grid_pos := GameState.world_to_grid(_current_world_pos)
	new_grid_pos.y = 0

	if new_grid_pos != _current_grid_pos:
		_current_grid_pos = new_grid_pos
		grid_position_changed.emit(_current_grid_pos)
		EventBus.grid_cell_hovered.emit(_current_grid_pos)


func get_current_grid_position() -> Vector3i:
	return _current_grid_pos


func get_current_world_position() -> Vector3:
	return GameState.grid_to_world(_current_grid_pos)


func is_position_valid() -> bool:
	return _is_valid_position
