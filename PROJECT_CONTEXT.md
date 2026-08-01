# Summoning Circle Game - Project Context for LLMs

## Project Overview

This is a **2D Godot 4.7** game prototype where players drag ritual items from a shelf onto a summoning circle. The goal is to match all 6 items to their correct positions on the circle.

- **Engine**: Godot 4.7 (GL Compatibility renderer)
- **Main Scene**: `res://scenes/shelf.tscn`
- **Game Type**: Drag-and-drop puzzle / ritual matching game

---

## Enabled Plugins

### 1. DragAndDrop (Custom Plugin)
**Path**: `res://addons/drag_and_drop/plugin.cfg`  
**Version**: 1.0  
**Author**: Cashew OldDew

**Purpose**: Provides a complete drag-and-drop system with:
- **Draggable** - Attach to any Area2D to make it draggable
- **DropZone** - Attach to any Area2D to make it a drop target
- **DropBehavior** - Extensible resource defining what happens on drop
- **DropAction** - Extensible resource defining how behavior executes
- **DropUtils** - Helper functions for common operations

**Custom Types Registered**:
- `Draggable` (extends Node) - icon: ToolMove.svg
- `DropZone` (extends Node2D) - icon: DropZone.svg

**Built-in DropBehaviors**:
- `drop_behavior_reject` - Reject if occupied, find nearest free spot
- `drop_behavior_replace` - Replace existing occupant
- `drop_behavior_rearrange` - Move occupant to make room

**Snap Styles**:
- `NONE` - Stay at current position
- `CENTER` - Center on DropZone owner
- `SNAP_MARKERS` - Snap to Marker2D children (used in this project)

**Signals** (key ones):
- `drag_started(area)` / `drag_ended(area, drop_spot)` / `state_changed(area, state)` on Draggable
- `drop_evaluated` / `drop_accepted` / `drop_rejected` / `drop_applied` / `occupant_changed` on DropZone

### 2. Godot MCP (Model Context Protocol)
**Path**: `res://addons/godot_mcp/plugin.cfg`  
**Version**: 4.1.0  
**Min Godot**: 4.5

**Purpose**: Enables AI assistant integration via WebSocket server for:
- Scene inspection and manipulation
- Runtime state observation
- Input injection for testing
- Animation control
- Profiling and debugging

**Autoload**: `MCPGameBridge` (singleton at `res://addons/godot_mcp/game_bridge/mcp_game_bridge.gd`)

**Settings** (project.godot `[godot_mcp]` section):
- `bind_mode` - 0=localhost, 1=WSL, 2=custom IP
- `port_override_enabled` / `port_override` - Custom port (default 6550)

---

## Scene Architecture (shelf.tscn)

```
Node2D (root)
├── Inventory (CanvasLayer, z_index=2)
│   ├── InventoryTrigger (Area2D) - Mouse hover opens shelf
│   └── Shelf (Area2D, script=shelf.gd) - Main inventory logic
│       ├── CollisionShape2D
│       ├── Sprite2D (shelf.png)
│       ├── DropZone (Node2D) - 6 Marker2D snap positions for items
│       └── Items (Node2D) - 6 draggable ritual items:
│           ├── Feather, Skull, Candle, Crystal, Book, Herbs
│           │   Each: Area2D + Sprite2D + CollisionShape2D + Draggable
│
├── Background (CanvasLayer, layer=-1)
│   ├── SummoningCircle (Area2D) - Visual circle sprite
│   │   └── 6 Drop Zones (SkullArea, BookArea, FeatherArea, HerbsArea, CrystalArea, CandleArea)
│   │       Each: Area2D + CollisionShape2D + DropZone (SNAP_MARKERS, specific accepted types)
│   └── ColorRect (dark background)
│
└── DragLayer (CanvasLayer, layer=2, script=drag_layer.gd) - Temporary parent during drag
```

---

## Game Mechanics

### Core Loop
1. Player hovers mouse over **InventoryTrigger** → shelf slides open (elastic tween)
2. Player drags items from **Shelf/Items** onto **SummoningCircle** drop zones
3. Each drop zone accepts **only one specific item type** (via `accepted_draggable_types`)
4. When all 6 zones filled → check if all matches correct → success/failure

