extends Node
@onready var game:Game = get_tree().current_scene
#var dumb1:SpriteFrames = preload("res://assets/characters/hog/ScorchedGlitch.res")
#var dumb2:SpriteFrames = preload("res://assets/characters/hog/scorchedwithglitch2.res")
#var dumb3:SpriteFrames = preload("res://assets/characters/hog/scorched.res")
# Called when the node enters the scene tree for the first time.

@onready var scorched = load("res://scenes/characters/scorched.tscn")
@onready var scorched_glitch = load("res://scenes/characters/scorched_glitch.tscn")

func _ready() -> void:
	name = "events"
	Conductor.step_hit.connect(step)
	print("song script ready")
	print(game)
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
#func _exit_tree() -> void:
	#preloaded_stuffs.clear()
func step(_step:int) -> void:
	if _step == 560:
		var cpu_player:Player = game.player_list[0] as Player
		for i in cpu_player.chars:
			i.play_anim("transrights",true)
	if _step == 864:
		var newchar = scorched.instantiate()
		game.stage.add_child(newchar)
		var cpu_player:Player = game.player_list[0] as Player
		for i in cpu_player.chars:
			i.queue_free()
			i.sprite.sprite_frames.clear_all()
		cpu_player.chars.clear()
		cpu_player.chars.append(newchar)
		newchar.position = game.stage.cpu.position
		game.hud.reload_icon_textures()
	if _step == 4160:
		if Game.shaders:
			game.stage.glitch.visible = true
			game.stage.do_glitch = true
		var newchar = scorched_glitch.instantiate()
		game.stage.add_child(newchar)
		
		var cpu_player:Player = game.player_list[0] as Player
		
		for i in cpu_player.chars:
			i.queue_free()
		cpu_player.chars.clear()
		cpu_player.chars.append(newchar)
		newchar.position = game.stage.cpu.position
		scorched = null
		
