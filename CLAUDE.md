# Soviet City Builder

## Project Overview

City-builder/economic simulation inspired by Workers & Resources: Soviet Republic.
Built with Godot 4.5+ and GDScript, targeting Linux as first-class platform.

**Key Goals:**
- Deep economic simulation (25+ resources, complex production chains)
- Large maps (10km+) with good performance
- Soviet/brutalist aesthetic
- AI-accelerated development

## Tech Stack

| Component | Technology |
|-----------|------------|
| Engine | Godot 4.5+ |
| Primary Language | GDScript |
| Performance Code | Rust (gdext) |
| Graphics | Vulkan |
| 3D Assets | Blender 5+ |

## Architecture Patterns

### Core Principles
- **Composition over inheritance** (Godot nodes)
- **Signals for decoupling** (EventBus pattern)
- **Resources for data** (Godot Resource system)
- **Autoloads for globals** (GameState, Economy, WorldManager)
- **Command pattern** (for undo/redo, future multiplayer)
- **Deterministic simulation** (fixed timestep, integer math where needed)

### Large Map Strategy
- **Chunk-based world** (256m x 256m chunks)
- **Streaming** (load/unload based on camera)
- **Spatial partitioning** (for entity queries)
- **LOD system** (3 levels for buildings)

## Code Conventions

### GDScript
```gdscript
# Always use static typing
var name: String = ""
var count: int = 0
var position: Vector3 = Vector3.ZERO

# PascalCase for classes
class_name BuildingBase

# snake_case for variables and functions
func calculate_production() -> int:
	pass

# Prefix signal handlers with _on_
func _on_button_pressed() -> void:
	pass

# Use @export for editor-configurable values
@export var production_rate: float = 1.0
@export_group("Resources")
@export var input_type: ResourceType
@export var output_type: ResourceType
```

### Signals
```gdscript
# Prefer signals over direct calls for decoupling
signal production_complete(resource: ResourceType, amount: int)

# Use EventBus for cross-system communication
EventBus.building_placed.emit(building, position)
```

## Key Systems

### Autoloads (scripts/autoload/)

| Singleton | Purpose |
|-----------|---------|
| `GameState` | Time, speed, global state |
| `Economy` | Resource tracking, trade |
| `WorldManager` | Chunks, entities, spatial queries |
| `ResourceManager` | Resource type definitions |
| `EventBus` | Global signals |

### Core Classes (scripts/core/)

| Class | Purpose |
|-------|---------|
| `BuildingBase` | Base for all buildings |
| `VehicleBase` | Base for all vehicles |
| `Chunk` | World chunk management |
| `SpatialGrid` | Entity spatial queries |
| `Command` | Base for all game commands |

### Buildings (scripts/buildings/)
Override `_process_production()` in BuildingBase subclasses.

### Vehicles (scripts/vehicles/)
Use pathfinding system, override `_on_destination_reached()`.

## File Structure

```
scripts/
├── autoload/           # Singletons (register in project.godot)
├── core/               # Base classes and systems
├── buildings/          # Building-specific logic
├── vehicles/           # Vehicle-specific logic
├── ui/                 # UI controllers
└── utils/              # Helpers and utilities

scenes/
├── main.tscn           # Main game scene
├── buildings/          # Building prefabs (.tscn)
├── vehicles/           # Vehicle prefabs (.tscn)
└── ui/                 # UI scenes

resources/
├── buildings/          # BuildingData (.tres)
├── resources/          # ResourceType (.tres)
└── recipes/            # ProductionRecipe (.tres)

native/                 # Rust GDExtension (when needed)
├── Cargo.toml
└── src/
```

## Current Phase

**Phase 0: Foundation (Week 1)**
- [x] Environment setup (Godot, Blender)
- [x] Project structure
- [x] Documentation/wiki
- [ ] Camera controls
- [ ] Grid-based placement
- [ ] First building (cube placeholder)

## Current Focus

Setting up the project foundation and implementing basic camera controls.

## Known Issues

*None yet - project just started*

## Performance Notes

- Start with GDScript for everything
- Profile before optimizing
- Only move to Rust if a system takes >5ms per frame
- Candidates for Rust: pathfinding, large entity iteration, serialization

## Resources

- [Project Wiki](docs/wiki/Home.md)
- [Roadmap](docs/wiki/Roadmap.md)
- [Architecture](docs/wiki/Architecture.md)
- [Godot Docs](https://docs.godotengine.org)
- [gdext (Rust)](https://github.com/godot-rust/gdext)
