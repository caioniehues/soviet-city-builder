class_name BuildingGhost
extends Node3D
## Visual preview of a building before placement.

@export var valid_color: Color = Color(0.2, 0.8, 0.2, 0.5)
@export var invalid_color: Color = Color(0.8, 0.2, 0.2, 0.5)

var _mesh_instance: MeshInstance3D
var _material: StandardMaterial3D
var _building_size: Vector2i = Vector2i(1, 1)
var _rotation_index: int = 0


func _ready() -> void:
	_setup_ghost_mesh()
	visible = false


func _setup_ghost_mesh() -> void:
	_mesh_instance = MeshInstance3D.new()
	add_child(_mesh_instance)

	_material = StandardMaterial3D.new()
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.albedo_color = valid_color
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.cull_mode = BaseMaterial3D.CULL_DISABLED

	_update_mesh()


func _update_mesh() -> void:
	var box := BoxMesh.new()
	var rotated_size := _get_rotated_size()
	box.size = Vector3(
		rotated_size.x * GameState.GRID_CELL_SIZE * 0.95,
		3.0,
		rotated_size.y * GameState.GRID_CELL_SIZE * 0.95
	)
	_mesh_instance.mesh = box
	_mesh_instance.material_override = _material
	_mesh_instance.position = Vector3(
		(rotated_size.x - 1) * GameState.GRID_CELL_SIZE * 0.5,
		box.size.y * 0.5,
		(rotated_size.y - 1) * GameState.GRID_CELL_SIZE * 0.5
	)


func _get_rotated_size() -> Vector2i:
	if _rotation_index % 2 == 1:
		return Vector2i(_building_size.y, _building_size.x)
	return _building_size


func set_building_size(size: Vector2i) -> void:
	_building_size = size
	_update_mesh()


func set_valid(is_valid: bool) -> void:
	_material.albedo_color = valid_color if is_valid else invalid_color


func set_grid_position(grid_pos: Vector3i) -> void:
	position = GameState.grid_to_world(grid_pos)
	position.x -= GameState.GRID_CELL_SIZE * 0.5
	position.z -= GameState.GRID_CELL_SIZE * 0.5


func rotate_building() -> void:
	_rotation_index = (_rotation_index + 1) % 4
	_update_mesh()


func get_rotation_index() -> int:
	return _rotation_index


func get_building_size() -> Vector2i:
	return _building_size


func reset_rotation() -> void:
	_rotation_index = 0
	_update_mesh()
