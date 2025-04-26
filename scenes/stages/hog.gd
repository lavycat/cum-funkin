extends Stage
@onready var overlay: Sprite2D = $Parallax2D4/Overlay
@onready var trees: Sprite2D = $Parallax2D2/trees
@onready var mount_hog: Sprite2D = $"Parallax2D/mount hog"
@onready var floor_spr: Sprite2D = $Sprite2D
@onready var rocks: Sprite2D = $Parallax2D3/Rocks
@onready var bg:TextureRect = $Parallax2D/bg
@onready var water: AnimatedSprite2D = $water
@onready var loops: AnimatedSprite2D = $Parallax2D2/loops
var do_glitch:bool = false
@onready var glitch: ColorRect = $shaders/glitch
var glitchamount:float = 0.3:
	set(v):
		glitchamount = min(v,1.0)
		glitch.material.set_shader_parameter("Amount",glitchamount)
var new_loops:Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Conductor.beat_hit.connect(beathit)
	Conductor.step_hit.connect(step)
	if Game.instance:
		var cpu_player:Player = Game.instance.player_list[0] as Player
		cpu_player.notehit.connect(cpu_note_hit)
	## trying to cache shader
	await RenderingServer.frame_post_draw
	glitch.visible = false
	
	pass # Replace with function body.
func step(s):
	match s:
		864:
			change_bg()

func change_bg():
	new_loops = Sprite2D.new()
	overlay.visible = false
	trees.texture = load("res://assets/stages/hog/hog 2/Plants.png")
	trees.position.x += 200
	trees.position.y += 60
	mount_hog.texture = load("res://assets/stages/hog/hog 2/Mountains.png")
	floor_spr.texture = load("res://assets/stages/hog/hog 2/Floor.png")
	floor_spr.position -= Vector2(-200, -30)
	rocks.texture = load("res://assets/stages/hog/hog 2/Rocks.png")
	bg.texture = load("res://assets/stages/hog/hog 2/Sunset.png")
	bg.position.y += 300.0
	water.sprite_frames = load("res://assets/stages/hog/hog 2/Waterfalls.res")
	water.play("British instance 1")
	new_loops.texture = load("res://assets/stages/hog/hog 2/Hills.png")
	new_loops.position = Vector2(0, 230)
	new_loops.centered = false
	loops.add_sibling(new_loops)
	loops.sprite_frames.clear_all()
	loops.visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if do_glitch:
		glitchamount = lerp(glitchamount,0.1,delta*3.125)
	else:
		glitchamount = 0.0

func beathit(beat:int):
	if do_glitch:
		glitchamount += 0.2
	
func cpu_note_hit(player:Player,note:Note):
	if note.sustain_ticking and do_glitch:
		glitchamount += 0.04 * (1.0 + note.og_sustain_length*Conductor.step_crochet)
