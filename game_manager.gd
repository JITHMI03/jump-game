extends Node

const MAX_LIVES = 3

@onready var pointslabel: Label = %pointslabel
@export var hearts: Array[Node]
@export var game_over_node: Node

var points = 0
var lives = MAX_LIVES

func decrease_health() -> void:
	lives -= 1
	for h in hearts.size():
		if hearts[h]:
			if h < lives:
				hearts[h].show()
			else:
				hearts[h].hide()
	if lives == 0:
		_show_game_over()

func _show_game_over() -> void:
	if game_over_node:
		var panel = game_over_node.get_node_or_null("GameOverPanel")
		if panel:
			var score_lbl = panel.get_node_or_null("VBoxContainer/score_label")
			if score_lbl:
				score_lbl.text = "Score: " + str(points)
			panel.show()
		get_tree().paused = true
	else:
		get_tree().reload_current_scene()

func add_point() -> void:
	points += 1
	pointslabel.text = "Collected: " + str(points)
