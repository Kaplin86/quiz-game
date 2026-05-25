extends Resource
class_name GameDefinition

## A resource for defining what games exist

@export_multiline() var gameName := ""
@export_multiline() var gameDescription := ""
@export_file("*.tscn") var scenelocation := ""
@export var query = ""

func apply(node : Control):
	var name = node.find_child("Name",true,true)
	print(name)
	var desc = node.find_child("Description",true)
	if name: if name is Label: name.text = gameName
	if desc: if desc is RichTextLabel: desc.text = gameDescription
	var play = node.find_child("Play",true)
	if play: if play is Button: play.connect("pressed",func():play.get_tree().change_scene_to_file(scenelocation))
