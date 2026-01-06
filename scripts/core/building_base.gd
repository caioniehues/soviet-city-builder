class_name BuildingBase
extends Node3D
## Base class for all buildings in the game.
##
## Provides common functionality:
## - Grid positioning and size
## - Rotation handling
## - Selection state
## - Building data reference
##
## Subclasses should override _process_production() for specific behavior.

# =============================================================================
# SIGNALS
# =============================================================================

signal selected()
signal deselected()

# =============================================================================
# EXPORTS
# =============================================================================

@export_group("Building Data")
## Reference to the BuildingData resource defining this building type.
@export var building_data: BuildingData

@export_group("Grid Properties")
## Size of this building in grid cells (width x depth).
@export var grid_size: Vector2i = Vector2i(1, 1)

# =============================================================================
# STATE
# =============================================================================

## Grid position where this building was placed (origin cell).
var grid_position: Vector3i = Vector3i.ZERO

## Rotation index (0-3 for 0, 90, 180, 270 degrees).
var rotation_index: int = 0

## Whether this building is currently selected.
var is_selected: bool = false:
	set(value):
		if is_selected != value:
			is_selected = value
			_on_selection_changed()

## Whether this building is operational (has power, workers, etc).
var is_operational: bool = true

# =============================================================================
# CACHED REFERENCES
# =============================================================================

var _selection_indicator: Node3D = null

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	if building_data:
		set_meta("building_data", building_data)
		if building_data.grid_size != Vector2i.ZERO:
			grid_size = building_data.grid_size

	_selection_indicator = get_node_or_null("SelectionIndicator")
	if _selection_indicator:
		_selection_indicator.visible = false

	_on_ready()


## Override in subclasses for additional setup.
func _on_ready() -> void:
	pass


func _process(delta: float) -> void:
	if is_operational:
		_process_production(delta)


## Override in production buildings to handle resource processing.
func _process_production(_delta: float) -> void:
	pass

# =============================================================================
# PUBLIC API
# =============================================================================

## Get the BuildingData resource for this building.
func get_building_data() -> BuildingData:
	return building_data


## Get all grid cells this building occupies.
func get_occupied_cells() -> Array[Vector3i]:
	return WorldManager.get_building_cells(grid_position, grid_size, rotation_index)


## Initialize the building after placement.
func initialize(p_grid_position: Vector3i, p_rotation_index: int) -> void:
	grid_position = p_grid_position
	rotation_index = p_rotation_index
	set_meta("grid_position", grid_position)
	set_meta("rotation_index", rotation_index)


## Select this building.
func select() -> void:
	is_selected = true


## Deselect this building.
func deselect() -> void:
	is_selected = false


## Called when building is about to be removed.
func on_remove() -> void:
	pass

# =============================================================================
# INTERNAL
# =============================================================================

func _on_selection_changed() -> void:
	if _selection_indicator:
		_selection_indicator.visible = is_selected

	if is_selected:
		selected.emit()
		EventBus.building_selected.emit(self)
	else:
		deselected.emit()

# =============================================================================
# UTILITY
# =============================================================================

## Get world-space center of this building.
func get_center() -> Vector3:
	var rotated_size := grid_size
	if rotation_index % 2 == 1:
		rotated_size = Vector2i(grid_size.y, grid_size.x)

	return Vector3(
		position.x + (rotated_size.x * GameState.GRID_CELL_SIZE) * 0.5,
		position.y,
		position.z + (rotated_size.y * GameState.GRID_CELL_SIZE) * 0.5
	)
