extends CanvasLayer

var _overlay: ColorRect

func _ready() -> void:
	layer = 100
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 1)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)
	get_tree().node_added.connect(_on_node_added)
	_fade_in()

func fade_to_scene(path: String) -> void:
	var tween = create_tween()
	tween.tween_property(_overlay, "color:a", 1.0, 0.3)
	await tween.finished
	get_tree().change_scene_to_file(path)

func fade_to_packed(scene: PackedScene) -> void:
	var tween = create_tween()
	tween.tween_property(_overlay, "color:a", 1.0, 0.3)
	await tween.finished
	get_tree().change_scene_to_packed(scene)

func _on_node_added(node: Node) -> void:
	if node == get_tree().current_scene:
		_fade_in()

func _fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(_overlay, "color:a", 0.0, 0.4)
