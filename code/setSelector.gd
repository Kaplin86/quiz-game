extends Control


func promptNewSet():
	var path = await QuestionImporter.locateCSV()
	if path == "":
		return
	
	QuestionImporter._questionPathHold = path
	get_tree().change_scene_to_file("res://scenes/setColumns.tscn")

func _ready():
	loadQuizs()

func loadQuizs():
	var quizs : Array[Quiz] = []
	var filePaths = DirAccess.open("user://").get_files()
	for filePath in filePaths:
		if filePath.get_extension() == "tres":
			var resource = ResourceLoader.load("user://"+filePath)
			print(resource)
