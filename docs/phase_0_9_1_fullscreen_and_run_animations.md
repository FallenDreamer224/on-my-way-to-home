# Phase 0.9.1 — Display scaling and character running

Status: implementation complete; final aggregate regression results pending.

## Diagnosis

The available machine has one 1920×1080 display and uses Godot 4.7.2 Compatibility/OpenGL on an NVIDIA RTX 3050 Laptop GPU. The original borderless fullscreen already filled that monitor at exactly 2×. A universal fullscreen failure was not reproduced.

Two display defects were reproduced: resizing to 1280×720 retained a 960×540 image with 160-pixel side margins and 90-pixel top/bottom margins, and leaving fullscreen discarded a manually resized window and restored 960×540. The project forced integer stretch for every output size. AppSettings stored only a window-size preset and did not retain the native window rectangle. Native resizing also does not necessarily emit Viewport.size_changed when the internal viewport remains fixed.

Both character SpriteFrames already contained eight idle, eight walk and eight run clips. Astronaut selected only idle/walk; Chiwis always selected walk while moving. No missing or incorrectly named run sheets were found. Re-exporting would not solve controller state selection.

## Display implementation

AppSettings remains the authoritative settings and display object. AppRoot applies it at startup; GameUI binds its presentation policy for direct-session validation too. There is no second settings manager or menu.

- Keep the internal viewport **960×540**, `viewport` stretch, `keep` aspect and nearest filtering. `project.godot` retains its integer default and now declares aspect preservation explicitly.
- Exact integer fits use integer stretch. All other sizes use Godot's nearest fractional viewport fit, filling the largest 16:9 rectangle without cropping. Native sprites, 64×32 terrain, camera zoom and UI-scale preference remain independent.
- At noninteger output factors, some source pixels necessarily occupy different numbers of physical columns/rows. Nearest sampling prevents interpolation blur; it cannot provide uniform integer pixel widths and full screen coverage simultaneously. This is the fallback expressly requested for this phase. The Art Bible and standards JSON remain unchanged.
- Other aspect ratios receive centered letterboxing/pillarboxing. At 1366×768 the aspect fit is 1365×768, leaving only output-pixel rounding. At 3440×1440 it is 2560×1440 with 440-pixel side bars.
- Support decorated, resizable windowed mode and **Fullscreen (borderless)** through the existing Settings panel. Exclusive fullscreen is not offered or claimed tested.
- Save the windowed client rectangle in the existing settings.cfg, alongside the original preset/fullscreen/VSync/interface fields. Fullscreen toggles restore that rectangle; explicitly selecting a size preset requests that size again. Window frames/title bars are included in usable-desktop fitting and centering. Stale monitor coordinates and oversized values are clamped safely.
- A cheap native-rectangle comparison observes resize/move changes; writes are debounced for 0.3 seconds. Mode-transition notifications are guarded so fullscreen dimensions cannot overwrite the windowed rectangle. No UI or textures are rebuilt per frame.
- Malformed window-size/UI-scale/rectangle values fall back safely. Existing settings files without a rectangle migrate through their original preset.
- One `display_fullscreen_toggle` action contains F11 and Alt+Enter. AppRoot handles it before GUI/gameplay routing, ignores key repeat and saves the result. F11 remains reserved from gameplay rebinding. Settings stay synchronized when toggled by shortcut, including while the session is paused. Restore defaults applies windowed mode through the same authority.

The implementation follows Godot's documented [Window content scaling and modes](https://docs.godotengine.org/en/stable/classes/class_window.html) and [multiple-resolution presentation](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html); the installed 4.7.2 executable was used for acceptance rather than assuming documentation alone proves runtime behavior.

## Existing animation sources and runtime resources

All 32 original projects under the authorized external `assets/animations` source directory were hashed against the completed import manifest. Their 32 runtime PNGs also match the existing verified run hashes or this phase's baseline. The authorized external character originals were included in the 64-original preservation baseline. No source, PNG, frame region, SpriteFrames, foot-anchor profile or import settings were replaced.

