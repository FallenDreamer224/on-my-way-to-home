# Third-party and licensing review

Reviewed 2026-11-15 against the local project and primary provider sources. Publication is **not cleared** until the open items below are resolved. No project LICENSE has been chosen.

| Material | Evidence / present use | Release action |
| --- | --- | --- |
| Project code and original game content | No selected license or existing project LICENSE | Publisher must select scope/terms before source publication. Do not infer MIT from the engine. |
| Astronaut/Chiwis walk/run art | Import manifests state user-supplied project-use authorization; external PXO originals are not in this source tree | Confirm rights to distribute source textures and executable copies. Preserve manifests/hashes. |
| Moon regolith | Manifest records supplied/authorized project use, without a separate redistribution license | Obtain/record owner or provider clearance for public source and build distribution. |
| PixelLab packs A–E | Provider terms linked in intake manifests; source/runtime mirrors and generation IDs preserved | Confirm account/input rights and applicable generation-time terms. Do not silently apply a blanket code license to art. |
| Godot runtime | MIT engine; other components/fonts have their own notices | Carry the official license and applicable third-party notices from the exact 4.7.2 build into executable documentation. |
| Temporary Godot project icon | Godot-branded icon.svg remains unchanged | Credit logo rights/usage and use approved game branding before public release. |
| Pixelorama | Authoring/export dependency only; cached tool is ignored | Do not bundle the editor/PCK in the playable game. If separately redistributing it, follow its license and component notices. |
| Fonts / plugins | No standalone font file, addon or provider SDK found; UI relies on engine fallback | Inspect the actual exported engine's bundled notices; no font-free claim is made about the engine binary. |
| NASA/JPL references | URLs, research registry and paraphrased design references; no newly downloaded imagery/logos | Preserve citations; review any third-party/publicity rights before reusing media or insignia. No endorsement. |

## Primary sources

- [PixelLab Terms of Service](https://www.pixellab.ai/termsofservice), displayed update 2026-10-30: grants output use/distribution, retains creator responsibility for third-party rights and references Open RAIL-M. Review the [linked license](https://github.com/CompVis/stable-diffusion/blob/main/LICENSE) and its output/use provisions. A provider's permission does not establish the provenance of independently supplied character/terrain files.
- [Godot license](https://godotengine.org/license/) and [distribution compliance](https://docs.godotengine.org/en/stable/about/complying_with_licenses.html): engine attribution/license and dependency notices are distinct from the game's chosen license.
- [Godot 4.7.2 third-party notices](https://github.com/godotengine/godot/blob/4.7.2-stable/COPYRIGHT.txt): includes bundled fonts/libraries, even when the project has no standalone font assets.
- [Godot press kit](https://godotengine.org/press/): logo CC BY 4.0 and use guidelines.
- [Pixelorama license](https://github.com/Orama-Interactive/Pixelorama/blob/master/LICENSE): Orama Interactive and contributors.
- [NASA media rules](https://www.nasa.gov/nasa-brand-center/images-and-media/) and [advertising guidance](https://www.nasa.gov/nasa-brand-center/advertising-guidelines/): names/insignia/endorsement and third-party content require separate consideration.

These sources document requirements for release review. They are not an assertion that all project art is cleared, nor a decision to publish or adopt an open-source license.

