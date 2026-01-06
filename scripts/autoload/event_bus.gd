extends Node
## Global event bus for decoupling systems.
##
## Use this singleton for cross-system communication instead of direct references.
## All signals use strongly-typed parameters for clarity and safety.

# =============================================================================
# BUILDING SIGNALS
# =============================================================================

## Emitted when a building is successfully placed in the world.
signal building_placed(building: Node3D, grid_position: Vector3i)

## Emitted when a building is removed from the world.
signal building_removed(building: Node3D, grid_position: Vector3i)

## Emitted when building placement fails (collision, invalid location, etc).
signal building_placement_failed(grid_position: Vector3i, reason: String)

## Emitted when a building is selected by the player.
signal building_selected(building: Node3D)

## Emitted when building selection is cleared.
signal building_deselected()

# =============================================================================
# GRID/PLACEMENT SIGNALS
# =============================================================================

## Emitted when the player hovers over a different grid cell.
signal grid_cell_hovered(grid_position: Vector3i)

## Emitted when placement mode is entered (user wants to place a building).
signal placement_mode_entered(building_data: Resource)

## Emitted when placement mode is exited (cancelled or completed).
signal placement_mode_exited()

## Emitted when the placement preview position updates.
signal placement_preview_updated(grid_position: Vector3i, is_valid: bool)

## Emitted when building rotation changes during placement.
signal placement_rotation_changed(rotation_index: int)

# =============================================================================
# COMMAND SIGNALS
# =============================================================================

## Emitted when a command is executed.
signal command_executed(command: RefCounted)

## Emitted when a command is undone.
signal command_undone(command: RefCounted)

## Emitted when a command is redone.
signal command_redone(command: RefCounted)

## Emitted when undo/redo availability changes.
signal undo_redo_state_changed(can_undo: bool, can_redo: bool)

# =============================================================================
# INPUT MODE SIGNALS
# =============================================================================

## Emitted when input mode changes (e.g., normal -> placement -> demolition).
signal input_mode_changed(mode: String)
