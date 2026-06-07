extends Control

var fileGrid : Array[PackedStringArray]
var headers : PackedStringArray = []
@export var panelContainerToDupe : Node
@export var errorPopup : Popup

func _ready() -> void:
	fileGrid = QuestionImporter.parseFilePathToGrid(QuestionImporter._questionPathHold)
	
	headers = fileGrid[0]
	fillOptionBoxes()
	
	if QuestionImporter.loadedQuiz != null:
		for I in QuestionImporter.loadedQuiz.incorrectColumn.size():
			var panel = createIncorrectAnswerPanel()
			var option = panel.find_child("OptionButton",true,false)
			option.select(QuestionImporter.loadedQuiz.incorrectColumn[I]+1)
		for box : OptionButton in get_tree().get_nodes_in_group("headerDropdown"):
			var returningValue =box.get_selected_metadata()
			match box.get_meta("type",""):
				"question":
					box.select(QuestionImporter.loadedQuiz.questionColumn)
				"answer":
					box.select(QuestionImporter.loadedQuiz.answerColumn)
				"desc":
					box.select(QuestionImporter.loadedQuiz.descColumn + 1)

func fillOptionBoxes():
	for box : OptionButton in get_tree().get_nodes_in_group("headerDropdown"):
		fillBox(box)

func fillBox(box : OptionButton):
	box.clear()
	if !box.is_in_group("requiredInput"):
		box.add_item("",0)
		box.set_item_metadata(0,-1)
	var index = 0
	for text : String in headers:
		box.add_item(text)
		box.set_item_metadata(-1,index)
		index += 1

func _on_button_pressed() -> void:
	createIncorrectAnswerPanel()

func createIncorrectAnswerPanel():
	var newPanel = panelContainerToDupe.duplicate()
	panelContainerToDupe.add_sibling(newPanel)
	panelContainerToDupe.get_parent().move_child(newPanel,-2)
	
	var optionBox = newPanel.find_child("OptionButton",true,false)
	optionBox.set_meta("type","incorrect")
	var label = newPanel.find_child("Label",true,false)
	label.text = "Incorrect Answer"
	
	fillBox(optionBox)
	return newPanel


func confirm():
	var answerColumn = -1
	var questionColumn = -1
	var descColumn = -1
	var incorrectColumns : Array[int] = []
	for dropdown : OptionButton in get_tree().get_nodes_in_group("headerDropdown"):
		var returningValue =dropdown.get_selected_metadata()
		if returningValue == -1:
			continue
		match dropdown.get_meta("type",""):
			"question":
				questionColumn = returningValue
			"answer":
				answerColumn = returningValue
			"desc":
				descColumn = returningValue
			"incorrect":
				incorrectColumns.append(returningValue)
	
	var questionArray = QuestionImporter.parseDataToQuestionResource(fileGrid,questionColumn,answerColumn,incorrectColumns,descColumn)
	
	var quiz = Quiz.new(QuestionImporter._questionPathHold,questionArray,questionColumn,answerColumn,incorrectColumns,descColumn)
	var path = "user://"+str(Time.get_unix_time_from_system()).replace(".","-") + ".tres"
	if QuestionImporter.loadedQuiz != null:
		for I : Question in QuestionImporter.loadedQuiz.questions:
			var quest = quiz.getQuestionByText(I.question)
			if quest:
				quest.history = I.history
		path = QuestionImporter.loadedQuiz.resource_path
	
	var err = ResourceSaver.save(quiz, path)
	
	print(error_string(err))
	print(ProjectSettings.globalize_path(path), " now has ", quiz.questionColumn)
	await get_tree().create_timer(0.05).timeout
	if err == 0:
		get_tree().change_scene_to_file("res://scenes/setSelector.tscn")
	else:
		errorPopup.visible = true
		await errorPopup.popup_hide
		get_tree().change_scene_to_file("res://scenes/setSelector.tscn")
