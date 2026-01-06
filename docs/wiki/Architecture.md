# Architecture

## Language Strategy

### Primary: GDScript
Used for:
- Game logic and systems
- UI and menus
- Prototyping
- Most gameplay code

### Performance: Rust via gdext (Recommended over C++)

For performance-critical code, we use **Rust** instead of C++:

| Aspect | Rust (gdext) | C++ |
|--------|--------------|-----|
| Memory safety | Compile-time guaranteed | Manual |
| Learning curve | Moderate (you know Java) | Steep |
| GDExtension support | Excellent (gdext) | Excellent |
| Error handling | Result types | Exceptions/error codes |
| Tooling | Cargo (excellent) | CMake (complex) |
| Community | Growing, helpful | Large, fragmented |

**Why Rust over C++:**
1. **Memory safety** - No segfaults, no use-after-free
2. **Cargo** - Simple dependency management (vs CMake hell)
3. **Better errors** - Compiler catches bugs before runtime
4. **Your background** - Java dev will find Rust more familiar than C++
5. **Modern language** - Enums, pattern matching, traits

### gdext Setup
```bash
# In your project root
cargo init --lib native

# Cargo.toml
[lib]
crate-type = ["cdylib"]

[dependencies]
godot = "0.2"  # Check for latest version
```

```rust
// native/src/lib.rs
use godot::prelude::*;

struct SovietCityBuilder;

#[gdextension]
unsafe impl ExtensionLibrary for SovietCityBuilder {}

// Example: High-performance pathfinding
#[derive(GodotClass)]
#[class(base=Node)]
struct PathfindingSystem {
    base: Base<Node>,
    grid: Vec<Vec<bool>>,
}

#[godot_api]
impl INode for PathfindingSystem {
    fn init(base: Base<Node>) -> Self {
        Self {
            base,
            grid: Vec::new(),
        }
    }
}

#[godot_api]
impl PathfindingSystem {
    #[func]
    fn find_path(&self, from: Vector2i, to: Vector2i) -> PackedVector2Array {
        // Fast Rust pathfinding here
        PackedVector2Array::new()
    }
}
```

### When to Use Rust
Only when GDScript profiling shows bottleneck:
- Pathfinding (A*, flow fields)
- Large entity iteration (10k+ entities)
- Economic simulation calculations
- Procedural generation
- Serialization/deserialization

**Rule:** Start with GDScript. Only port to Rust if profiler shows >5ms in a single system.

---

## Core Systems Architecture

### Autoloads (Singletons)

```
GameState          - Global game state, time, speed
├── ResourceManager - Resource type definitions
├── Economy        - Global resource tracking, trade
├── WorldManager   - Chunk loading, entity registry
└── EventBus       - Global signals for decoupling
```

### Entity Hierarchy

```
Building (base class)
├── ProductionBuilding
│   ├── Mine
│   ├── Factory
│   └── Farm
├── StorageBuilding
│   ├── Warehouse
│   └── Silo
├── ResidentialBuilding
│   └── ApartmentBlock
├── ServiceBuilding
│   ├── Hospital
│   ├── School
│   └── Shop
└── InfrastructureBuilding
    ├── PowerPlant
    ├── HeatingPlant
    └── WaterTower

Vehicle (base class)
├── Truck
├── Train
└── Bus

Infrastructure
├── Road
├── Rail
├── Pipe
└── PowerLine
```

### Data Flow

```
Input (User/Time)
       │
       ▼
┌─────────────────┐
│  Command Queue  │  ← All state changes go through commands
└─────────────────┘
       │
       ▼
┌─────────────────┐
│   Simulation    │  ← Fixed timestep update
│   (20 ticks/s)  │
└─────────────────┘
       │
       ▼
┌─────────────────┐
│   Game State    │  ← Single source of truth
└─────────────────┘
       │
       ▼
┌─────────────────┐
│   Rendering     │  ← Interpolated for smooth visuals
│   (60 FPS)      │
└─────────────────┘
```

---

## Chunk System

### World Division
```
World (10km x 10km)
└── Chunks (256m x 256m = ~40 x 40 chunks)
    └── Cells (1m x 1m = 256 x 256 per chunk)
```

### Chunk States
```gdscript
enum ChunkState {
    UNLOADED,      # Not in memory
    LOADING,       # Async loading
    LOD_ONLY,      # Only terrain LOD, no entities
    LOADED,        # Full simulation
    UNLOADING      # Async unloading
}
```

### Loading Strategy
```
Camera Position
       │
       ▼
┌──────────────────────────────────────┐
│  Load Radius (3 chunks) = LOADED    │
│  ┌────────────────────────────────┐ │
│  │ LOD Radius (6 chunks)          │ │
│  │ = LOD_ONLY                     │ │
│  │  ┌──────────────────────────┐  │ │
│  │  │ Unload (>8 chunks)       │  │ │
│  │  │ = UNLOADED               │  │ │
│  │  └──────────────────────────┘  │ │
│  └────────────────────────────────┘ │
└──────────────────────────────────────┘
```

---

## Command Pattern

All game state changes go through commands for:
- Undo/redo support
- Deterministic replay (multiplayer)
- Save/load simplicity

```gdscript
class_name GameCommand
extends RefCounted

var timestamp: int
var executed: bool = false

func execute() -> void:
    pass  # Override

func undo() -> void:
    pass  # Override

# Example
class_name PlaceBuildingCommand
extends GameCommand

var building_type: BuildingData
var position: Vector3i

func execute() -> void:
    WorldManager.place_building(building_type, position)
    executed = true

func undo() -> void:
    WorldManager.remove_building(position)
    executed = false
```

---

## Signal Bus Pattern

Decouple systems using a global event bus:

```gdscript
# autoload/event_bus.gd
extends Node

signal building_placed(building: Building, position: Vector3i)
signal building_removed(building: Building)
signal resource_produced(type: ResourceType, amount: int, building: Building)
signal vehicle_arrived(vehicle: Vehicle, destination: Building)
signal citizen_need_unmet(citizen: Citizen, need: Need)
signal day_changed(day: int)
signal economy_updated()
```

Usage:
```gdscript
# In a building
func _on_production_complete() -> void:
    EventBus.resource_produced.emit(output_type, output_amount, self)

# In UI
func _ready() -> void:
    EventBus.resource_produced.connect(_on_resource_produced)
```

---

## File Organization

```
soviet-city-builder/
├── CLAUDE.md
├── project.godot
├── native/                    # Rust GDExtension
│   ├── Cargo.toml
│   └── src/
│       ├── lib.rs
│       ├── pathfinding.rs
│       └── simulation.rs
├── scripts/
│   ├── autoload/
│   │   ├── game_state.gd
│   │   ├── economy.gd
│   │   ├── world_manager.gd
│   │   ├── resource_manager.gd
│   │   └── event_bus.gd
│   ├── core/
│   │   ├── command.gd
│   │   ├── building_base.gd
│   │   ├── vehicle_base.gd
│   │   ├── chunk.gd
│   │   └── spatial_grid.gd
│   └── ...
└── ...
```
