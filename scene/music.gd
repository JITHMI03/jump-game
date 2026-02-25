extends AudioStreamPlayer

# Attach this script to an AudioStreamPlayer in each level.
# Set the stream via the @export in the Inspector, then it loops automatically.

@export var bgm: AudioStream

func _ready() -> void:
	if bgm:
		stream = bgm
		play()

# Fade in on level load
func fade_in(duration := 1.5) -> void:
	volume_db = -80.0
	var tween = create_tween()
	tween.tween_property(self, "volume_db", 0.0, duration)

# Fade out (e.g. before scene change)
func fade_out(duration := 1.0) -> void:
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -80.0, duration)
	await tween.finished
	stop()
