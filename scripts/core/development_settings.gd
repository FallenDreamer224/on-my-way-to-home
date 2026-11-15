class_name DevelopmentSettings
extends Resource
## Shared development configuration. Development features are disabled in release builds.

@export var enabled: bool = true
@export var show_development_screen: bool = true
@export var log_startup: bool = false


func is_active() -> bool:
	return OS.is_debug_build() and enabled
