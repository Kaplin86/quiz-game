extends Node
class_name QuestionImporterNode

## A class built around finding and parsing given CSV files into godot resources.

signal _endRequest(file : String)

var _questionPathHold = ""

## Asks the user for a .csv, a .tsv, or a .quiz file and returns the path. Will return "" if a invalid path is selected.
func locateCSV() -> String:
	var fileRequest := FileDialog.new()
	fileRequest.access = FileDialog.ACCESS_FILESYSTEM
	fileRequest.use_native_dialog = true
	fileRequest.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fileRequest.add_filter("*.csv","CSV File")
	fileRequest.add_filter("*.tsv","TSV File")
	fileRequest.add_filter("*.quiz","Quiz File")
	
	
	add_child(fileRequest)
	fileRequest.visible = true
	
	fileRequest.file_selected.connect(func(_file):
		print("hi file selected and its ", _file)
		_endRequest.emit(_file)
		)
	fileRequest.canceled.connect(func(): _endRequest.emit(""))
	
	var file : String =  await _endRequest
	if !file.get_extension() in ["csv","tsv","quiz"]:
		return ""
	
	return file

## Reads the file at the path and will attempt to form it into a 2d array
func parseFilePathToGrid(filePath,delim = ",") -> Array[PackedStringArray]:
	var fileOpening = FileAccess.open(filePath,FileAccess.READ)
	var grid : Array[PackedStringArray] = []
	while not fileOpening.eof_reached():
		var lin = fileOpening.get_csv_line(delim)
		grid.append(lin)
	
	fileOpening.close() 
	return grid

## Parses passed data and turns it into Question resources. Requires a question and answer column. Optionally takes incorrect column array and a reason column
func parseDataToQuestionResource(data : Array[PackedStringArray],qColumn, aColumn, iColumn = [], rColumn = -1) -> Array[Question]:
	var index = 0
	var questions : Array[Question] = []
	for row : PackedStringArray in data:
		if index == 0:
			index += 1 
			continue
		var qText = row[qColumn]
		var aText = row[aColumn]
		var question := Question.new(qText,aText)
		
		if iColumn != []:
			for ii in iColumn:
				question.falseAnswers.append(row[ii])
		
		if rColumn != -1:
			question.answerReason = row[rColumn]
		
		questions.append(question)
	return questions
