# Gameplay scene contract

Current Phase 0.7 composition uses GameplayModes and PlayerSession under Main/Systems, world pickups in `scenes/world/`, and modal/prompt scenes in `scenes/ui/`. The Phase 0.1 description below is historical; construction, container transfers and disk persistence remain deferred.

Future exploration/base-management coordinators, placement components, and interaction components belong here, with behavior in `scripts/gameplay/` once needed. Attach nonvisual coordinators under `Main/Systems`; place world entities under the appropriate `World/Entities` category. Keep UI presentation under `Main/UI`. No gameplay mode, placement, interaction, management, or persistence system is implemented in Phase 0.1.
