extends Node

const HINT_SCENE = preload("res://scene/tutorial_hint.tscn")

var _hint_node: Node = null
var _shown_hints: Dictionary = {}

func _ready() -> void:
	_load_shown_hints()

func _ensure_hint_node() -> void:
	if _hint_node and is_instance_valid(_hint_node):
		return
	_hint_node = HINT_SCENE.instantiate()
	get_tree().root.add_child(_hint_node)

func show(hint_id: String, text: String) -> void:
	if GameManager.get_meta("hints_disabled", false):
		return
	if _shown_hints.has(hint_id):
		return
	_shown_hints[hint_id] = true
	_save_shown_hints()
	_ensure_hint_node()
	if _hint_node.has_method("show_hint"):
		_hint_node.show_hint(hint_id, text)

func reset() -> void:
	_shown_hints.clear()
	_save_shown_hints()

func _save_shown_hints() -> void:
	var file = FileAccess.open("user://hints.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_shown_hints))
		file.close()

func _load_shown_hints() -> void:
	if not FileAccess.file_exists("user://hints.json"):
		return
	var file = FileAccess.open("user://hints.json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		if data:
			_shown_hints = data
