class_name Command
extends RefCounted
## Base class for all game commands.
##
## Commands encapsulate state-changing operations for:
## - Undo/redo support
## - Deterministic replay (multiplayer)
## - Save/load simplicity
##
## All subclasses must implement execute() and undo().

# =============================================================================
# PROPERTIES
# =============================================================================

## Unique identifier for this command (for networking/replay).
var id: int = 0

## Timestamp when command was created (game time, not real time).
var timestamp: float = 0.0

## Whether this command has been executed.
var is_executed: bool = false

## Human-readable description for UI/debugging.
var description: String = "Command"

# =============================================================================
# VIRTUAL METHODS - Override in subclasses
# =============================================================================

## Execute the command. Returns true on success.
func execute() -> bool:
	push_error("Command.execute() must be overridden")
	return false


## Undo the command. Returns true on success.
func undo() -> bool:
	push_error("Command.undo() must be overridden")
	return false


## Check if this command can be merged with another (for batching).
func can_merge_with(_other: Command) -> bool:
	return false


## Merge another command into this one.
func merge(_other: Command) -> void:
	pass

# =============================================================================
# UTILITY METHODS
# =============================================================================

## Get command data for serialization/networking.
func to_dict() -> Dictionary:
	return {
		"type": get_class(),
		"id": id,
		"timestamp": timestamp,
		"description": description,
	}
