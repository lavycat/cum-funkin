extends CanvasLayer
@onready var label:Label = $Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var font_size = 16
const aspect = 16.0/9.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var fps = Engine.get_frames_per_second()
	var ram = String.humanize_size(OS.get_static_memory_usage() + Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED))
	label.text = "FPS: %d\nMemory: %s"%[fps,ram]
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed() and not event.is_echo():
			if event.keycode == KEY_F1:
				label.visible = not label.visible
