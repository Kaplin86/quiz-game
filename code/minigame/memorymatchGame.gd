extends Control

@export var quiz : Quiz

@export var grid : GridContainer
@export var attempts : Label
@export var recordAttempts : Label

var memoryTile = preload("res://scenes/memoryMatchTile.tscn")

var tilesFlipped : Array[Control] = []

signal finishedFlippingTwo

var score = 0

func _ready() -> void:
	quiz = QuestionImporter.loadedQuiz
	
	if quiz.memoryMatchLowScore != 999:
		recordAttempts.visible = true
		recordAttempts.text = "Record Attempts: " + str(quiz.memoryMatchLowScore)
	else:
		recordAttempts.visible = false
	
	var questions = quiz.questions.duplicate()
	questions.shuffle()
	var i = 0
	var batch : Array[Question] = []
	for quest in questions:
		batch.append(quest)
		i += 1
		if batch.size() >= 4:
			await displayQuestions(batch,i,questions.size())
			batch.clear()
	if batch.size() > 0:
		await displayQuestions(batch,i,questions.size())
	
	if score <= quiz.memoryMatchLowScore:
		quiz.memoryMatchLowScore = score
	
	ResourceSaver.save(quiz)
	get_tree().change_scene_to_file("res://scenes/setSelector.tscn")

func displayQuestions(batch : Array[Question], num : int, max : int):
	var tiles = []
	for question in batch:
		var questionTile = createTile(question,false)
		var answerTile = createTile(question,true)
		
		tiles.append(questionTile)
		tiles.append(answerTile)
	
	for I in grid.get_children():
		I.queue_free()
	
	tiles.shuffle()
	var tileX = 0
	for I in tiles:
		tileX += 1
		grid.add_child(I)
		I.modulate = Color.TRANSPARENT
		create_tween().tween_property(I,"modulate",Color.WHITE,0.1 + (0.1*tileX))
	
	while grid.get_children().size() != 0:
		await finishedFlippingTwo
		while !Input.is_action_just_pressed("mouse"):
			await get_tree().process_frame
		var question1 = tilesFlipped[0].get_meta("question")
		var question2 = tilesFlipped[1].get_meta("question")
		
		if question1 == question2:
			var tween = create_tween()
			tween.set_parallel()
			tween.tween_property(tilesFlipped[0],"modulate",Color.TRANSPARENT,0.25)
			tween.tween_property(tilesFlipped[1],"modulate",Color.TRANSPARENT,0.25)
			await tween.finished
			tilesFlipped[0].process_mode = Node.PROCESS_MODE_DISABLED
			tilesFlipped[1].process_mode = Node.PROCESS_MODE_DISABLED
			tilesFlipped.clear()
		else:
			flipTileToText(tilesFlipped[0],"???")
			await flipTileToText(tilesFlipped[1],"???")
			tilesFlipped.clear()
		
		score += 1
		attempts.text = "Attempts: " + str(score)
		
		var done = true
		for node in grid.get_children():
			if node.process_mode != Node.PROCESS_MODE_DISABLED:
				done = false
		if done:
			break

func createTile(question : Question, isAnswer):
	var newTile =  memoryTile.instantiate()
	newTile.set_meta("question",question)
	newTile.set_meta("isAnswer",isAnswer)
	newTile.get_child(1).connect("pressed",tileFlipped.bind(newTile))
	return newTile

func tileFlipped(tile):
	var question : Question = tile.get_meta("question")
	if tilesFlipped.size() <= 1:
		tilesFlipped.append(tile)
		if tile.get_meta("isAnswer"):
			flipTileToText(tile,question.answer)
		else:
			flipTileToText(tile,question.question)
		if tilesFlipped.size() == 2:
			finishedFlippingTwo.emit()

func flipTileToText(tile : Control,text : String):
	var newTween = create_tween()
	newTween.tween_property(tile,"scale",Vector2(0,1),0.25)
	newTween.tween_property(tile,"scale",Vector2(1,1),0.25)
	await newTween.step_finished
	tile.find_child("RichTextLabel",true).text = text
	if text == "???":
		tile.get_child(1).mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		tile.get_child(1).mouse_filter = Control.MOUSE_FILTER_IGNORE
	
