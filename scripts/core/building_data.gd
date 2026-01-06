class_name BuildingData
extends Resource
## Data resource defining a building type.
##
## Create .tres files in resources/buildings/ for each building type.

@export_group("Identity")
## Unique identifier for this building type.
@export var id: String = ""
## Display name shown in UI.
@export var display_name: String = ""
## Description shown in tooltips.
@export var description: String = ""
## Category for UI grouping.
@export var category: String = "misc"

@export_group("Grid")
## Size in grid cells (width x depth).
@export var grid_size: Vector2i = Vector2i(1, 1)
## Whether this building can be rotated.
@export var can_rotate: bool = true

@export_group("Scene")
## The scene to instantiate for this building.
@export var scene: PackedScene
## Preview mesh for placement mode (optional, uses scene if not set).
@export var preview_mesh: Mesh

@export_group("Visuals")
## Icon for UI.
@export var icon: Texture2D
## Base color for placeholder buildings.
@export var placeholder_color: Color = Color(0.6, 0.6, 0.7)
