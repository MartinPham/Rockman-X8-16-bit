extends MusicPlayer

func play_miniboss_song() -> void :
	volume_db = volume
	queue_loop_if_needed(miniboss_intro, miniboss_song)
	fade_out = false
	slow_fade_out = false
	play()
