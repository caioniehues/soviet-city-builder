# Development Roadmap

## Timeline Summary

| Phase | Weeks | Duration | Key Milestone |
|-------|-------|----------|---------------|
| **0: Foundation** | 1 | 1 week | Environment ready, first scene |
| **1: Prototype** | 2-7 | 6 weeks | Basic economy loop working |
| **2: Core Systems** | 8-16 | 9 weeks | Playable city builder |
| **3: Depth** | 17-28 | 12 weeks | Full simulation, rail, 10k citizens |
| **4: Polish** | 29-38 | 10 weeks | Content complete, polished |
| **5: Release** | 39-48 | 10 weeks | Steam launch |

**Total: ~48 weeks (1 year) at 30+ hours/week**

---

## Phase 0: Foundation (Week 1)

**Goal:** Set up environment and start building immediately

### Days 1-2: Environment Setup
- [ ] Install Godot 4.3+ on Linux
- [ ] Install Blender 4.x
- [ ] Set up Claude Code with Godot MCP
- [ ] Set up Blender MCP
- [ ] Create project repository with Git
- [ ] Create CLAUDE.md project context file

### Days 3-7: First Playable Scene
- [ ] Create main scene with terrain plane
- [ ] Implement camera controls (pan, zoom, rotate)
- [ ] Add grid visualization
- [ ] Place first building (cube placeholder)
- [ ] Basic UI showing coordinates

**Deliverable:** Flyable camera over terrain, can place cubes on grid

---

## Phase 1: Prototype Core Loop (Weeks 2-7)

**Goal:** Minimal playable loop with basic economy + large world foundation

### Week 2-3: World Foundation (Large Map Architecture)
- [ ] Chunk-based terrain system (for 10km+ maps)
  - World divided into 256m x 256m chunks
  - Only nearby chunks fully loaded
  - LOD terrain for distant chunks
- [ ] Grid-based building placement within chunks
- [ ] Chunk streaming manager (load/unload based on camera)
- [ ] Simple building models (cubes/primitives for now)

### Week 4-5: Basic Economy
- [ ] Resource system (3 types: ore, coal, steel)
- [ ] Resource types as Godot Resources (.tres)
- [ ] Simple production building (mine -> ore)
- [ ] Storage building concept
- [ ] Basic resource UI display

### Week 6-7: First Transport
- [ ] Road placement system (stores connections in graph)
- [ ] Single truck type
- [ ] Point-to-point transport (simple pathfinding)
- [ ] Loading/unloading at buildings
- [ ] Vehicle pooling (for performance with many trucks later)

**Deliverable:** Large explorable terrain, place mines/storage, trucks move resources

**Architecture Notes:**
- Spatial partitioning for all entities
- Chunk-aware building placement
- Graph-based road network (not grid-based)

---

## Phase 2: Core Systems (Weeks 8-16)

**Goal:** Functional city builder with basic simulation

### Weeks 8-9: Pathfinding & Roads
- [ ] Road network as weighted graph
- [ ] Hierarchical A* (HPA*) for large map pathfinding
- [ ] Flow fields for common destinations (factories, storage)
- [ ] Multiple vehicle support with spatial hashing
- [ ] Traffic basics (lane-based, no physics collisions)

### Weeks 10-11: Production Chains
- [ ] Expand to 8-10 resource types
- [ ] Multi-input production (ore + coal -> steel)
- [ ] Production timing and rates (deterministic for future MP)
- [ ] Storage capacity limits
- [ ] Resource transport priorities

### Weeks 12-13: Citizens (Basic)
- [ ] Population as aggregate (not individual simulation yet)
- [ ] Housing buildings with capacity
- [ ] Workers assigned to buildings (job matching)
- [ ] Basic needs (food only)
- [ ] Commute distance affects happiness

### Weeks 14-15: Visual Polish Pass 1
- [ ] Replace primitives with actual building models
- [ ] Soviet aesthetic post-processing shader
- [ ] Basic particle effects (smoke from factories)
- [ ] Time of day lighting
- [ ] Building LOD system (3 levels)

