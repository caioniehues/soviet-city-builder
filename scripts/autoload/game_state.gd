extends Node
## Global game state manager.
##
## Handles time progression, game speed, and high-level game modes.
## This is the single source of truth for global game state.

# =============================================================================
# ENUMS
# =============================================================================

## Input modes determine how player input is interpreted.
enum InputMode {
	NORMAL,       ## Default mode - selection, camera control
	PLACEMENT,    ## Building placement mode
	DEMOLITION,   ## Building removal mode
}

## Game speed settings.
enum GameSpeed {
	PAUSED = 0,
	NORMAL = 1,
	FAST = 2,
	FASTER = 4,
}

# =============================================================================
# CONSTANTS
# =============================================================================

const GRID_CELL_SIZE: float = 1.0  ## Size of each grid cell in meters
const CHUNK_SIZE: int = 256        ## Chunk size in grid cells (256m x 256m)

# =============================================================================
# STATE VARIABLES
# =============================================================================

## Current input mode.
var current_input_mode: InputMode = InputMode.NORMAL:
	set(value):
		if current_input_mode != value:
			var old_mode := current_input_mode
			current_input_mode = value
			_on_input_mode_changed(old_mode, value)

## Current game speed multiplier.
var current_speed: GameSpeed = GameSpeed.NORMAL:
	set(value):
		current_speed = value
		speed_changed.emit(value)

## Whether the game is paused.
var is_paused: bool = false:
	get:
		return current_speed == GameSpeed.PAUSED

## The BuildingData resource currently selected for placement (null if none).
var selected_building_data: Resource = null

## Current rotation index for placement (0-3 = 0, 90, 180, 270 degrees).
var placement_rotation: int = 0:
	set(value):
		placement_rotation = value % 4
		EventBus.placement_rotation_changed.emit(placement_rotation)

# =============================================================================
# SIGNALS
# =============================================================================

signal speed_changed(speed: GameSpeed)

# =============================================================================
# INPUT MODE MANAGEMENT
# =============================================================================

## Enter building placement mode with the specified building type.
func enter_placement_mode(building_data: Resource) -> void:
	selected_building_data = building_data
	placement_rotation = 0
	current_input_mode = InputMode.PLACEMENT
	EventBus.placement_mode_entered.emit(building_data)


## Exit placement mode and return to normal mode.
func exit_placement_mode() -> void:
	selected_building_data = null
	current_input_mode = InputMode.NORMAL
	EventBus.placement_mode_exited.emit()


## Enter demolition mode.
func enter_demolition_mode() -> void:
	selected_building_data = null
	current_input_mode = InputMode.DEMOLITION


## Return to normal mode from any mode.
func return_to_normal_mode() -> void:
	selected_building_data = null
	current_input_mode = InputMode.NORMAL


## Rotate placement by 90 degrees clockwise.
func rotate_placement_clockwise() -> void:
	placement_rotation = (placement_rotation + 1) % 4


## Rotate placement by 90 degrees counter-clockwise.
func rotate_placement_counter_clockwise() -> void:
	placement_rotation = (placement_rotation + 3) % 4


func _on_input_mode_changed(_old_mode: InputMode, new_mode: InputMode) -> void:
	var mode_name: String = InputMode.keys()[new_mode].to_lower()
	EventBus.input_mode_changed.emit(mode_name)


# =============================================================================
# COORDINATE UTILITIES
# =============================================================================

## Convert world position to grid position (integer coordinates).
static func world_to_grid(world_pos: Vector3) -> Vector3i:
	return Vector3i(
		floori(world_pos.x / GRID_CELL_SIZE),
		floori(world_pos.y / GRID_CELL_SIZE),
		floori(world_pos.z / GRID_CELL_SIZE)
	)


## Convert grid position to world position (center of cell).
static func grid_to_world(grid_pos: Vector3i) -> Vector3:
	return Vector3(
		grid_pos.x * GRID_CELL_SIZE + GRID_CELL_SIZE * 0.5,
		grid_pos.y * GRID_CELL_SIZE,
		grid_pos.z * GRID_CELL_SIZE + GRID_CELL_SIZE * 0.5
	)


## Convert world position to chunk coordinates.
static func world_to_chunk(world_pos: Vector3) -> Vector2i:
	return Vector2i(
		floori(world_pos.x / (CHUNK_SIZE * GRID_CELL_SIZE)),
		floori(world_pos.z / (CHUNK_SIZE * GRID_CELL_SIZE))
	)


## Convert grid position to chunk coordinates.
static func grid_to_chunk(grid_pos: Vector3i) -> Vector2i:
	return Vector2i(
		floori(float(grid_pos.x) / CHUNK_SIZE),
		floori(float(grid_pos.z) / CHUNK_SIZE)
	)


## Get rotation in radians from rotation index (0-3).
static func rotation_index_to_radians(index: int) -> float:
	return index * PI * 0.5  # 0, 90, 180, 270 degrees
