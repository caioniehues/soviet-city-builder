class_name PlaceBuildingCommand
extends Command
## Command to place a building at a grid position.

var building_data: Resource
var grid_position: Vector3i
var rotation_index: int
var _placed_building: Node3D = null


func _init(p_building_data: Resource, p_grid_position: Vector3i, p_rotation_index: int = 0) -> void:
	building_data = p_building_data
	grid_position = p_grid_position
	rotation_index = p_rotation_index
	description = "Place building at %s" % str(grid_position)


func execute() -> bool:
	_placed_building = WorldManager.place_building(building_data, grid_position, rotation_index)
	return _placed_building != null


func undo() -> bool:
	if _placed_building == null:
		return false
	return WorldManager.remove_building(grid_position)


func to_dict() -> Dictionary:
	var data := super.to_dict()
	data["building_data_path"] = building_data.resource_path if building_data else ""
	data["grid_position"] = {"x": grid_position.x, "y": grid_position.y, "z": grid_position.z}
	data["rotation_index"] = rotation_index
	return data
