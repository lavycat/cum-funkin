extends Node2D

var fullscreen:bool = false
@export var overlay:VBoxContainer
@onready var voume_bar: ProgressBar = $"CanvasLayer/overlay/voume bar"
@onready var canvas_layer: CanvasLayer = $CanvasLayer

var overlay_pos:Vector2
var timer:float = 0.0
func show_overlay():
	overlay_pos.y = 0
	timer = 1.0
func hide_overlay():
	overlay_pos.y = -100
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	RenderingServer.set_default_clear_color(Color.BLACK)
	show_overlay()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	canvas_layer.offset = lerp(canvas_layer.offset,overlay_pos,delta*12.0)
	timer -= delta
	if timer < 0.0:
		hide_overlay()
	pass

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_WINDOW_FOCUS_IN:
			get_tree().paused = false
			Engine.max_fps = SaveMan.get_data("fps")
		NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			Engine.max_fps = 5
			get_tree().paused = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		if event is InputEventKey:
			event = event as InputEventKey
			if not fullscreen:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
				if event.shift_pressed:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
					
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			fullscreen = not fullscreen
		pass