| Character/state | Actual frames per direction | Existing FPS |
| --- | --- | --- |
| Astronaut walk | 7 for each of eight directions | 6; SE 3.4, W 3.9 |
| Astronaut run | 7 for each of eight directions | 6; SW and W 3 |
| Chiwis walk | 4 for each of eight directions | 6 |
| Chiwis run | 4 for each of eight directions | 6 |
| Both idle | Existing one-frame directional poses | Unchanged |

All frames are native **64×64**, with transparent padding. Counts above are measured per clip, not inferred by dividing a combined sheet. The original FPS and per-frame durations remain authoritative; the slower astronaut western clips were not silently normalized.

Runtime sheets remain under `assets/characters/{astronaut,chiwis}/{walk,run}/`. Profiles and frames remain `resources/characters/{astronaut,chiwis}_art.tres` and `{astronaut,chiwis}_frames.tres`. Provenance remains in `art/imports/pixelorama_characters.json` and `pixelorama_runs.json`. Export changes: **none**. The existing verified native Pixelorama pipeline remains available for a future explicitly requested art revision.

## Actual movement and animation behavior

Astronaut now exposes typed Inspector speeds: walk **80 px/s** (unchanged), run **140 px/s** (new, configurable). The single remappable `player_run` action defaults to holding Shift. Movement retains Input.get_vector/limit_length normalization, full-foot terrain sweeps, physical collision, facing, modal/neutral-input guards and the original coordinator. Running requires both held run input and actual displacement. Releasing Shift while moving selects walk; stopping or colliding selects idle with the current facing. There is no stamina or physiological model.

Chiwis does not read Shift. Its original 90 px/s movement cap is retained for catch-up. Nearby cruise is capped at the configurable **80 px/s** walk speed when the existing goal distance is at most activation distance plus preferred distance (normally 56+36=92 px). Beyond that it uses the existing 90 px/s cap. Follow activation/stopping distances, route planning, reservations, obstacle sweeps, room transitions and dialogue remain unchanged. An astronaut running continuously at 140 px/s can outpace a 90 px/s companion; no teleport or arbitrary speed boost was added.

Chiwis classifies animation from actual post-collision displacement/time relative to walk speed. Sustained faster movement selects run. A 0.1-second slowdown debounce prevents short route-waypoint steps from flashing walk frames; stopping still enters idle immediately. Direction uses actual motion through the shared AstronautDirections mapper. No duplicate controller or animation state machine was introduced.

Directions remain screen-facing **n, ne, e, se, s, sw, w, nw**. Grid-column motion is down-right and grid-row motion down-left; it is not relabeled as screen north/east. The existing angle mapper handles movement vectors for both characters. Original per-frame measured foot offsets, unit sprite scale and render-only snapping are preserved. AstronautAnimation already avoids restarting an unchanged clip; that selector required no modification.

## Validation and screenshots

The new `tests/character_running_test.gd` enters the configured AppRoot through the real menu/New Game control. It walks to staging points in the installed northern regolith, drives actual Shift/movement input in all eight directions, observes autonomous Chiwis walking/catch-up running, checks native frame-clock progress, orientation, foot contact, normalized speeds, release/turn/idle transitions, the real perimeter, inventory and management input ownership. Actors are not teleported and animation selectors are not forced for these captures. Capture-only follow offset gives the trailing companion headroom while retaining the same 2× camera and bounds, then restores ordinary framing. This is not a preview scene or a shipping camera change.

`tests/display_scaling_test.gd` checks safe configuration, settings reload, no duplicate shortcuts, actual menu mouse hits, New Game, display transitions/window restoration, independent camera zoom, inventory, dashboard mouse selection, and settings/database modals. Its explicit offscreen simulations render the real current viewport using nearest sampling and test source-pixel correspondence and bars. Native fullscreen images are unscaled monitor captures. Test-only foreground priority prevents desktop windows from occluding the captures; production does not become always-on-top.

| Target | Validation environment | Presentation |
| --- | --- | --- |
| 960×540 | Actual window + native-size offscreen output | Integer 1× |
| 1280×720 | Actual window + offscreen output | Nearest 4/3×, full area |
| 1366×768 | Actual window + offscreen output | Nearest fit, ≤1-pixel rounding bar |
| 1600×900 | Actual window + offscreen output | Nearest 5/3×, full area |
| 1920×1080 | Actual monitor borderless fullscreen + offscreen output | Integer 2×, full area |
| 2560×1440 | Controlled offscreen output only | Nearest 8/3×, full area |
| 3440×1440 | Controlled offscreen output only | 2560×1440 content, symmetric side bars |

