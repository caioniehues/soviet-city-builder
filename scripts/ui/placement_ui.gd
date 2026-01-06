class_name PlacementUI
extends Control
## Displays current grid coordinates and placement status.

@onready var coord_label: Label = $MarginContainer/VBoxContainer/CoordinateLabel
@onready var status_label: Label = $MarginContainer/VBoxContainer/StatusLabel
@onready var mode_label: Label = $MarginContainer/VBoxContainer/ModeLabel


func _ready() -> void:
	EventBus.grid_cell_hovered.connect(_on_grid_cell_hovered)
	EventBus.placement_mode_entered.connect(_on_placement_mode_entered)
	EventBus.placement_mode_exited.connect(_on_placement_mode_exited)
	EventBus.input_mode_changed.connect(_on_input_mode_changed)
	EventBus.building_placed.connect(_on_building_placed)

	_update_mode_label()
	status_label.visible = false


func _on_grid_cell_hovered(grid_pos: Vector3i) -> void:
	coord_label.text = "Grid: (%d, %d)" % [grid_pos.x, grid_pos.z]


func _on_placement_mode_entered(_building_data: Resource) -> void:
	status_label.text = "[LMB] Place | [RMB] Cancel | [R] Rotate | [B] Exit"
	status_label.visible = true
	_update_mode_label()


func _on_placement_mode_exited() -> void:
	status_label.visible = false
	_update_mode_label()


func _on_input_mode_changed(_mode: String) -> void:
	_update_mode_label()


func _on_building_placed(_building: Node3D, _grid_pos: Vector3i) -> void:
	pass


func _update_mode_label() -> void:
	match GameState.current_input_mode:
		GameState.InputMode.NORMAL:
			mode_label.text = "Mode: Normal | [B] Build"
		GameState.InputMode.PLACEMENT:
			mode_label.text = "Mode: Placement"
		GameState.InputMode.DEMOLITION:
			mode_label.text = "Mode: Demolition"
