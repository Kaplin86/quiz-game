extends Node2D

func _ready():
	var file = await QuestionImporter.locateCSV()
	print("file is ", file)
	QuestionImporter.parseFile(file)
