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

func _init(sourcePath : String, questions : Array[Question], questionColumn : int, answerColumn : int, incorrectColumn : Array[int] = [], descColumn : int = -1):
	self.sourcePath = sourcePath
	self.questions = questions
	self.questionColumn = questionColumn
	self.answerColumn = answerColumn
	self.incorrectColumn = incorrectColumn
	self.descColumn = descColumn
	
	_hash = FileAccess.get_sha256(sourcePath)
