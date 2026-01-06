class_name CommandManager
extends RefCounted
## Manages command execution, undo, and redo stacks.
##
## Usage:
##   var cmd := PlaceBuildingCommand.new(building_data, position)
##   CommandManager.get_instance().execute(cmd)
##   CommandManager.get_instance().undo()
##   CommandManager.get_instance().redo()

# =============================================================================
# CONSTANTS
# =============================================================================

const MAX_UNDO_HISTORY: int = 100

# =============================================================================
# STATE
# =============================================================================

## Undo stack (most recent at end).
var _undo_stack: Array[Command] = []

## Redo stack (most recent at end).
var _redo_stack: Array[Command] = []

## Next command ID.
var _next_id: int = 1

# =============================================================================
# SINGLETON PATTERN
# =============================================================================

static var _instance: CommandManager = null


static func get_instance() -> CommandManager:
	if _instance == null:
		_instance = CommandManager.new()
	return _instance

# =============================================================================
# COMMAND EXECUTION
# =============================================================================

## Execute a command and add it to the undo stack.
func execute(command: Command) -> bool:
	command.id = _next_id
	_next_id += 1

	var success := command.execute()

	if success:
		command.is_executed = true

		# Check if we can merge with the last command
		if _undo_stack.size() > 0:
			var last := _undo_stack[-1]
			if last.can_merge_with(command):
				last.merge(command)
				EventBus.command_executed.emit(last)
				_emit_state_changed()
				return true

		_undo_stack.append(command)

		# Limit undo history
		while _undo_stack.size() > MAX_UNDO_HISTORY:
			_undo_stack.pop_front()

		# Clear redo stack (new action invalidates redo)
		_redo_stack.clear()

		EventBus.command_executed.emit(command)
		_emit_state_changed()

	return success


## Undo the most recent command.
func undo() -> bool:
	if _undo_stack.is_empty():
		return false

	var command: Command = _undo_stack.pop_back()
	var success: bool = command.undo()

	if success:
		command.is_executed = false
		_redo_stack.append(command)
		EventBus.command_undone.emit(command)
		_emit_state_changed()
	else:
		# Failed to undo, put it back
		_undo_stack.append(command)

	return success


## Redo the most recently undone command.
func redo() -> bool:
	if _redo_stack.is_empty():
		return false

	var command: Command = _redo_stack.pop_back()
	var success: bool = command.execute()

	if success:
		command.is_executed = true
		_undo_stack.append(command)
		EventBus.command_redone.emit(command)
		_emit_state_changed()
	else:
		# Failed to redo, put it back
		_redo_stack.append(command)

	return success


## Check if undo is available.
func can_undo() -> bool:
	return not _undo_stack.is_empty()


## Check if redo is available.
func can_redo() -> bool:
	return not _redo_stack.is_empty()


## Clear all history.
func clear_history() -> void:
	_undo_stack.clear()
	_redo_stack.clear()
	_emit_state_changed()


## Get the description of the command that would be undone.
func get_undo_description() -> String:
	if _undo_stack.is_empty():
		return ""
	return _undo_stack[-1].description


## Get the description of the command that would be redone.
func get_redo_description() -> String:
	if _redo_stack.is_empty():
		return ""
	return _redo_stack[-1].description


func _emit_state_changed() -> void:
	EventBus.undo_redo_state_changed.emit(can_undo(), can_redo())
