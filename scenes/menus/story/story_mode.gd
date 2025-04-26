extends Node2D
@export var levels:Array[LevelData] = []

@onready var level_display: CanvasLayer = $level_display

var cur_selected:float = 0
@onready var tracks_txt: Label = $"tracks/tracks txt"
@onready var week_score_txt: Label = $"black/week score txt"
var lerped_week_score:int = 0
var week_score:int = 0
var difficulty_textures:Array[Texture] = [load("res://assets/levels/images/difficultys/easy.png"), load("res://assets/levels/images/difficultys/hard.png"), load("res://assets/levels/images/difficultys/normal.png")]
@onready var difficulty_display: Sprite2D = $"difficulty_display/difficultys shit/difficulty display"
@onready var left: AnimatedSprite2D = $"difficulty_display/difficultys shit/left"
@onready var right: AnimatedSprite2D = $"difficulty_display/difficultys shit/right"

func _ready() -> void:
	create_level_display()
	change_level_select(0)
	change_difficulty(0)
var cur_difficulty:int = 1
var difficulty:String = "normal"
var difficultys:Array = ["easy","normal","hard"]
func change_level_select(p:int):
	cur_selected = wrap(cur_selected + p,0,levels.size())
	tracks_txt.text = ""
	var q = levels[cur_selected]
	week_score = HighScore.get_level_score(q.level_name,"hard")[0]
	
	var sp = ""
	var penis_id:int = 0
	var limit = levels[cur_selected].level_songs_shown
	for penisass in q.level_songs:
		if penis_id >= limit and not limit <= 0:
			continue
		
		sp += penisass.to_upper()
		sp += "\n"
		penis_id += 1 
	tracks_txt.text = sp
	AudioManager.play_sfx(AudioManager.MENU_SCROLL)
	await RenderingServer.frame_post_draw
	tracks_txt.position.y = 30
func load_level():
	AudioManager.play_sfx(AudioManager.MENU_CONFIRM)
	var level := levels[cur_selected]
	Game.campaign_songs = level.level_songs
	Game.level_name = level.level_name
	Game.song_name = level.level_songs[0]
	Game.song_diff = difficulty
	Game.play_mode = Game.PlayMode.CAMPAIGN
	print(Game.song_diff)
	SceneManager.switch_scene("uid://cgla7xsm2aocj")
	
func create_level_display():
	var penis:int = 1
	for i in levels:
		var spr := Sprite2D.new()
		spr.texture = i.level_image
		spr.centered = false
		spr.position.x -= spr.texture.get_width()/2
		spr.position.y += (max(110,spr.texture.get_height()) + 10) * penis
		level_display.add_child(spr)
		penis += 1
var cock = false
func change_difficulty(p:int):
	# no cock
	if cock:
		cock = false
	var t = get_tree().create_tween().set_parallel(true)
	cur_difficulty = wrap(cur_difficulty + p,0,difficultys.size())
	difficulty = difficultys[cur_difficulty]
	
	difficulty_display.texture = load("res://assets/levels/images/difficultys/%s.png"%difficulty)
	difficulty_display.position.y = left.position.y - (difficulty_display.texture.get_height() / 2) + 75
	t.tween_property(difficulty_display,"position:y",difficulty_display.position.y - 40,0.07)
	t.tween_property(difficulty_display,"modulate:a",1.0,0.07)
	cock = true
func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed("ui_cancel"):
		SceneManager.switch_scene("uid://dv4w8fl053lxq")
	if event.is_action_pressed("ui_down"):
		change_level_select(1)
	if event.is_action_pressed("ui_up"):
		change_level_select(-1)
	if event.is_action_pressed("ui_accept"):
		load_level()
	if event.is_action_pressed("ui_left"):
		change_difficulty(-1)
	if event.is_action_pressed("ui_right"):
		change_difficulty(1)
		
		
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		left.play("arrow push left")
	if Input.is_action_just_released("ui_left"):
		left.play("arrow left")
		
	if Input.is_action_just_pressed("ui_right"):
		right.play("arrow push right")
	if Input.is_action_just_released("ui_right"):
		right.play("arrow right")
	
	var COCK = level_display.get_child(cur_selected)
	level_display.offset.y = lerp(level_display.offset.y,452 - (COCK.position.y - COCK.texture.get_height()/2),10.2 * delta)
	lerped_week_score = floor(lerp(lerped_week_score,week_score,delta*30))
	if abs(lerped_week_score - week_score) <= 50:
		lerped_week_score = week_score
	week_score_txt.text = "WEEK SCORE: %d" %lerped_week_score
