extends Node
## Manages the game world, grid occupancy, and building placement.
##
## Responsible for:
## - Tracking what occupies each grid cell
## - Validating building placement
## - Spatial queries (what's at position X?)
## - Building instantiation and removal

# =============================================================================
# TYPES
# =============================================================================

## Represents what can occupy a grid cell.
enum CellOccupancy {
	EMPTY,
	BUILDING,
	ROAD,
	RESERVED,  ## Reserved for multi-cell buildings
}

## Data stored for each occupied cell.
class CellData:
	var occupancy: CellOccupancy = CellOccupancy.EMPTY
	var building: Node3D = null  ## Reference to building if occupied
	var building_origin: Vector3i = Vector3i.ZERO  ## Origin cell for multi-cell buildings

	func _init(p_occupancy: CellOccupancy = CellOccupancy.EMPTY,
			   p_building: Node3D = null,
			   p_origin: Vector3i = Vector3i.ZERO) -> void:
		occupancy = p_occupancy
		building = p_building
		building_origin = p_origin

# =============================================================================
# STATE
# =============================================================================

## Grid occupancy data. Key: Vector3i (grid position), Value: CellData
## We only store occupied cells (sparse storage for large maps).
var _grid: Dictionary = {}

## All placed buildings. Key: Vector3i (origin position), Value: Node3D
var _buildings: Dictionary = {}

## Parent node for all buildings in the scene tree.
var _buildings_container: Node3D = null

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	_ensure_buildings_container()


func _ensure_buildings_container() -> void:
	if _buildings_container == null:
		_buildings_container = Node3D.new()
		_buildings_container.name = "Buildings"

# =============================================================================
# GRID QUERIES
# =============================================================================

## Check if a grid cell is empty.
func is_cell_empty(grid_pos: Vector3i) -> bool:
	if not _grid.has(grid_pos):
		return true
	return _grid[grid_pos].occupancy == CellOccupancy.EMPTY


## Check if a rectangular area is empty.
func is_area_empty(origin: Vector3i, size: Vector2i, rotation_index: int = 0) -> bool:
	var cells := get_building_cells(origin, size, rotation_index)
	for cell in cells:
		if not is_cell_empty(cell):
			return false
	return true


## Get the building at a grid position (or null if empty).
func get_building_at(grid_pos: Vector3i) -> Node3D:
	if _grid.has(grid_pos):
		return _grid[grid_pos].building
	return null


## Get all cells that a building would occupy.
func get_building_cells(origin: Vector3i, size: Vector2i, rotation_index: int = 0) -> Array[Vector3i]:
	var cells: Array[Vector3i] = []
	var rotated_size := _rotate_size(size, rotation_index)

	for x in range(rotated_size.x):
		for z in range(rotated_size.y):
			cells.append(Vector3i(origin.x + x, origin.y, origin.z + z))

	return cells


## Get cell data at position (or null if unoccupied).
func get_cell_data(grid_pos: Vector3i) -> CellData:
	return _grid.get(grid_pos, null)


## Get total number of placed buildings.
func get_building_count() -> int:
	return _buildings.size()

# =============================================================================
# BUILDING PLACEMENT
# =============================================================================

## Validate if a building can be placed at the given position.
## Returns empty string if valid, error message if invalid.
func validate_placement(building_data: Resource, grid_pos: Vector3i, rotation_index: int = 0) -> String:
	if building_data == null:
		return "No building type selected"

	var size := _get_building_size(building_data)

	if not is_area_empty(grid_pos, size, rotation_index):
		return "Area is not empty"

	return ""


## Place a building at the specified grid position.
## Returns the placed building instance, or null if placement failed.
func place_building(building_data: Resource, grid_pos: Vector3i, rotation_index: int = 0) -> Node3D:
	var validation_error := validate_placement(building_data, grid_pos, rotation_index)
	if validation_error != "":
		EventBus.building_placement_failed.emit(grid_pos, validation_error)
		return null

	var building := _instantiate_building(building_data, grid_pos, rotation_index)
	if building == null:
		EventBus.building_placement_failed.emit(grid_pos, "Failed to instantiate building")
		return null

	var size := _get_building_size(building_data)
	var cells := get_building_cells(grid_pos, size, rotation_index)

	for cell in cells:
		_grid[cell] = CellData.new(CellOccupancy.BUILDING, building, grid_pos)

	_buildings[grid_pos] = building

	EventBus.building_placed.emit(building, grid_pos)

	return building


## Remove a building from the world.
## Returns true if building was removed, false if no building found.
func remove_building(grid_pos: Vector3i) -> bool:
	var cell_data := get_cell_data(grid_pos)
	if cell_data == null or cell_data.building == null:
		return false

	var building := cell_data.building
	var origin := cell_data.building_origin

	var cells_to_clear: Array[Vector3i] = []
	for cell_pos: Vector3i in _grid.keys():
		var data: CellData = _grid[cell_pos]
		if data.building == building:
			cells_to_clear.append(cell_pos)

	for cell in cells_to_clear:
		_grid.erase(cell)

	_buildings.erase(origin)

	EventBus.building_removed.emit(building, origin)

	building.queue_free()

	return true

# =============================================================================
# INTERNAL HELPERS
# =============================================================================

func _rotate_size(size: Vector2i, rotation_index: int) -> Vector2i:
	if rotation_index % 2 == 1:
		return Vector2i(size.y, size.x)
	return size


func _get_building_size(building_data: Resource) -> Vector2i:
	if building_data and "grid_size" in building_data:
		return building_data.grid_size
	return Vector2i(1, 1)


func _instantiate_building(building_data: Resource, grid_pos: Vector3i, rotation_index: int) -> Node3D:
	if _buildings_container == null:
		_ensure_buildings_container()

	if _buildings_container.get_parent() == null:
		var main := get_tree().current_scene
		if main:
			main.add_child(_buildings_container)

	var building: Node3D = null

	if building_data and "scene" in building_data and building_data.scene != null:
		var scene: PackedScene = building_data.scene
		building = scene.instantiate()

	if building == null:
		building = _create_placeholder_building(building_data)

	var world_pos := GameState.grid_to_world(grid_pos)
	building.position = world_pos
	building.rotation.y = GameState.rotation_index_to_radians(rotation_index)

	building.set_meta("grid_position", grid_pos)
	building.set_meta("rotation_index", rotation_index)
	building.set_meta("building_data", building_data)

	_buildings_container.add_child(building)

	return building


func _create_placeholder_building(building_data: Resource) -> Node3D:
	var size := _get_building_size(building_data)

	var root := Node3D.new()
	root.name = "PlaceholderBuilding"

	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()

	box_mesh.size = Vector3(
		size.x * GameState.GRID_CELL_SIZE * 0.9,
		3.0,
		size.y * GameState.GRID_CELL_SIZE * 0.9
	)
	mesh_instance.mesh = box_mesh
	mesh_instance.position.y = box_mesh.size.y * 0.5

	var material := StandardMaterial3D.new()
	if building_data and "placeholder_color" in building_data:
		material.albedo_color = building_data.placeholder_color
	else:
		material.albedo_color = Color(0.6, 0.6, 0.7)  # Soviet gray
	mesh_instance.material_override = material

	root.add_child(mesh_instance)

	return root
