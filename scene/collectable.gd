extends Area2D

@export var sfx_collect: AudioStream

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if sfx_collect:
			var player = AudioStreamPlayer.new()
			player.stream = sfx_collect
			get_tree().root.add_child(player)
			player.play()
			player.finished.connect(player.queue_free)
		queue_free()
		GameManager.add_point()
