extends Resource
class_name Quiz

## A class that stores a saved quiz. This includes questions, bindings, and more.

## The path to the source file (csv / tsv)
@export var sourcePath : String = ""
## The array of questions
@export var questions : Array[Question]
## The column questions are pulled from. Should be treated as read-only
@export var questionColumn : int
## The column answers are pulled from. Should be treated as read-only
@export var answerColumn : int
## The columns incorrect answers are pulled from. Should be treated as read-only
@export var incorrectColumn : Array[int] = []
## The column answer descriptions are pulled from. Should be treated as read-only
@export var descColumn : int = -1

@export var _hash = ""
@export var creationDate : float
@export var displayName : String

func _init(src : String = "", question : Array[Question]= [], questionCol : int= -1, answerCol : int= -1, incorrectCol : Array[int] = [], descCol : int = -1):
	if src == "":
		return
	self.sourcePath = src
	self.questions = question
	self.questionColumn = questionCol
	self.answerColumn = answerCol
	self.incorrectColumn = incorrectCol
	self.descColumn = descCol
	
	creationDate = Time.get_unix_time_from_system()
	displayName = src.get_file().get_basename()
	
	_hash = FileAccess.get_sha256(src)
