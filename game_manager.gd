extends Node

const MAX_LIVES = 3
const MULTIPLIER_DURATION = 3.0
const SAVE_PATH = "user://savegame.json"

signal health_changed(lives: int)
signal points_changed(points: int)
signal game_over(points: int)
signal multiplier_changed(multiplier: int)

var points := 0
var lives := MAX_LIVES
var multiplier := 1
var best_score := 0
var _multiplier_timer := 0.0

func _ready() -> void:
	_load_best_score()

func _process(delta: float) -> void:
	if _multiplier_timer > 0.0:
		_multiplier_timer -= delta
		if _multiplier_timer <= 0.0:
			_multiplier_timer = 0.0
			multiplier = 1
			multiplier_changed.emit(multiplier)

func reset() -> void:
	points = 0
	lives = MAX_LIVES
	multiplier = 1
	_multiplier_timer = 0.0

func decrease_health() -> void:
	multiplier = 1
	_multiplier_timer = 0.0
	multiplier_changed.emit(multiplier)
	lives -= 1
	health_changed.emit(lives)
	if lives <= 0:
		_check_best_score()
		game_over.emit(points)

func add_point() -> void:
	points += multiplier
	points_changed.emit(points)

func trigger_stomp_multiplier() -> void:
	multiplier = min(multiplier + 1, 4)
	_multiplier_timer = MULTIPLIER_DURATION
	multiplier_changed.emit(multiplier)

func _check_best_score() -> void:
	if points > best_score:
		best_score = points
		_save_best_score()

func save_best_score() -> void:
	_check_best_score()

func _save_best_score() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"best_score": best_score}))
		file.close()

func _load_best_score() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var data = JSON.parse_string(text)
		if data and data.has("best_score"):
			best_score = int(data["best_score"])
