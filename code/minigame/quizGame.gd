extends Control

@export var quiz : Quiz

@export var questionCountLabel : Label
@export var questionText : RichTextLabel
@export var grid : GridContainer

@export var questionsToAnswerSpeed = 0.25

func _ready() -> void:
	quiz = QuestionImporter.loadedQuiz
	print(quiz)
	var questions = quiz.questions.duplicate()
	questions.shuffle()
	var i = 0
	for quest in questions:
		i += 1
		await displayQuestion(quest,i,questions.size())
	
	ResourceSaver.save(quiz)
	get_tree().change_scene_to_file("res://scenes/setSelector.tscn")

func displayQuestion(question : Question,count,maxVal):
	print(question.history)
	questionCountLabel.text = "Question " + str(count) + "/" + str(maxVal)
	questionText.text = question.question
	var possibleAnswers = [question.answer]
	possibleAnswers.append_array(question.falseAnswers)
	possibleAnswers.shuffle()
	
	for child in grid.get_children():child.queue_free()
	
	if possibleAnswers.size() % 2 == 0:
		grid.columns = 2
	else:
		grid.columns = 3
	
	var firstTween = create_tween()
	for answer in possibleAnswers:
		var newButton = Button.new()
		newButton.text = answer
		grid.add_child(newButton)
		newButton.connect("pressed",onButtonPress.bind(newButton))
		newButton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		newButton.size_flags_vertical = Control.SIZE_EXPAND_FILL
		newButton.autowrap_mode = TextServer.AUTOWRAP_WORD
		newButton.modulate = Color(1,1,1,0)
		firstTween.tween_property(newButton,"modulate",Color(1,1,1,1),0.1)
	
	var answer = await customButtonPress
	for child : Button in grid.get_children(): child.button_mask = 0
	
	var answerNode : Button= answer[0]
	var answerText = answer[1]
	
	var newTween = create_tween()
	newTween.set_parallel(true)
	for child in grid.get_children(): if child != answerNode: if child.text != question.answer: newTween.tween_property(child,"modulate",Color(1,1,1,0.5),questionsToAnswerSpeed)
	
	if answerText == question.answer:
		newTween = create_tween()
		var newStyle : StyleBoxFlat = answerNode.get_theme_stylebox("normal").duplicate(true)
		answerNode.add_theme_stylebox_override("normal",newStyle)
		answerNode.add_theme_stylebox_override("hover",newStyle)
		newTween.tween_property(newStyle,"bg_color",lerp(Color.GREEN,newStyle.bg_color,0.75),questionsToAnswerSpeed)
	else:
		newTween = create_tween()
		newTween.set_parallel(true)
		var newStyle : StyleBoxFlat = answerNode.get_theme_stylebox("normal").duplicate(true)
		answerNode.add_theme_stylebox_override("normal",newStyle)
		answerNode.add_theme_stylebox_override("hover",newStyle)
		newTween.tween_property(newStyle,"bg_color",lerp(Color.RED,newStyle.bg_color,0.75),questionsToAnswerSpeed)
		
		var correctAnswerNode = null
		for child in grid.get_children(): if child.text == question.answer: correctAnswerNode = child
		newStyle = correctAnswerNode.get_theme_stylebox("normal").duplicate(true)
		correctAnswerNode.add_theme_stylebox_override("normal",newStyle)
		correctAnswerNode.add_theme_stylebox_override("hover",newStyle)
		print(correctAnswerNode.text)
		newTween.tween_property(newStyle,"bg_color",lerp(Color.GREEN,newStyle.bg_color,0.75),questionsToAnswerSpeed)
		
	await get_tree().create_timer(questionsToAnswerSpeed).timeout
	if !Input.is_action_pressed("Speed"): await get_tree().create_timer(2-questionsToAnswerSpeed).timeout
	
	newTween = create_tween()
	newTween.set_parallel(true)
	for child in grid.get_children(): newTween.tween_property(child,"modulate",Color(1.0, 1.0, 1.0, 0.0),0.5)
	if !Input.is_action_pressed("Speed"): await newTween.finished
	
	if answerText == question.answer:
		question.history.append(true)
	else:
		question.history.append(false)
	
	if !Input.is_action_pressed("Speed"): await get_tree().create_timer(0.1).timeout
	
	
	

signal customButtonPress
func onButtonPress(node):
	customButtonPress.emit(node,node.text)
