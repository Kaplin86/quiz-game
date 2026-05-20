extends Node
class_name QuestionImporterNode

## A class built around finding and parsing given CSV files into godot resources.

func locateCSV():
	var fileRequest := FileDialog.new()
	fileRequest.access = FileDialog.ACCESS_FILESYSTEM
	fileRequest.use_native_dialog = true
	fileRequest.add_filter("*.csv","A Comma-seperated value file")
	
	add_child(fileRequest)
	fileRequest.visible = true