Only one monitor was available. No native 1440p/ultrawide or multi-monitor hardware acceptance is claimed. Screenshots are saved at their native dimensions and were not resized for evaluation.

Evidence is in ignored `tests/output/phase_0_9_1/`:

- `menu_windowed.png`, `menu_fullscreen_native.png`, `game_windowed.png`, `game_fullscreen_native.png`.
- `inventory_fullscreen.png`, `dashboard_fullscreen.png`, `settings_fullscreen.png`, `database_fullscreen.png`.
- `simulated_{960x540,1280x720,1366x768,1600x900,1920x1080,2560x1440,3440x1440}.png`.
- `astronaut_run_{n,ne,e,se,s,sw,w,nw}.png` and `chiwis_run_{n,ne,e,se,s,sw,w,nw}.png`; each shows both real moving characters in that direction.
- `animation_source_audit.json`, `baseline.json`, final aggregate/startup logs and preservation audit.

Focused results: **213 headless / 229 graphical running checks**, **41 headless / 119 graphical display checks**, and **95 inventory integration checks** pass with zero errors/warnings. The original 903-check headless run-art suite passes, retaining exact source counts/timing/anchor validation and legacy clip fingerprints. All original inventory assertions remain; its mouse fixture now uses the viewport final transform instead of assuming logical coordinates equal native event coordinates. Capture framing restores the camera and waits for the completed render before checking foot contact, avoiding a fixture mismatch between different camera frames. Final aggregate and preservation results are recorded after completion below.

## Modified files

- `project.godot`: explicit keep aspect and the two authorized input actions.
- `scripts/core/app_settings.gd`: existing settings authority, presentation policy, restoration, robust loading and persistence.
- `scripts/core/app_root.gd`: fullscreen shortcut ownership and saving on application exit.
- `scripts/ui/game_ui.gd`, `settings_panel.gd`: bind presentation, synchronized existing display controls and accurate help text.
- `scripts/player/astronaut.gd`, `scripts/companions/chiwis.gd`: select existing run clips from real movement.
- `tests/display_scaling_test.gd`, `character_running_test.gd` and generated UID sidecars: focused production acceptance.
- `tests/run_animation_test.gd`: replace historical no-run-input expectation with the authorized single run action; retain all art/fingerprint/frame assertions.
- `tests/interaction_inventory_test.gd`: native input coordinate conversion, retaining all acceptance checks.
- `tests/validate.ps1`: include the new headless/rendered suites.
- `AGENTS.md`, `README.md`, one inventory status row and this report: additive current-phase documentation. Historical reports remain historical.

## Preservation and limits

Baseline HEAD is `7aca5b2a8db3164f5a4a3495cc782e1c5196e129`, branch `dev/phase-0.8f-ui-overhaul`; protected Alpha is `2942b0502d1a53a78651044319bbd86392497198`. All inherited Phase 0.9/G2 changes are preserved. No user editor was running at the initial process check. CLAUDE.md and the historical Phase 0.7B report are absent; current source/manifests and the completed Phase 0.9 report were used instead.

No artwork, credit-consuming jobs, audio, additional characters/planets, simulation systems, commits, push, export or publication were added. Existing outpost/airlock/greenhouse/utility abstractions and art limitations remain. A packaged Windows release and clean-machine acceptance remain separate work. The slower source clip cadence and noninteger nearest pixel-size variation are disclosed above. No next phase has begun.

## Manual acceptance

1. Launch normally, open Settings → Display, resize the decorated window, and toggle F11/Alt+Enter. Check full coverage at 1920×1080 and exact window restoration; restart to check saved preferences.
2. Select New Game. Move with WASD/arrows, hold Shift, turn in eight directions, release Shift, then stop. Confirm run/walk/idle and stable feet.
3. Watch Chiwis cruise nearby and run when the gap grows. Stop for it to catch up. Open inventory and switch camera modes; astronaut run input must remain blocked when appropriate.
4. Inspect the dashboard, settings, equipment database and existing interior station interfaces. Follow the normal airlock route into the furnished base and use the greenhouse/science/utility panels as before.
