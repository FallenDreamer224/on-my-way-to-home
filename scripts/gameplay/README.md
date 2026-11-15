# Future gameplay ownership

Current Phase 0.7 implementation: `player_session.gd` handles inventory modal/input handoff beside the existing mode coordinator. The latter gains a modal guard; its camera behavior is preserved. Interaction components live in `scripts/interaction/`, runtime inventory in `scripts/inventory/`, item definitions in `resources/items/`, and UI in `scripts/ui/`. Chiwis remains in `scripts/companions/`. These implemented domains supersede their old proposed locations/status below; the other future systems remain deferred. Main wires references and UI owns no quantities. See `docs/phase_0_7_report.md`.

Phase 0.4 implements `gameplay_mode_coordinator.gd` here as a small presentation/input coordinator under Main/Systems. It exposes PLAYER/BASE_MANAGEMENT queries and mode_changed, owns camera activation and input routing, and never owns world simulation data. Future modules below remain deferred; there is no general state-machine framework.

This directory reserves module ownership without placeholder behavior. Add focused files/components only when their phase is approved:

| Responsibility | Future location under this directory | State boundary |
| --- | --- | --- |
| Modes | `modes/` | Select input, camera, UI policy; share world state |
| Interactions | `interactions/` | Resolve requests against world entities |
| Inventory | `inventory/` | Item IDs and quantities, separate from icons |
| Resource management | `resources/` | Resource balances and equipment/power state |
| Construction | `construction/` | Logical footprints and placement requests |
| Survival | `survival/` | Explicit future state; no assumed formulas |
| Tutorials/missions | `missions/` | Data-defined objectives and stable progression IDs |

Reusable coordinator scenes belong in `scenes/gameplay/`; static definitions belong in `resources/data/`. Companion-specific scripts will belong in `scripts/companions/` when implemented. No listed child directories or gameplay scripts are needed yet. Main/Systems will wire services; rendering/UI do not own persistent state.
