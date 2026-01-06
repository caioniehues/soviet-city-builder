# Soviet City Builder

<p align="center">
  <img src="docs/images/banner.png" alt="Soviet City Builder" width="800">
  <br>
  <em>Build. Plan. Industrialize.</em>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#installation">Installation</a> •
  <a href="#development">Development</a> •
  <a href="#roadmap">Roadmap</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## Overview

**Soviet City Builder** is a deep economic simulation and city-building game inspired by *Workers & Resources: Soviet Republic*. Plan your industrial empire, manage complex supply chains, and build a thriving socialist republic from the ground up.

Built with modern technology for **superior performance** and **better graphics** than its inspiration, while maintaining the hardcore simulation depth that fans love.

### Why Another Soviet City Builder?

| Problem with existing games | Our Solution |
|----------------------------|--------------|
| Poor late-game performance | Chunk-based streaming, spatial partitioning, Rust for hot paths |
| Limited map sizes | 10km+ maps with LOD system from day one |
| Single-threaded simulation | Designed for parallelism, deterministic simulation |
| Dated graphics | Modern Vulkan renderer, PBR materials, volumetric effects |

---

## Features

### Core Gameplay
- **Deep Economic Simulation** - 25+ resource types with realistic production chains
- **Complex Logistics** - Trucks, trains, conveyors, and pipelines
- **Citizen Management** - Housing, employment, education, healthcare, happiness
- **Large-Scale Building** - Cities with thousands of buildings and 10,000+ citizens

### Production Chains
```
Iron Ore ──┬──→ Steel Mill ──→ Steel ──→ Mechanical Factory ──→ Parts
Coal ──────┘                      │
                                  └──→ Vehicle Factory ──→ Trucks, Buses
```

### Technical Excellence
- **Native Linux** - First-class Linux support, not a port
- **Performant** - Handles massive cities without slowdown
- **Modern Graphics** - Vulkan-based rendering with PBR and post-processing
- **Moddable** - GDScript for easy modding

---

## Screenshots

> *Screenshots will be added as development progresses*

---

## Tech Stack

| Component | Technology |
|-----------|------------|
| Engine | Godot 4.5+ |
| Primary Language | GDScript |
| Performance Code | Rust (via gdext) |
| Graphics API | Vulkan |
| 3D Modeling | Blender 5+ |
| Development | AI-assisted (Claude Code) |

---

## Installation

### Requirements
- **OS:** Linux (native), Windows/Mac (future)
- **GPU:** Vulkan 1.2+ compatible
- **RAM:** 8GB minimum, 16GB recommended
- **Storage:** 2GB (Early Access), 10GB (Full Release)

### From Source

```bash
# Clone the repository
git clone https://github.com/yourusername/soviet-city-builder.git
cd soviet-city-builder

# Open in Godot
godot project.godot

# Or run directly
godot --path .
```

### Releases

> *Releases will be available on Steam and itch.io*

---

## Development

### Prerequisites

- [Godot 4.3+](https://godotengine.org/download/linux/)
- [Blender 4+](https://www.blender.org/download/) (for asset creation)
- [Rust](https://rustup.rs/) (for performance-critical code)

### Project Structure

```
soviet-city-builder/
├── CLAUDE.md              # AI development context
├── project.godot          # Godot project file
├── native/                # Rust GDExtension code
├── scripts/               # GDScript source
│   ├── autoload/          # Global singletons
│   ├── core/              # Core systems
│   ├── buildings/         # Building logic
│   └── vehicles/          # Vehicle logic
├── scenes/                # Godot scenes
├── resources/             # Data resources
├── assets/                # Art, audio, fonts
└── docs/wiki/             # Documentation
```

### AI-Assisted Development

This project uses **Claude Code** for AI-assisted development:
- Direct code editing and generation
- Godot MCP for editor integration
- Blender MCP for 3D asset creation

See [Claude Code Integration](docs/wiki/Claude-Code-Integration.md) for details.

### Building Rust Extensions

```bash
cd native
cargo build --release
# Output: target/release/libsoviet_city_builder.so
```

---

## Roadmap

| Phase | Timeline | Status |
|-------|----------|--------|
| **Foundation** | Week 1 | 🔄 In Progress |
| **Prototype** | Weeks 2-7 | ⏳ Planned |
| **Core Systems** | Weeks 8-16 | ⏳ Planned |
| **Depth & Scale** | Weeks 17-28 | ⏳ Planned |
| **Polish** | Weeks 29-38 | ⏳ Planned |
| **Release** | Weeks 39-48 | ⏳ Planned |

### Current Focus
- [x] Environment setup
- [x] Project structure
- [ ] Camera controls
- [ ] Grid-based building placement
- [ ] Basic resource system

See [Full Roadmap](docs/wiki/Roadmap.md) for detailed breakdown.

---

## Documentation

Full documentation available in the [Project Wiki](docs/wiki/Home.md):

- [Roadmap](docs/wiki/Roadmap.md) - Development timeline
- [Technical Specs](docs/wiki/Technical-Specifications.md) - Engine and architecture
- [Architecture](docs/wiki/Architecture.md) - Code design patterns
- [Resources](docs/wiki/Resources.md) - Game resources and production chains
- [Claude Code Integration](docs/wiki/Claude-Code-Integration.md) - AI development workflow

---

## Contributing

This is currently a solo project with AI assistance. Contribution guidelines will be added if/when the project opens for contributions.

### Reporting Issues
- Use GitHub Issues for bug reports
- Include system info (OS, GPU, Godot version)
- Provide steps to reproduce

---

## License

*License to be determined*

---

## Acknowledgments

- **Workers & Resources: Soviet Republic** by 3Division - The inspiration
- **Godot Engine** - Open source game engine
- **Claude** by Anthropic - AI development assistant
- **Kenney.nl** - Free game assets
- **Poly Haven** - CC0 textures and HDRIs

---

<p align="center">
  <strong>Build the future. Manage the present. Plan the economy.</strong>
  <br><br>
  Made with ❤️ and AI assistance
</p>
