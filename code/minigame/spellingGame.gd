extends Control

@export var quiz : Quiz

@export var grid : GridContainer
@export var textLabel : RichTextLabel

@export var spawnSpeed = 5
@export var maxAnswerableWord = 7

@export var timer : Timer

var wordLookingFor := ""
var wordArray := []
var processingArray := []
var index = 0

var spellingLetter = preload("res://scenes/spellingLetter.tscn")
signal letterPressed

func _ready() -> void:
	timer.stop()
	quiz = QuestionImporter.loadedQuiz
	var questions = quiz.questions.duplicate()
	
	var newQuestions :Array[Question] = []
	for I : Question in questions:
		if I.answer.length() <= 15:
			newQuestions.append(I)
	await get_tree().create_timer(0.1).timeout
	newQuestions.shuffle()
	
	var i = 0
	for quest in newQuestions:
		i += 1
		await displayQuestion(quest,i,newQuestions.size())
	
	ResourceSaver.save(quiz)
	get_tree().change_scene_to_file("res://scenes/setSelector.tscn")

func displayQuestion(question : Question, indexy : int, maxCount : int):
	index = 0
	textLabel.text = question.question
	wordLookingFor = question.answer
	for I in wordLookingFor:
		processingArray.append(I)
		wordArray.append(I)
	if processingArray.size() > maxAnswerableWord:
		var distance = processingArray.size() - maxAnswerableWord
		if processingArray.has(" "):
			var indexsOfSpace = [processingArray.find(" ",0)]
			var ind = processingArray.find(" ",0) + 1
			while processingArray.find(" ",ind) != -1:
				indexsOfSpace.append(ind)
				ind = processingArray.find(" ",ind) + 1
			for e in indexsOfSpace:
				if processingArray.get(e + 1) != " " and processingArray.get(e + 1) != null:
					if distance != 0:
						processingArray[e + 1] = null
						distance -= 1
			
		if randi_range(0,1) == 0:
			for I in distance:
				processingArray[I] = null
		else:
			for I in distance:
				processingArray[processingArray.size() - (I + 1)] = null
	
	timer.wait_time = 1
	timer.start()
	
	var exit = false
	while !exit:
		var letter = await letterPressed
	displayStuffs()
	spellingLetter


func displayStuffs():
	for I in grid.get_children():
		I.queue_free()
	
	var indexWow = 0
	for I in processingArray:
		
		var newText
		if I == null:
			newText = wordArray[indexWow]
		else:
			if I == " ":
				newText = " "
			else:
				newText = "?"
		
		var newLabel = Label.new()
		newLabel.text = newText
		newLabel.add_theme_font_size_override("font_size",20)
		newLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		newLabel.size_flags_horizontal = Control.SIZE_FILL
		var newPanelContainer = PanelContainer.new()
		newPanelContainer.add_child(newLabel)
		newPanelContainer.custom_minimum_size = Vector2(34,0)
		grid.add_child(newPanelContainer)
		
		indexWow += 1
	


func _on_timer_timeout():
	var newSpawnLetter = spellingLetter.instantiate()
	add_child(newSpawnLetter)
	newSpawnLetter.global_position = Vector2(573.0,290)
	newSpawnLetter.direction = randf_range(-PI,PI)
	newSpawnLetter.speed = randf_range(30,30)
