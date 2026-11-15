# On My Way to Home — Demo 0.1.0-rc.1

An early Windows x64 Moon exploration prototype with one astronaut and Chiwis, a robotic companion. Includes a 40×40 isometric lunar region, two camera modes, resource pickups and stacking inventory, safety perimeter, placeholder habitat interiors, an interlocked airlock, utility terminals and small resource-dependent growing trays.

Extract the entire ZIP into a writable folder, then open `On-My-Way-to-Home-Demo.exe`. Keep its matching `.pck` beside it. No Godot editor, Python, PixelLab account or other development tools are required. The game opens directly into the Moon scene; there is no main menu or New Game button.

| Control | Action |
| --- | --- |
| WASD / arrow keys | Walk; pan in Base Management Mode |
| Tab | Switch Player / Base Management camera |
| Mouse wheel | Zoom the management camera |
| E / left click | Use the nearest valid interaction shown by the prompt |
| I | Open / close inventory |
| Esc | Close the active inventory or terminal panel |
| Window close / Alt+F4 | Exit |

For fullscreen, launch the EXE with Godot's `--fullscreen` option (for example, add it to a Windows shortcut target). Default launch is windowed. There is no in-game display-settings menu or fullscreen hotkey.

Suggested short route: collect a Lunar Sample near the starting point, check inventory, try both cameras, then walk northwest toward the habitat crew airlock. Follow its seal/inspection/cycle prompts, enter the hub and visit Health / Science. Use the powered science station's **Examine sample** activity. This is a suggested activity route; there is no mission-completion screen.

Known limitations: no disk save/load, main menu, sprint input, crafting, Mars or final survival/medical simulation. Some exteriors are reserved zones; interiors and room fixtures use development visuals. Status readouts remain placeholders. Airlock, utilities and plant growth are bounded game abstractions. The executable is unsigned and uses the temporary Godot icon. GPU/driver compatibility beyond the tested Windows machine has not been established. No sound or music is included.

This is an unpublished release candidate. Public redistribution clearance for supplied character/terrain artwork is still pending. NASA and JPL are scientific references and do not sponsor or endorse this game. See `CREDITS.txt`, `GODOT_LICENSE.txt` and `GODOT_COPYRIGHT.txt` in the package.
