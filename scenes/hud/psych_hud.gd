extends BaseHud

@onready var time_txt: Label = $text

@onready var timebar: ProgressBar = $timebar
@onready var healthbar_bg: TextureRect = $healthbarBG
@onready var healthbar: ProgressBar = $healthbarBG/healthbar

@onready var icon_p1: Sprite2D = $iconp1
@onready var icon_p2: Sprite2D = $iconp2
@onready var score_txt: Label = $score_txt
var rating_fc:String = "N/A"
var rating_name:String = ""
var rating_group:Node2D = Node2D.new()
func reload_icon_textures():
	icon_p2.texture = Game.instance.player_list[0].chars[0].icon
	icon_p1.texture = Game.instance.player_list[1].chars[0].icon
	pass
func _ready() -> void:
	score_txt.text = "Score: 0 | Misses: 0 | Rating: ?"
	pivot_offset = size/2
	print("psych hud")
	timebar.max_value = Conductor.audio.stream.get_length()
	timebar.value = 0
	timebar.modulate.a = 0
	time_txt.modulate.a = 0
	add_child(rating_group)
	healthbar_bg.position.x = size.x / 2 - healthbar.size.x/2
	print(Game.instance.player_field)
	if SaveMan.save.downscroll:
		time_txt.position.y = size.y - 44
		healthbar_bg.position.y = size.y*0.11
		icon_p1.position.y = healthbar_bg.position.y
		icon_p2.position.y = healthbar_bg.position.y
		
	
		
	timebar.position.y = time_txt.position.y + time_txt.size.y/4
	timebar.position.x = size.x / 2 - timebar.size.x/2
	time_txt.position.x = size.x / 2 - time_txt.size.x/2
	score_txt.position.y = healthbar_bg.position.y + 40
	Conductor.beat_hit.connect(_on_beat_hit)
	reload_icon_textures()
func update_score_text():
	if stats.ratings.good == 0 and stats.ratings.bad == 0 and stats.ratings.shit == 0 and stats.combo_breaks == 0:
			rating_name = "Perfect!!"
	else:
		rating_name = "Sick!"
	if stats.accuracy < 0.9:
		rating_name = "Great"
	if stats.accuracy < 0.8:
		rating_name = "Good"
	if stats.accuracy < 0.7:
		rating_name = "Nice"
	if stats.accuracy < 0.69:
		rating_name = "Meh"
	if stats.accuracy < 0.6:
		rating_name = "bruh"
	if stats.accuracy < 0.5:
		rating_name = "Bad"
	if stats.accuracy < 0.4:
		rating_name = "Shit"
	if stats.accuracy < 0.2:
		rating_name = "You Suck!"
	var rating_text = "%s (%.3f%%) - %s" %[rating_name,stats.accuracy*100.0,rating_fc]
	
	score_txt.text = "Score: %d | Misses: %d | Rating: %s" %[stats.score,stats.combo_breaks,rating_text]
	pass
func format_time(total_seconds: float) -> String:
	#total_seconds = 12345
	var seconds:float = fmod(total_seconds , 60.0)
	var minutes:int   =  int(total_seconds / 60.0) % 60
	var hhmmss_string:String = "%2d:%02d" % [minutes, seconds]
	return hhmmss_string
func on_song_start():
	create_tween().tween_property(timebar,"modulate:a",1,0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	create_tween().tween_property(time_txt,"modulate:a",1,0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
var bar_center:float = 0
func _process(delta: float) -> void:
	healthbar.value = 2.0 - stats.health
	timebar.value = Conductor.time
	time_txt.text = format_time(Conductor.time)
	# icon shit
	bar_center = healthbar_bg.position.x + 6 + (healthbar.value / healthbar.max_value)*healthbar.size.x
	const icon_offset = 26
	
	icon_p1.position.x = bar_center + (150 * icon_p1.scale.x - 150) / 2 - icon_offset + 75
	icon_p2.position.x = bar_center - (150 * icon_p1.scale.x) / 2 - icon_offset * 2 + 75
	
	var mult:float = lerp(1.0,icon_p1.scale.x,exp(-delta*9))
	icon_p1.scale = Vector2(mult,mult)
	icon_p2.scale = Vector2(mult,mult)
func check_fc():
	
	if stats.combo_breaks == 0:
		rating_fc = "SFC"
		if stats.ratings.good != 0:
			rating_fc = "GFC"
		if stats.ratings.bad > 0 or stats.ratings.shit > 0:
			rating_fc = "FC"
	if stats.combo_breaks >= 1:
		rating_fc = "SDCB"
	if stats.combo_breaks >= 10:
		rating_fc = "Clear"
	pass
func on_note_rate(player:Player,_rating:NoteRating):
	check_fc()
	if _rating.rating == "invalid" or not player.does_input:
		return
	
	var rating:VelocitySprite = VelocitySprite.new()
	rating.centered = false
	rating.texture = skin.get("%s_texture"%_rating.rating)
	rating.scale = Vector2(0.7,0.7)
	rating.acceleration.y = 550
	rating.velocity.x -= randi_range(0,10)
	rating.velocity.y -= randi_range(145,175)
	const placement = 1280*0.35
	rating.position.x = placement - 40
	rating.position.y = (360 - rating.get_rect().size.y/2) - 60
	rating_group.add_child(rating)
	var rating_tween = create_tween().set_parallel()
	rating_tween.tween_property(rating,"modulate:a",0,0.2).set_delay(Conductor.beat_crochet).finished.connect(func(): rating.queue_free())
	## show combo
	var combo_pad = str(player.stats.combo).pad_zeros(3)
	var daloop:int = 0
	for i in combo_pad:
		var num_score:VelocitySprite = VelocitySprite.new()
		num_score.texture = skin.combo_texture
		num_score.hframes = 10
		num_score.frame = int(i)
		num_score.centered = false
		num_score.scale = Vector2(0.5,0.5)
		num_score.position = Vector2(640 - num_score.get_rect().size.x/2,360 - num_score.get_rect().size.y/2)
		num_score.position.x = placement + (43*daloop) - 90
		num_score.position.y += 80
		num_score.acceleration.y = randi_range(200,300)
		num_score.velocity = Vector2(randf_range(-5,-5),randi_range(-140,-160))
		var num_tween = create_tween().set_parallel()
		num_tween.tween_property(num_score,"modulate:a",0,0.2)\
		.set_delay(Conductor.beat_crochet*2).finished.connect(func():num_score.queue_free())
		add_child(num_score)
		daloop += 1
		update_score_text()
		
		
		
		
		pass
func on_note_miss(player:Player,note:Note):
	update_score_text()
	pass
func _on_beat_hit(b):
	icon_p1.scale = Vector2(1.2,1.2)
	icon_p2.scale = Vector2(1.2,1.2)
