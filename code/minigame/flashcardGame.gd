extends Control

@export var quiz : Quiz

@export var cardNode : Node2D
@export var cardText : RichTextLabel
@export var countDisplay : Label

@export var flipSpeed = 0.25

var currentSideisAnswer = false 

var displayedQuestion : Question

signal answerButtonPressed(state)

func _ready() -> void:
	quiz = QuestionImporter.loadedQuiz
	var questions = quiz.questions.duplicate()
	questions.shuffle()
	var i = 0
	for quest in questions:
		i += 1
		await displayQuestion(quest,i,questions.size())
	
	ResourceSaver.save(quiz)
	get_tree().change_scene_to_file("res://scenes/setSelector.tscn")

func displayQuestion(question : Question,count,maxVal):
	countDisplay.text = str(count) + " / " + str(maxVal)
	displayedQuestion = question
	currentSideisAnswer = false
	cardText.text = question.question
	var state = await answerButtonPressed
	question.history.append(state)


func _on_flip_pressed():
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(cardNode,"scale",Vector2(0,1),flipSpeed)
	tween.tween_property(cardNode,"skew",0.1,flipSpeed)
	await tween.finished
	tween = create_tween()
	tween.set_parallel()
	
	currentSideisAnswer = !currentSideisAnswer
	if currentSideisAnswer:
		cardText.text = displayedQuestion.answer
	else:
		cardText.text = displayedQuestion.question
	
	tween.tween_property(cardNode,"scale",Vector2(1,1),flipSpeed)
	tween.tween_property(cardNode,"skew",0,flipSpeed)
	
	


func _on_incorrect_pressed():
	answerButtonPressed.emit(false)


func _on_correct_pressed():
	answerButtonPressed.emit(true)
