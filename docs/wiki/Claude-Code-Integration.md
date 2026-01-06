# Claude Code Integration

This document outlines how Claude Code is integrated into the development workflow for maximum AI-assisted productivity.

## Overview

Claude Code serves as the primary development assistant, capable of:
- Writing and editing GDScript code
- Creating and modifying Godot scenes (.tscn)
- Designing game systems and architecture
- Debugging and optimization
- Creating 3D assets via Blender MCP

---

## Integration Methods

### 1. Direct File Editing (Default)

Claude Code can directly read and edit all text-based Godot files:

| File Type | Extension | Claude Can Edit |
|-----------|-----------|-----------------|
| Scripts | `.gd` | Full control |
| Scenes | `.tscn` | Full control |
| Resources | `.tres` | Full control |
| Project settings | `project.godot` | Full control |
| Shaders | `.gdshader` | Full control |

**Example workflow:**
```
You: "Add a new resource type for aluminum ore"
Claude: Creates resources/resources/aluminum_ore.tres
        Updates scripts/autoload/resource_manager.gd
        Adds to relevant production chains
```

### 2. Godot MCP Server (Enhanced Integration)

MCP (Model Context Protocol) enables real-time communication between Claude and Godot.

**Available MCP Servers:**

| Server | Features | Link |
|--------|----------|------|
| **Godot-MCP** | Scene control, debugging, screenshots | [github.com/ee0pdt/Godot-MCP](https://github.com/ee0pdt/Godot-MCP) |
| **godot-mcp** | Launch editor, run projects | [github.com/Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) |
| **GDAI MCP** | Full integration, scene creation | [gdaimcp.com](https://gdaimcp.com/) |

**Setup (Godot-MCP):**
```bash
# Clone the MCP server
git clone https://github.com/ee0pdt/Godot-MCP.git

# Install in Godot
# Copy addons/godot_mcp to your project's addons/
# Enable in Project Settings > Plugins

# Configure Claude Code
# Add to ~/.config/claude-code/config.json or use /mcp command
```

**MCP Capabilities:**
- Take screenshots of the running game
- Inspect scene tree
- Read node properties
- Execute GDScript in editor
- Create/modify scenes programmatically

### 3. Blender MCP (3D Asset Creation)

Claude can create and modify 3D models in Blender.

**Setup:**
```bash
# Install Blender MCP
git clone https://github.com/ahujasid/blender-mcp

# In Blender:
# 1. Open Preferences > Add-ons
# 2. Install from file: blender-mcp
# 3. Enable "Blender MCP"
# 4. In sidebar (N), find "Blender MCP" tab
# 5. Click "Start MCP Server"
```

**Blender MCP Capabilities:**
- Create primitive shapes and combine them
- Apply modifiers (bevel, subdivision, array)
- Set up materials and colors
- Export to .glb for Godot
- Generate procedural models via Python

**Example:**
```
You: "Create a Soviet-style apartment building, 5 floors, with balconies"
Claude: Uses Blender MCP to:
        1. Create box primitive
        2. Scale to building proportions
        3. Add balcony extrusions
        4. Apply concrete material
        5. Export as buildings/apartment_block.glb
```

---

## CLAUDE.md Project Context

The `CLAUDE.md` file in the project root provides context to Claude about the project.

**Location:** `/soviet-city-builder/CLAUDE.md`

**Purpose:**
- Define project architecture
- Establish coding conventions
- Track current focus areas
- Document key systems
- Note known issues

**Claude reads this file automatically** when working in the project directory.

---

## AI Development Workflows

### Workflow 1: Feature Development

```
1. Describe feature to Claude
   "I need a storage building that can hold multiple resource types"

2. Claude explores existing code
   - Reads building_base.gd
   - Checks resource system
   - Reviews similar buildings

3. Claude proposes implementation
   - New StorageBuilding class
   - Resource capacity system
   - UI for inventory display

4. You approve or adjust

5. Claude implements
   - Creates scripts/buildings/storage_building.gd
   - Creates scenes/buildings/storage.tscn
   - Updates CLAUDE.md with new system docs
```

### Workflow 2: Debugging

```
1. Describe the bug
   "Trucks are getting stuck at intersections"

2. Claude investigates
   - Reads vehicle_base.gd
   - Checks pathfinding code
   - Requests screenshot via MCP (if available)

3. Claude identifies issue
   - Explains root cause
   - Proposes fix

4. Claude implements fix
   - Modifies relevant code
   - Adds edge case handling
```

### Workflow 3: Learning While Building

```
1. Ask Claude to implement something
   "Add camera controls that let me pan, zoom, and rotate"

2. Claude implements it

3. Ask for explanation
   "Explain how the camera rotation works"

4. Claude explains the code
   - Breaks down each function
   - Explains Godot concepts used
   - Suggests documentation to read
```

### Workflow 4: Asset Creation

```
1. Describe asset needed
   "I need a coal mine building, industrial style, with a conveyor"

2. Claude uses Blender MCP
   - Creates base structure
   - Adds details
   - Sets up materials

3. Export to Godot
   - Saves as .glb
   - Creates scene with colliders
   - Wires up to building system
```

---

## Best Practices

### DO:
- Keep CLAUDE.md updated with current focus
- Ask Claude to explain code you don't understand
- Use Claude for boilerplate and repetitive code
- Let Claude handle file organization
- Request code reviews from Claude

### DON'T:
- Accept code without understanding it
- Skip testing Claude's implementations
- Forget to update CLAUDE.md after major changes
- Ignore Claude's architectural suggestions without considering them

---

## Prompt Patterns

### For New Features
```
"Implement [feature] that:
- Does X
- Handles Y edge case
- Integrates with Z system
Follow the existing patterns in [similar_file.gd]"
```

### For Bug Fixes
```
"There's a bug where [description].
Steps to reproduce:
1. Do X
2. Then Y
3. Bug occurs

Expected: [expected behavior]
Actual: [actual behavior]"
```

### For Refactoring
```
"Refactor [system] to:
- Improve [aspect]
- Maintain existing functionality
- Follow [pattern]
Don't change [specific thing to preserve]"
```

### For Learning
```
"Implement [feature] and explain:
1. Why you chose this approach
2. What Godot concepts are used
3. How I could extend this later"
```

---

## Troubleshooting

### Claude can't find files
- Make sure you're in the project directory
- Check file paths are correct
- Verify .gitignore isn't hiding needed files

### MCP not connecting
- Ensure MCP server is running in Godot/Blender
- Check port conflicts (default: 9876 for Blender, varies for Godot)
- Restart the MCP server

### Claude making incorrect assumptions
- Update CLAUDE.md with more context
- Provide relevant code snippets in your prompt
- Be specific about constraints and requirements

---

## Future Possibilities

### Planned Integrations
- [ ] Custom MCP tools for game-specific operations
- [ ] Automated testing via Claude
- [ ] Asset generation pipeline
- [ ] Documentation generation

### Experimental Ideas
- Voice-to-code via Claude
- Automated playtesting analysis
- Procedural content generation
- Bug prediction from code patterns
