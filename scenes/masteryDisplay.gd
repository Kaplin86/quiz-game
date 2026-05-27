extends Control
class_name MasteryDisplay

func displayQuiz(quiz : Quiz):
	var trues = 0
	var total = 0
	for question : Question in quiz.questions:
		total += 2
		if question.history.size() != 0:
			if question.history[-1]: trues +=1
			if question.history.size() >= 2:
				if question.history[-2]: trues += 1
	
	print(trues, "vs", total)
	
	var correctPercent
	if trues != 0:
		correctPercent = float(trues)/float(total)
	else:
		correctPercent = 0
	var incorrectPercent = 1-correctPercent
	print(correctPercent, "from ", total, " / ", trues)
	get_child(1).value = incorrectPercent * 360
	get_child(0).radial_initial_angle = incorrectPercent * 360
	get_child(0).value = correctPercent * 360
	
	$"../Label".text = "Mastery Progress %" + str(int(correctPercent * 100))

func _on_theme_changed():
	var root : Control = get_tree().current_scene
	var correctColor = root.get_theme_color("correct","MasteryTracker")
	var incorrectColor = root.get_theme_color("incorrect","MasteryTracker")
	
	if !correctColor: correctColor = Color.GREEN
	if !incorrectColor: incorrectColor = Color.RED
	
	get_child(0).tint_progress = correctColor
	get_child(1).tint_progress = incorrectColor