### Matching Logic (shelf.gd:_on_item_drag_ended)
```gdscript
# target_area.name contains dragged_item.name → match
_circle_match[target_area.name] = matches
# When all 6 filled: check _circle_match.values.all() → success/failure
```

### Item → Drop Zone Mapping
| Item (Draggable type) | Drop Zone (accepted type) |
|----------------------|---------------------------|
| Skull | SkullArea |
| Book | BookArea |
| Feather | FeatherArea |
| Herbs | HerbsArea |
| Crystal | CrystalArea |
| Candle | CandleArea |

**Note**: Feather/Herbs/Crystal/Candle/Book all use the same DraggableType resource (`Resource_pb500`), but DropZones filter by specific type. Skull uses unique type (`Resource_ilsen`).

### Input Actions
- `draggable_click` - Left mouse button (drag trigger)
- `inventory` - 'I' key (toggle shelf)

---

## Key Scripts

### `scenes/shelf.gd` (extends Area2D)
**Main game controller**
- Manages shelf open/close animation (Tween with ELASTIC easing)
- Connects to all Draggable `drag_started`/`drag_ended` signals
- Tracks matches in `_circle_match` dictionary
- Handles inventory toggle via 'I' key

**Exported Properties**:
- `inventory_trigger: Area2D` - Mouse hover area
- `items: Node2D` - Container for draggable items
- `dragLayer: CanvasLayer` - Reparent target during drag

### `scenes/drag_layer.gd` (extends CanvasLayer)
- Simple passthrough for drag_ended signal (prints debug)

### `scenes/item_slot.gd` (extends Area2D)
- Empty placeholder (no logic yet)

---

## DragAndDrop Integration Details

### Draggable Setup (on each item)
```gdscript
# In shelf.gd _ready():
for child in item.find_children("Draggable", "Node", true):
    if child is Draggable:
        child.drag_ended.connect(_on_item_drag_ended)
        child.drag_started.connect(_on_item_drag_started)

func _on_item_drag_started(area):
    area.reparent(dragLayer)  # Move to top layer while dragging
```

### DropZone Configuration (in .tscn)
Each summoning circle area has:
```gdscript
# DropZone properties:
attach_spot = NodePath("..")  # Parent Area2D
snap_style = 1  # SNAP_MARKERS
drop_behavior = SubResource("Resource_4qg5k")  # drop_behavior_reject
accepted_draggable_types = [Specific DraggableType]
```

---

## Project Settings Summary

| Setting | Value |
|---------|-------|
| `config/name` | "SummoningCircleGame" |
| `run/main_scene` | "res://scenes/shelf.tscn" |
| `config/features` | ["4.7", "GL Compatibility"] |
| `display/window/stretch/mode` | "canvas_items" |
| `display/window/stretch/aspect` | "expand" |
| `physics/3d/physics_engine` | "Jolt Physics" |
| `rendering/renderer/rendering_method` | "gl_compatibility" |

---

## Assets

**Images** (res://assets/images/):
- shelf.png, circle.png - Background art
- skull.png, candle.png, crystal.png, feather.png, book.png, plants.png - Ritual items

---

## Development Notes for LLMs

1. **The game is a learning project** - User wants to understand Godot, not just finish
2. **Prefer idiomatic Godot** - Signals, nodes, composition over inheritance
3. **DragAndDrop plugin is the core mechanic** - All item interaction flows through it
4. **MCP plugin enables AI-assisted development** - Can inspect runtime state, inject inputs, control animations
5. **Scene uses CanvasLayers for z-ordering** - Background(-1), Inventory(2), DragLayer(2)
6. **Tween animations for UI** - Elastic easing for shelf open/close
7. **Type-safe matching** - DraggableType resources enforce correct item→zone pairing

---

## Common Tasks for AI Assistance

- **Add new ritual items**: Create new Area2D + Draggable in Shelf/Items, add matching DropZone in SummoningCircle
- **Modify drop behavior**: Extend DropBehavior resource or change `drop_behavior` on DropZone
- **Add visual feedback**: Connect to DropZone signals (`drop_accepted`, `drop_rejected`)
- **Test gameplay**: Use `godot_input` to simulate drags, `godot_game_time` to step through animations
- **Debug state**: Use `godot_runtime_state digest` to see all entity positions and match status