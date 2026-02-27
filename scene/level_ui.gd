extends Node

@export var hearts: Array[Node]
@onready var pointslabel: Label = %pointslabel
@onready var multiplierlabel: Label = %multiplierlabel

var sfx_game_over: AudioStream = preload("res://sfx_game_over.wav")
var sfx_player_death: AudioStream = preload("res://sfx_player_death.wav")

func _play_sfx(stream: AudioStream) -> void:
	if not stream:
		return
	var p = AudioStreamPlayer.new()
	p.stream = stream
	p.pitch_scale = randf_range(0.95, 1.05)
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func _ready() -> void:
	GameManager.reset()
	_refresh_hearts(GameManager.lives)
	pointslabel.text = "Collected: 0"
	multiplierlabel.visible = false
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.points_changed.connect(_on_points_changed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.multiplier_changed.connect(_on_multiplier_changed)
	# Show tutorial hints on first play
	_show_level_hints()

func _show_level_hints() -> void:
	await get_tree().create_timer(0.5).timeout
	var scene_path = get_tree().current_scene.scene_file_path
	if "level1" in scene_path:
		Tutorial.show("controls", "Arrow keys/WASD to move, Space to jump!")
	elif "level2" in scene_path:
		Tutorial.show("dash", "Press Shift to dash through enemies!")
	elif "level3" in scene_path:
		Tutorial.show("walljump", "Jump into walls to wall-slide and wall-jump!")
	elif "boss" in scene_path:
		Tutorial.show("boss", "Stomp the boss 3 times to defeat it!")

func _on_health_changed(lives: int) -> void:
	_refresh_hearts(lives)
	if lives <= 0:
		_play_sfx(sfx_player_death)

func _on_points_changed(pts: int) -> void:
	pointslabel.text = "Collected: " + str(pts)

func _on_multiplier_changed(mult: int) -> void:
	# Use the actual multiplier from GameManager to avoid desync
	var actual_mult = GameManager.multiplier
	if actual_mult > 1:
		multiplierlabel.text = "x" + str(actual_mult) + " COMBO!"
		multiplierlabel.visible = true
	else:
		multiplierlabel.visible = false

func _on_game_over(pts: int) -> void:
	_play_sfx(sfx_game_over)
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
