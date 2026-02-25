extends Node

@export var hearts: Array[Node]
@export var game_over_node: Node
@onready var pointslabel: Label = %pointslabel

func _ready() -> void:
	GameManager.reset()
	_refresh_hearts(GameManager.lives)
	pointslabel.text = "Collected: 0"
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.points_changed.connect(_on_points_changed)
	GameManager.game_over.connect(_on_game_over)

func _on_health_changed(lives: int) -> void:
	_refresh_hearts(lives)

func _on_points_changed(pts: int) -> void:
	pointslabel.text = "Collected: " + str(pts)

func _on_game_over(pts: int) -> void:
	if game_over_node:
		var panel = game_over_node.get_node_or_null("GameOverPanel")
		if panel:
			var score_lbl = panel.get_node_or_null("VBoxContainer/score_label")
			if score_lbl:
				score_lbl.text = "Score: " + str(pts)
			panel.show()
	get_tree().paused = true

func _refresh_hearts(lives: int) -> void:
	for h in hearts.size():
		if hearts[h]:
			if h < lives:
				hearts[h].show()
			else:
				hearts[h].hide()
