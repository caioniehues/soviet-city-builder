class_name PlacementManager
extends Node
## Manages the building placement workflow.

@export var grid_controller: GridPlacementController
@export var ghost: BuildingGhost

var _current_grid_pos: Vector3i = Vector3i.ZERO


func _ready() -> void:
	EventBus.placement_mode_entered.connect(_on_placement_mode_entered)
	EventBus.placement_mode_exited.connect(_on_placement_mode_exited)

	if grid_controller:
		grid_controller.grid_position_changed.connect(_on_grid_position_changed)


func _unhandled_input(event: InputEvent) -> void:
	if GameState.current_input_mode != GameState.InputMode.PLACEMENT:
		if event.is_action_pressed("undo"):
			CommandManager.get_instance().undo()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("redo"):
			CommandManager.get_instance().redo()
			get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed:
			match mouse_event.button_index:
				MOUSE_BUTTON_LEFT:
					_try_place_building()
					get_viewport().set_input_as_handled()
				MOUSE_BUTTON_RIGHT:
					GameState.exit_placement_mode()
					get_viewport().set_input_as_handled()

	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo:
			match key_event.keycode:
				KEY_R:
					_rotate_ghost()
					get_viewport().set_input_as_handled()
				KEY_ESCAPE:
					GameState.exit_placement_mode()
					get_viewport().set_input_as_handled()
				KEY_B:
					GameState.exit_placement_mode()
					get_viewport().set_input_as_handled()


func _input(event: InputEvent) -> void:
	if GameState.current_input_mode == GameState.InputMode.NORMAL:
		if event is InputEventKey:
			var key_event := event as InputEventKey
			if key_event.pressed and not key_event.echo and key_event.keycode == KEY_B:
				_enter_test_placement_mode()
				get_viewport().set_input_as_handled()


func _try_place_building() -> void:
	if not grid_controller or not grid_controller.is_position_valid():
		return

	var building_data := GameState.selected_building_data
	if building_data == null:
		return

	var grid_pos := _current_grid_pos
	var rotation := ghost.get_rotation_index() if ghost else GameState.placement_rotation

	var validation_error := WorldManager.validate_placement(building_data, grid_pos, rotation)
	if validation_error != "":
		return

	var cmd := PlaceBuildingCommand.new(building_data, grid_pos, rotation)
	CommandManager.get_instance().execute(cmd)

	_update_ghost_validity()


func _rotate_ghost() -> void:
	if ghost:
		ghost.rotate_building()
		GameState.placement_rotation = ghost.get_rotation_index()
		_update_ghost_validity()


func _on_placement_mode_entered(building_data: Resource) -> void:
	if ghost:
		var size := Vector2i(1, 1)
		if building_data and "grid_size" in building_data:
			size = building_data.grid_size
		ghost.set_building_size(size)
		ghost.reset_rotation()
		ghost.visible = true
		_update_ghost_validity()


func _on_placement_mode_exited() -> void:
	if ghost:
		ghost.visible = false


func _on_grid_position_changed(new_pos: Vector3i) -> void:
	_current_grid_pos = new_pos
	if ghost and ghost.visible:
		ghost.set_grid_position(new_pos)
		_update_ghost_validity()

	EventBus.placement_preview_updated.emit(new_pos, _is_placement_valid())


func _update_ghost_validity() -> void:
	if ghost:
		ghost.set_valid(_is_placement_valid())


func _is_placement_valid() -> bool:
	var building_data := GameState.selected_building_data
	if building_data == null:
		return false

	var rotation := ghost.get_rotation_index() if ghost else GameState.placement_rotation
	var validation_error := WorldManager.validate_placement(building_data, _current_grid_pos, rotation)
	return validation_error == ""


func _enter_test_placement_mode() -> void:
	var test_data: BuildingData = null

	if ResourceLoader.exists("res://resources/buildings/placeholder_building.tres"):
		test_data = load("res://resources/buildings/placeholder_building.tres")

	if test_data == null:
		test_data = BuildingData.new()
		test_data.id = "test_building"
		test_data.display_name = "Test Building"
		test_data.grid_size = Vector2i(1, 1)
		test_data.placeholder_color = Color(0.5, 0.5, 0.7)

	GameState.enter_placement_mode(test_data)
