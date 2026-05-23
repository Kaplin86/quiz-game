extends Control

var loadedQuizs : Array[Quiz] = []
var buttonGroup = ButtonGroup.new()
var selectedQuiz : Quiz

@export var quizBox : VBoxContainer
@export var themeButton : OptionButton

func promptNewSet():
	var path = await QuestionImporter.locateCSV()
	if path == "":
		return
	
	QuestionImporter._questionPathHold = path
	get_tree().change_scene_to_file("res://scenes/setColumns.tscn")

func _ready():
	loadQuizs()
	buttonGroup.connect("pressed",setSelected)
	loadThemes()

func loadThemes():
	for iTheme : Theme in ThemeController.themes:
		themeButton.add_item(iTheme.resource_name)
		themeButton.set_item_metadata(-1,iTheme)

func setSelected(button : BaseButton):
	for I in get_tree().get_nodes_in_group("requireDataset"):
		I.disabled = false
	selectedQuiz = button.get_meta("quiz",null)


func sortCreation(a : Quiz, b: Quiz):
	if a.creationDate > b.creationDate:
		return true
	return false



func loadQuizs():
	var filePaths = DirAccess.open("user://").get_files()
	for filePath in filePaths:
		if filePath.get_extension() == "tres":
			var resource = ResourceLoader.load("user://"+filePath)
			if resource is Quiz:
				loadedQuizs.append(resource)
	
	loadedQuizs.sort_custom(sortCreation)
	
	for quiz : Quiz in loadedQuizs:
		var newButton = Button.new()
		newButton.toggle_mode = true
		newButton.button_group = buttonGroup
		newButton.text = quiz.displayName
		quizBox.add_child(newButton)
		newButton.set_meta("quiz",quiz)


func pressedSelected():
	QuestionImporter.loadedQuiz = selectedQuiz
	get_tree().change_scene_to_file("res://scenes/gameSelect.tscn")


func _on_option_button_item_selected(index):
	ThemeController.currentTheme = themeButton.get_item_metadata(index)
