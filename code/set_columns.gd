extends Control

var fileGrid : Array[PackedStringArray]
var headers : PackedStringArray = []
@export var panelContainerToDupe : Node

func _ready() -> void:
	#temp
	var path = await QuestionImporter.locateCSV()
	fileGrid = QuestionImporter.parseFilePathToGrid(path)
	#
	
	headers = fileGrid[0]
	fillOptionBoxes()

func fillOptionBoxes():
	for box : OptionButton in get_tree().get_nodes_in_group("headerDropdown"):
		fillBox(box)

func fillBox(box : OptionButton):
	box.clear()
	if !box.is_in_group("requiredInput"):
		box.add_item("",0)
		box.set_item_metadata(0,"EMPTY")
	var index = 0
	for text : String in headers:
		box.add_item(text)
		box.set_item_metadata(-1,index)
		index += 1

func _on_button_pressed() -> void:
	var newPanel = panelContainerToDupe.duplicate()
	panelContainerToDupe.add_sibling(newPanel)
	panelContainerToDupe.get_parent().move_child(newPanel,-2)
	
	var optionBox = newPanel.find_child("OptionButton",true,false)
	optionBox.set_meta("type","incorrect")
	var label = newPanel.find_child("Label",true,false)
	label.text = "Incorrect Answer"
	
	fillBox(optionBox)
