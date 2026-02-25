extends Node

@export var hearts: Array[Node]
@onready var pointslabel: Label = %pointslabel
@onready var multiplierlabel: Label = %multiplierlabel

func _ready() -> void:
	GameManager.reset()
	_refresh_hearts(GameManager.lives)
	pointslabel.text = "Collected: 0"
	multiplierlabel.visible = false
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.points_changed.connect(_on_points_changed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.multiplier_changed.connect(_on_multiplier_changed)

func _on_health_changed(lives: int) -> void:
	_refresh_hearts(lives)

func _on_points_changed(pts: int) -> void:
	pointslabel.text = "Collected: " + str(pts)

func _on_multiplier_changed(mult: int) -> void:
	if mult > 1:
		multiplierlabel.text = "x" + str(mult) + " COMBO!"
		multiplierlabel.visible = true
	else:
		multiplierlabel.visible = false

func _on_game_over(pts: int) -> void:
	var root = get_tree().current_scene
	var panel = root.get_node_or_null("ui/game_over/GameOverPanel")
	if panel:
		var score_lbl = panel.get_node_or_null("VBoxContainer/score_label")
		if score_lbl:
			var best = GameManager.best_score
			score_lbl.text = "Score: " + str(pts) + ("  |  Best: " + str(best) if best > 0 else "")
		panel.show()
	get_tree().paused = true

func _refresh_hearts(lives: int) -> void:
	for h in hearts.size():
		if hearts[h]:
			if h < lives:
				hearts[h].show()
			else:
				hearts[h].hide()