### Week 16: Save/Load & UI
- [ ] Save game state to file (JSON or binary)
- [ ] Load saved games
- [ ] Autosave (async, non-blocking)
- [ ] Proper UI menus
- [ ] Build menu with categories

**Deliverable:** Playable city builder with 10+ buildings, citizens, production chains

**Multiplayer-Ready Patterns:**
- Deterministic simulation (fixed timestep, no floats for game logic)
- Input/command system (all changes via commands, not direct mutation)
- Separable game state (could be synced later)

---

## Phase 3: Depth & Scale (Weeks 17-28)

**Goal:** Full simulation depth, performance optimization

### Weeks 17-19: Rail Transport
- [ ] Rail track placement (spline-based)
- [ ] Train simulation (consists of wagons)
- [ ] Train stations and loading platforms
- [ ] Signal system (block-based, basic)
- [ ] Junctions and switches

### Weeks 20-22: Full Economy
- [ ] 20+ resource types (see [[Resources]])
- [ ] Complete production chains
- [ ] Import/export border crossings
- [ ] Dual currency system (Rubles/Dollars)
- [ ] Economic rebalancing

### Weeks 23-24: Citizen Depth
- [ ] Individual citizen tracking (for visible ones)
- [ ] Aggregate simulation (for thousands)
- [ ] Multiple needs (food, healthcare, education, culture)
- [ ] Happiness/loyalty system
- [ ] Education levels (uneducated -> university)
- [ ] Population growth/decline mechanics

### Weeks 25-26: Utilities
- [ ] Power grid (graph-based distribution)
- [ ] Power plants (coal, oil)
- [ ] Substations and coverage
- [ ] Heating network (optional, adds depth)

### Weeks 27-28: Performance Optimization
- [ ] Profile with Godot profiler + Tracy
- [ ] Identify and optimize bottlenecks
- [ ] GDExtension C++ for hot paths if needed
- [ ] Stress test with 10k+ entities

**Deliverable:** Deep simulation with 50+ buildings, rail, utilities, 10k+ citizens

---

## Phase 4: Polish & Content (Weeks 29-38)

**Goal:** Polished, content-rich game

### Weeks 29-31: Graphics Upgrade
- [ ] Final building models (low-poly realistic)
- [ ] Procedural building variation system
- [ ] Terrain improvements (texturing, details)
- [ ] Weather effects (rain, snow, fog)
- [ ] Volumetric industrial atmosphere

### Weeks 32-34: Content Expansion
- [ ] 50+ building types total
- [ ] Multiple vehicle variants per category
- [ ] Decorations, props, monuments
- [ ] 2-3 map scenarios (different terrain/resources)

### Weeks 35-36: Audio
- [ ] Ambient environmental sounds
- [ ] Building operation sounds
- [ ] Vehicle sounds (engines, horns)
- [ ] UI feedback sounds
- [ ] Background music (optional, Soviet era style)

### Weeks 37-38: Tutorial & UX
- [ ] Interactive tutorial scenario
- [ ] Contextual tooltips
- [ ] Help system / encyclopedia
- [ ] Quality of life (mass selection, templates)
- [ ] Options menu (graphics, audio, controls)

**Deliverable:** Polished game ready for public testing

---

## Phase 5: Release Preparation (Weeks 39-48)

**Goal:** Steam-ready release

### Weeks 39-42: Beta Testing
- [ ] Closed beta with 10-20 testers
- [ ] Bug tracking and fixing
- [ ] Balance adjustments based on feedback
- [ ] Performance testing on various hardware

### Weeks 43-45: Steam Preparation
- [ ] Steam page creation
- [ ] Screenshots and trailer
- [ ] Store description and tags
- [ ] Linux packaging (Flatpak optional)

### Weeks 46-48: Launch
- [ ] Final bug fixes
- [ ] Launch day preparation
- [ ] Community setup (Discord, forums)
- [ ] Post-launch support plan

**Deliverable:** Game released on Steam
