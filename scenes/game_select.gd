extends Control

@export var games : Array[GameDefinition] = []
@export var gameContainer : Container
var gameCard = preload("res://scenes/gameCard.tscn")

func _ready():
	var gameNodes : Array[Control]= []
	var highestX = 0
	for game in games:
		var newGamecard :Control= gameCard.instantiate()
		gameContainer.add_child(newGamecard)
		game.apply(newGamecard)
		gameNodes.append(newGamecard)
		if newGamecard.get_combined_minimum_size().x >= highestX:
			highestX = newGamecard.get_combined_minimum_size().x
		if !QuestionImporter.loadedQuiz.checkProperty(game.query):
			newGamecard.get_child(1).visible = true
	
	for I in gameNodes:
		I.custom_minimum_size.x = highestX
