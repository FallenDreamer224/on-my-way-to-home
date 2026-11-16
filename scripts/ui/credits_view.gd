class_name CreditsView
extends ScrollContainer
## Scrollable credits. The entries mirror CREDITS.md; keep both in agreement when credits change.

const ENTRIES: Array[Array] = [
	["ON MY WAY TO HOME", "A 2D isometric lunar exploration and base-management game by the project authors. Public author names and licensing are pending publisher confirmation."],
	["ENGINE", "Made with Godot Engine 4.7.2.\nCopyright (c) 2014-present Godot Engine contributors. Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.\nGodot is distributed under the MIT license. This credit does not license the game's code or artwork."],
	["CHARACTERS AND TERRAIN", "The astronaut and Chiwis, with their walk and run animations, are original Pixelorama artwork supplied for this project. The lunar regolith tiles come from the supplied terrain pack."],
	["GENERATED ARTWORK", "Interface icons and frames, props, base structures, the lander, terrain overlays and the title-scene sky layers were generated with PixelLab.ai, then selected and reviewed by the project authors. Generation records are kept with the project sources."],
	["AI ASSISTANCE", "OpenAI Codex assisted with code and documentation. PixelLab.ai-assisted artwork is documented in the asset import records. Character artwork and animations were made by hand in Pixelorama."],
	["TYPEFACES", "Departure Mono by Helena Zhang.\nSilkscreen by Jason Kottke and the Silkscreen Project Authors.\nBoth are used under the SIL Open Font License 1.1; the license texts ship with the fonts."],
	["TOOLS", "Pixelorama by Orama Interactive and contributors was used to author and export the character art. It is not part of the game."],
	["SCIENCE REFERENCES", "Public NASA and JPL publications inform the research notes and the equipment database. This independent game is not sponsored, approved or endorsed by NASA. No NASA affiliation or hardware qualification is claimed."],
]

var list: VBoxContainer


func _init() -> void:
	name = "Credits"
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	list = UiKit.vbox(3)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(list)
	for entry: Array in ENTRIES:
		list.add_child(UiKit.label(entry[0], &"SectionLabel"))
		list.add_child(UiKit.wrapped(entry[1], &"SecondaryLabel", 360))
		var gap := Control.new()
		gap.custom_minimum_size.y = 4
		list.add_child(gap)
