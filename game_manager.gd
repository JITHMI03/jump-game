extends Node

const MAX_LIVES = 3

signal health_changed(lives: int)
signal points_changed(points: int)
signal game_over(points: int)

var points := 0
var lives := MAX_LIVES

func reset() -> void:
	points = 0
	lives = MAX_LIVES

func decrease_health() -> void:
	lives -= 1
	health_changed.emit(lives)
	if lives <= 0:
		game_over.emit(points)

func add_point() -> void:
	points += 1
	points_changed.emit(points)
