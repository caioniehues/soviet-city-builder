class_name RemoveBuildingCommand
extends Command
## Command to remove a building from the world.

var grid_position: Vector3i
var _removed_building_data: Resource = null
var _removed_rotation: int = 0
var _removed_origin: Vector3i


func _init(p_grid_position: Vector3i) -> void:
	grid_position = p_grid_position
	description = "Remove building at %s" % str(grid_position)


func execute() -> bool:
	var cell_data := WorldManager.get_cell_data(grid_position)
	if cell_data == null or cell_data.building == null:
		return false

	var building := cell_data.building
	_removed_origin = cell_data.building_origin
	_removed_rotation = building.get_meta("rotation_index", 0)
	_removed_building_data = building.get_meta("building_data", null)

	return WorldManager.remove_building(grid_position)


func undo() -> bool:
	if _removed_building_data == null:
		push_warning("Cannot undo RemoveBuildingCommand: no building data stored")
		return false

	var building := WorldManager.place_building(_removed_building_data, _removed_origin, _removed_rotation)
	return building != null


func to_dict() -> Dictionary:
	var data := super.to_dict()
	data["grid_position"] = {"x": grid_position.x, "y": grid_position.y, "z": grid_position.z}
	return data
