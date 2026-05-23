extends Control
class_name ThemeControllerNode

## A node dedicated to storing themes and applying them.

## An array of loaded themes.
@export var themes : Array[Theme]
## The currently loaded theme.
var currentTheme : Theme:
	set(value):
		currentTheme = value
		applyTheme()

func _ready() -> void:
	currentTheme = themes[0]
	get_tree().connect("scene_changed",applyTheme)

## Runs whenever a scene is loaded. Sets the theme of that node, alongside a custom background.
func applyTheme():
	var scene : Node = get_tree().current_scene
	scene.theme = currentTheme
	$ColorRect.color = currentTheme.get_color("background","BackgroundColor")
