extends Resource
class_name Question

## A resource that stores the data about a question. Requires both a question and an answer.

## The question
@export var question : String
## The answer to question
@export var answer : String
## Any binding "incorrect answers"
@export var falseAnswers : Array[String] = []
## Optional reason on why answer is correct.
@export var answerReason : String = ""

## The history of whether the person got this question right or wrong. This should not be shared on export and only be saved locally.
@export var history : Array[bool] = []

func _init(quest := "",answ := ""):
	question = quest
	answer = answ

func _to_string():
	return question + "("+answer+", with " + str(falseAnswers.size()) + " incorrect)"
