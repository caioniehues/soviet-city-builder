# Resources & Production Chains

## Resource Categories

### Raw Materials
Extracted directly from the environment.

| Resource | Source | Notes |
|----------|--------|-------|
| Iron Ore | Iron Mine | Primary metal source |
| Coal | Coal Mine | Fuel and steel production |
| Bauxite | Bauxite Mine | Aluminum production |
| Oil | Oil Derrick | Fuel and plastics |
| Gravel | Gravel Pit | Construction material |
| Wood | Logging Camp | Construction and boards |
| Crops | Farm | Food production |
| Livestock | Farm | Meat production |

### Processed Materials
Created from raw materials in processing facilities.

| Resource | Inputs | Facility |
|----------|--------|----------|
| Steel | Iron Ore + Coal | Steel Mill |
| Aluminum | Bauxite + Electricity | Aluminum Smelter |
| Fuel | Oil | Refinery |
| Bitumen | Oil | Refinery |
| Boards | Wood | Sawmill |
| Bricks | Clay + Fuel | Brick Factory |
| Concrete | Gravel + Cement | Concrete Plant |
| Fabric | Cotton/Wool | Textile Mill |
| Plastics | Oil | Chemical Plant |
| Chemicals | Oil | Chemical Plant |
| Food | Crops | Food Factory |
| Meat | Livestock | Meat Processing |

### Advanced Products
High-value goods requiring complex production chains.

| Resource | Inputs | Facility |
|----------|--------|----------|
| Mechanical Parts | Steel + Aluminum | Mechanical Factory |
| Electrical Parts | Copper + Plastics | Electrical Factory |
| Electronics | Electrical Parts + Chemicals | Electronics Factory |
| Vehicles | Steel + Mech. Parts + Elec. Parts | Vehicle Factory |
| Prefab Panels | Steel + Concrete | Panel Factory |

### Special Resources
Non-physical resources tracked by the game.

| Resource | Source | Purpose |
|----------|--------|---------|
| Workers | Housing | Labor for buildings |
| Rubles | Internal economy | Domestic currency |
| Dollars | Export/Import | Foreign currency |
| Electricity | Power Plants | Required by many buildings |
| Heat | Heating Plants | Required in winter |

---

## Production Chain Diagrams

### Phase 1 (3 Resources)
```
Iron Ore ──┬──→ [Steel Mill] ──→ Steel
Coal ──────┘
```

### Phase 2 (10 Resources)
```
                                    ┌──→ [Mech. Factory] ──→ Mechanical Parts
Iron Ore ──┬──→ [Steel Mill] ──→ Steel ──┤
Coal ──────┘                              └──→ [Vehicle Factory] ──→ Vehicles
                                                        ↑
                                          Mech. Parts ──┘

Crops ──→ [Food Factory] ──→ Food

Wood ──→ [Sawmill] ──→ Boards

Gravel ──→ [Concrete Plant] ──→ Concrete
```

### Phase 3 (Full Economy)
```
┌─────────────────────────────────────────────────────────────────┐
│                        RAW EXTRACTION                           │
├─────────────────────────────────────────────────────────────────┤
│  Iron Ore    Coal    Bauxite    Oil    Gravel    Wood    Crops │
│      │        │         │        │        │        │       │    │
└──────┼────────┼─────────┼────────┼────────┼────────┼───────┼────┘
       │        │         │        │        │        │       │
       ▼        ▼         ▼        ▼        ▼        ▼       ▼
┌─────────────────────────────────────────────────────────────────┐
│                        PROCESSING                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Iron + Coal → Steel Mill → STEEL                               │
│                                                                  │
│  Bauxite + Power → Aluminum Smelter → ALUMINUM                  │
│                                                                  │
│  Oil → Refinery → FUEL + BITUMEN                                │
│      → Chemical Plant → PLASTICS + CHEMICALS                    │
│                                                                  │
│  Wood → Sawmill → BOARDS                                        │
│                                                                  │
│  Gravel → Concrete Plant → CONCRETE                             │
│                                                                  │
│  Crops → Food Factory → FOOD                                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────────┐
│                     MANUFACTURING                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Steel + Aluminum → Mechanical Factory → MECHANICAL PARTS       │
│                                                                  │
│  Copper + Plastics → Electrical Factory → ELECTRICAL PARTS      │
│                                                                  │
│  Elec. Parts + Chemicals → Electronics Factory → ELECTRONICS    │
│                                                                  │
│  Steel + Concrete → Panel Factory → PREFAB PANELS               │
│                                                                  │
│  Steel + Mech + Elec → Vehicle Factory → VEHICLES               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────────┐
│                      CONSUMPTION                                 │
├─────────────────────────────────────────────────────────────────┤
│  Citizens need: Food, Meat, Alcohol, Clothing, Electronics      │
│  Construction needs: Concrete, Steel, Bricks, Boards, Panels    │
│  Export for Dollars: Vehicles, Electronics, Steel, Oil          │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementation Notes

### Resource Definition (Godot Resource)
```gdscript
# resources/resources/resource_type.gd
class_name ResourceType
extends Resource

@export var id: StringName
@export var display_name: String
@export var icon: Texture2D
@export var category: Category
@export var base_value_rubles: int
@export var base_value_dollars: int
@export var stack_size: int = 100
@export var weight_per_unit: float = 1.0

enum Category {
    RAW,
    PROCESSED,
    ADVANCED,
    SPECIAL
}
```

### Storage Implementation
```gdscript
# Storage is a dictionary of ResourceType -> amount
var inventory: Dictionary = {}

func add_resource(type: ResourceType, amount: int) -> int:
    var current: int = inventory.get(type, 0)
    var space: int = capacity - current
    var to_add: int = mini(amount, space)
    inventory[type] = current + to_add
    return to_add  # Returns amount actually added

func remove_resource(type: ResourceType, amount: int) -> int:
    var current: int = inventory.get(type, 0)
    var to_remove: int = mini(amount, current)
    inventory[type] = current - to_remove
    return to_remove  # Returns amount actually removed
```

---

## Balancing Guidelines

### Production Rates
- Raw extraction: 1-5 units/tick
- Processing: Match input rates
- Manufacturing: Slower, higher value

### Transport Capacity
- Truck: 10-20 units
- Train wagon: 50-100 units
- Conveyor: Continuous flow

### Economic Balance
- Self-sufficiency should be viable but harder
- Trade provides faster growth but dependency
- Dollars needed for advanced imports initially
