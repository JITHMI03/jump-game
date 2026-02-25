extends Area2D

const PARTICLES_SCENE = preload("res://scene/particles.tscn")

@export var sfx_collect: AudioStream

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if sfx_collect:
			var player = AudioStreamPlayer.new()
			player.stream = sfx_collect
			get_tree().root.add_child(player)
			player.play()
			player.finished.connect(player.queue_free)
		# Spawn collect particles
		var particles = PARTICLES_SCENE.instantiate()
		particles.global_position = global_position
		get_tree().root.add_child(particles)
		if particles.has_signal("animation_finished"):
			particles.animation_finished.connect(particles.queue_free)
		else:
			var timer = get_tree().create_timer(0.4)
			timer.timeout.connect(particles.queue_free)
		queue_free()
		GameManager.add_point()
