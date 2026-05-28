extends Control

@export var quiz : Quiz

@export var grid : GridContainer
@export var textLabel : RichTextLabel

@export var spawnSpeed = 5
@export var maxAnswerableWord = 7

@export var difficultyScaling = 0.3
@export var timer : Timer

var wordLookingFor := ""
var wordArray := []
var processingArray := []
var index = 0

var spellingLetter = preload("res://scenes/spellingLetter.tscn")
signal letterPressed(letter : String)

var alphabet : PackedStringArray = "abcdefghijklmnopqrstuvwxyz1234567890".split("")
var alphabet_upper : PackedStringArray = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".split("")

var difficulty = 1.0

var buttons = []

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
	difficulty = 1.0
	index = 0
	textLabel.text = question.question
	wordLookingFor = question.answer
	processingArray = []
	wordArray = []
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
	
	timer.wait_time = float(maxAnswerableWord - (difficulty * 1/difficultyScaling)) / 2
	timer.start()
	displayStuffs()
	var exit = false
	while !exit:
		print("back to await")
		await letterPressed
		print("wow a letter was pressed!")
		difficulty += difficultyScaling
		clearRemainingLetter()
		print("lets display some new junk")
		displayStuffs()
		print("wait time")
		timer.wait_time = ((maxAnswerableWord - (difficulty * 2)) / 2)
		if getRemainingWholeLetters() == 0:
			exit = true
	
	print("finish!")
	for I in buttons:
		if I:
			I.explode()

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
	buttons.append(newSpawnLetter)
	newSpawnLetter.global_position = Vector2(573.0,290)
	newSpawnLetter.direction = randf_range(-PI,PI)
	newSpawnLetter.speed = randf_range(25,30 * difficulty)
	newSpawnLetter.dirSpeed = randf_range(0,0.5 * difficulty)
	newSpawnLetter.modulate = Color.TRANSPARENT
	var newTween = create_tween()
	newTween.bind_node(newSpawnLetter)
	newTween.tween_property(newSpawnLetter,"modulate",Color.WHITE,2)
	newTween.tween_interval(randi_range(4,10))
	newTween.tween_property(newSpawnLetter,"modulate",Color.TRANSPARENT,2)
	newTween.tween_callback(newSpawnLetter.queue_free)
	var letters : PackedStringArray = alphabet.duplicate()
	var letterNeed = getNextNeededLetter()
	if letterNeed.to_upper() == letterNeed:
		letters = alphabet_upper
	
	var finalLetter = " "
	var odds = 10 * ((1+wordArray.size()-getRemainingWholeLetters())/wordArray.size()) #when there is only one letter remaining, this should return 10
	if randi_range(-1,int(odds * 1.2)) == 0:
		finalLetter = letterNeed
	else:
		finalLetter = letters.get(randi_range(0,letters.size() - 1))
	
	newSpawnLetter.text = finalLetter
	newSpawnLetter.connect("pressed",pressedLetter.bind(finalLetter,newSpawnLetter))

func pressedLetter(letter : String, node : Button):
	print("next needed is ", getNextNeededLetter())
	buttons.erase(node)
	if node.text != getNextNeededLetter():
		node.explode()
	else:
		print("wowie what a press!")
		letterPressed.emit(letter)
		node.absorb()

func getRemainingWholeLetters():
	var count = 0
	for I in processingArray:
		if I != null and I != " ":
			count += 1
	return count

func getClearedLetters():
	return processingArray.size() - getRemainingWholeLetters()

func getNextNeededLetter() -> String:
	for I in processingArray:
		if I != null and I != " ":
			return I
	return " "

func clearRemainingLetter():
	print("lets clear!")
	for I in processingArray.size():
		if processingArray[I] != null:
			if processingArray[I] == " ":
				processingArray[I] = null
			else:
				processingArray[I] = null
				return
