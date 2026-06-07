extends Button
class_name SceneButton

## Its a button, but changes scenes on click!

@export_file_path("*.tscn") var scene : String

func _pressed():
	get_tree().change_scene_to_file(scene)
