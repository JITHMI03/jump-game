extends Node

enum Difficulty { EASY, NORMAL, HARD }

const MULTIPLIER_DURATION = 3.0
const SAVE_PATH = "user://savegame.json"

# Difficulty settings: [lives, enemy_speed_mult]
const DIFFICULTY_DATA = {
	Difficulty.EASY: {"lives": 5, "enemy_speed": 0.7},
	Difficulty.NORMAL: {"lives": 3, "enemy_speed": 1.0},
	Difficulty.HARD: {"lives": 2, "enemy_speed": 1.3}
}

signal health_changed(lives: int)
signal points_changed(points: int)
signal game_over(points: int)
signal multiplier_changed(multiplier: int)
signal difficulty_changed(diff: Difficulty)

var difficulty: Difficulty = Difficulty.NORMAL
var points := 0
var lives := 3
var multiplier := 1
var best_score := 0
var _multiplier_timer := 0.0
var completed_levels: Dictionary = {}  # {"level1": true, "level2": true, etc.}

func get_max_lives() -> int:
	return DIFFICULTY_DATA[difficulty]["lives"]

func get_enemy_speed_mult() -> float:
	return DIFFICULTY_DATA[difficulty]["enemy_speed"]

func set_difficulty(diff: Difficulty) -> void:
	difficulty = diff
	difficulty_changed.emit(diff)
	_save_settings()

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
	lives = get_max_lives()
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

func mark_level_complete(level_name: String) -> void:
	completed_levels[level_name] = true
	_save_progress()

func is_level_complete(level_name: String) -> bool:
	return completed_levels.get(level_name, false)

func _save_progress() -> void:
	var data = {
		"best_score": best_score,
		"difficulty": int(difficulty),
		"completed_levels": completed_levels
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

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
		if data == null:
			push_warning("GameManager: Failed to parse save file, may be corrupted")
			return
		if data.has("best_score"):
			best_score = int(data["best_score"])
		if data.has("difficulty"):
			difficulty = int(data["difficulty"]) as Difficulty
		if data.has("completed_levels"):
			completed_levels = data["completed_levels"]

func _save_settings() -> void:
	# Load existing data first to preserve best_score
	var data = {"best_score": best_score, "difficulty": int(difficulty)}
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var existing = JSON.parse_string(file.get_as_text())
			file.close()
			if existing and existing.has("best_score"):
				data["best_score"] = existing["best_score"]
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
