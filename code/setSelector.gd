extends Control


func promptNewSet():
	var path = await QuestionImporter.locateCSV()
	if path == "":
		return
	
	QuestionImporter._questionPathHold = path
	get_tree().change_scene_to_file("res://scenes/setColumns.tscn")
