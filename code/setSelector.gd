extends Control

var loadedQuizs : Array[Quiz] = []
var buttonGroup = ButtonGroup.new()
var selectedQuiz : Quiz

@export var quizBox : VBoxContainer
@export var themeButton : OptionButton
@export var masteryDisplay : MasteryDisplay
@export var memoryMatchLowScore : Label

func promptNewSet():
	var path = await QuestionImporter.locateCSV()
	if path == "":
		return
	
	var foundPathQuiz=null
	for I in loadedQuizs:
		if I.sourcePath == path:
			foundPathQuiz = I
			break
	
	if foundPathQuiz:
		foundPathQuiz.hidden = false
		ResourceSaver.save(foundPathQuiz)
		loadQuizs()
	else:
		QuestionImporter._questionPathHold = path
		get_tree().change_scene_to_file("res://scenes/setColumns.tscn")

func _ready():
	loadQuizs()
	buttonGroup.connect("pressed",setSelected)
	loadThemes()
	memoryMatchLowScore.visible = false

func loadThemes():
	for iTheme : Theme in ThemeController.themes:
		themeButton.add_item(iTheme.resource_name)
		themeButton.set_item_metadata(-1,iTheme)

func setSelected(button : BaseButton):
	for I in get_tree().get_nodes_in_group("requireDataset"):
		I.disabled = false
	selectedQuiz = button.get_meta("quiz",null)
	masteryDisplay.displayQuiz(selectedQuiz)
	if selectedQuiz.memoryMatchLowScore != 999:
		memoryMatchLowScore.visible = true
		memoryMatchLowScore.text = "Memory Match Lowscore: " + str(selectedQuiz.memoryMatchLowScore)
	else:
		memoryMatchLowScore.visible = false


func sortCreation(a : Quiz, b: Quiz):
	if a.creationDate > b.creationDate:
		return true
	return false



func loadQuizs():
	loadedQuizs.clear()
	var filePaths = DirAccess.open("user://").get_files()
	for filePath in filePaths:
		if filePath.get_extension() == "tres":
			var resource = ResourceLoader.load("user://"+filePath)
			if resource is Quiz:
				loadedQuizs.append(resource)
	
	loadedQuizs.sort_custom(sortCreation)
	
	for i in quizBox.get_children():i.queue_free()
	
	for quiz : Quiz in loadedQuizs:
		if !quiz.hidden:
			var newButton = Button.new()
			newButton.toggle_mode = true
			newButton.button_group = buttonGroup
			newButton.text = quiz.displayName
			quizBox.add_child(newButton)
			newButton.set_meta("quiz",quiz)
			newButton.tooltip_text = quiz.sourcePath


func pressedSelected():
	QuestionImporter.loadedQuiz = selectedQuiz
	get_tree().change_scene_to_file("res://scenes/gameSelect.tscn")


func _on_option_button_item_selected(index):
	ThemeController.currentTheme = themeButton.get_item_metadata(index)

func removeSelected():
	selectedQuiz.hidden = true
	ResourceSaver.save(selectedQuiz)
	loadQuizs()
