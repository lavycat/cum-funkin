extends Node2D
@onready var anim_player: AnimationPlayer = $anim_player
@onready var sprite: AnimatedSprite2D = $sprite
@onready var camera_position: Marker2D = $sprite/camera_position
@export var music_stream:AudioStream
@export var death_sound_sfx:AudioStream
@export var retry_sound_sfx:AudioStream


var music:AudioStreamPlayer = AudioStreamPlayer.new()
var death:AudioStreamPlayer = AudioStreamPlayer.new()
var retry:AudioStreamPlayer = AudioStreamPlayer.new()
var retrying:bool = false
func _ready() -> void:
	music.stream = music_stream
	death.stream  = death_sound_sfx
	retry.stream = retry_sound_sfx
	add_child(death)
	add_child(music)
	add_child(retry)
	anim_player.play("death")
	death.play()
	await sprite.animation_finished
	if retrying: return
	anim_player.play("death_loop")
	music.play()
	
func _input(event: InputEvent) -> void:
	if retrying:
		return
	if event.is_action_pressed("ui_accept"):
		retrying = true
		anim_player.play("retry")
		retry.play()
		music.stop()
		var t = create_tween().tween_property(sprite,"modulate:a",0,2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC).set_delay(0.7)
		await t.finished
		get_tree().change_scene_to_file("res://scenes/gmae.tscn")
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
