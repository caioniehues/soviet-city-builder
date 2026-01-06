# Technical Specifications

## Engine & Technology Stack

### Core Engine
| Component | Choice | Rationale |
|-----------|--------|-----------|
| **Game Engine** | Godot 4.5+ | Best Linux support, text-based files, excellent Claude Code integration |
| **Primary Language** | GDScript | Python-like, fast iteration, AI can fully assist |
| **Performance Code** | Rust (gdext) | Memory-safe, excellent tooling, better than C++ for this project |
| **Graphics API** | Vulkan | Native Linux, future-proof |

### Why Rust over C++?
| Aspect | Rust | C++ |
|--------|------|-----|
| Memory safety | Compile-time guaranteed | Manual |
| Build system | Cargo (simple) | CMake (complex) |
| Error handling | Result types | Exceptions |
| Learning curve | Moderate | Steep |
| GDExtension support | gdext (excellent) | godot-cpp (excellent) |

### AI-Assisted Development
| Tool | Purpose |
|------|---------|
| **Claude Code** | Primary development assistant |
| **Godot MCP** | Claude <-> Godot editor integration |
| **Blender MCP** | Claude <-> Blender 3D modeling |

### Graphics Pipeline
| Tool | Purpose |
|------|---------|
| **Blender 4+** | 3D modeling and asset creation |
| **Meshy AI** | Text-to-3D generation (free tier) |
| **Poly Haven** | Free CC0 textures and HDRIs |
| **Dream Textures** | AI texture generation in Blender |

---

## Key Architectural Decisions

### Map Scale: 10km+ x 10km+
Requires from day one:
- **Chunk-based world** (256m x 256m chunks)
- **Streaming system** (load/unload based on camera)
- **LOD system** (3+ levels for buildings and terrain)
- **Spatial partitioning** (for entity queries)

### Multiplayer-Ready Patterns
Even for single-player, using patterns that enable future multiplayer:
- **Deterministic simulation** (fixed timestep, integer math for game logic)
- **Command pattern** (all state changes via commands)
- **Separable game state** (can be serialized/synced)

### Performance Targets
| Metric | Target |
|--------|--------|
| Citizens | 10,000+ at 60 FPS |
| Vehicles | 1,000+ simultaneously |
| Buildings | 5,000+ on map |
| Map size | 10km x 10km minimum |
| Frame time | <16.67ms (60 FPS) |

---

## File Formats

### Godot-Specific
| Extension | Purpose | Text/Binary |
|-----------|---------|-------------|
| `.tscn` | Scene files | Text (AI-editable) |
| `.gd` | GDScript source | Text (AI-editable) |
| `.tres` | Resources | Text (AI-editable) |
| `.import` | Import settings | Text (gitignored) |

### Assets
| Extension | Purpose |
|-----------|---------|
| `.glb` | 3D models (GLTF binary) |
| `.png` | Textures |
| `.ogg` | Audio (music, ambience) |
| `.wav` | Audio (short SFX) |

---

## Code Architecture

### Directory Structure
```
soviet-city-builder/
├── CLAUDE.md                 # AI context file
├── project.godot             # Godot project
├── scripts/
│   ├── autoload/             # Singletons (GameState, Economy)
│   ├── core/                 # Base classes, systems
│   ├── buildings/            # Building-specific scripts
│   ├── vehicles/             # Vehicle-specific scripts
│   └── ui/                   # UI controllers
├── scenes/
│   ├── main.tscn             # Main game scene
│   ├── buildings/            # Building prefabs
│   └── vehicles/             # Vehicle prefabs
├── resources/
│   ├── buildings/            # BuildingData resources
│   ├── resources/            # ResourceType definitions
│   └── recipes/              # Production recipes
└── assets/
    ├── models/               # 3D models (.glb)
    ├── textures/             # Textures
    └── audio/                # Sound effects, music
```

### Design Patterns Used
- **Composition over inheritance** (Godot nodes)
- **Signals for decoupling** (event-driven)
- **Resources for data** (Godot Resource system)
- **Autoloads for globals** (singletons)
- **Command pattern** (for undo/redo, networking)
- **Entity Component System concepts** (for large entity counts)

---

## Simulation Architecture

### Fixed Timestep
```gdscript
const SIMULATION_HZ: int = 20  # 20 ticks per second
const TICK_DELTA: float = 1.0 / SIMULATION_HZ

func _physics_process(delta: float) -> void:
    _accumulator += delta
    while _accumulator >= TICK_DELTA:
        _simulation_tick()
        _accumulator -= TICK_DELTA
```

### Entity Management
```
Spatial Grid (for queries)
├── Cell (0,0) -> [Building, Building, Vehicle]
├── Cell (0,1) -> [Building]
├── Cell (1,0) -> [Vehicle, Vehicle]
└── ...

Chunk System (for streaming)
├── Chunk (0,0) -> Loaded (near camera)
├── Chunk (0,1) -> Loaded
├── Chunk (1,0) -> LOD only
└── Chunk (2,0) -> Unloaded
```

---

## Graphics Specifications

### Art Style
- **Realistic low-poly** (like W&R:SR)
- **Soviet/brutalist aesthetic**
- **Muted color palette** (grays, concrete, industrial)
- **Weathered/aged materials**

### Post-Processing Stack
1. Desaturation (0.3-0.4)
2. Cold color grading
3. Film grain (subtle)
4. Vignette (subtle)
5. Ambient occlusion

### LOD Distances
| Level | Distance | Detail |
|-------|----------|--------|
| LOD0 | 0-100m | Full detail |
| LOD1 | 100-300m | Reduced |
| LOD2 | 300-800m | Simplified |
| LOD3/Impostor | 800m+ | Billboard |

---

## Performance Guidelines

### GDScript Best Practices
- Use static typing everywhere
- Cache node references in `_ready()`
- Avoid `get_node()` in loops
- Use object pooling for frequently created objects
- Profile before optimizing

### When to Use Rust (GDExtension)
Only if GDScript profiling shows bottleneck (>5ms in a system):
- Pathfinding algorithms (A*, flow fields)
- Large entity iteration (10k+ entities)
- Complex math operations
- Serialization/deserialization
- Procedural generation

### Memory Guidelines
- Pool frequently allocated objects
- Use Resources for shared data
- Stream chunks to limit memory
- Target: <4GB RAM usage
