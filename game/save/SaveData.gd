class_name SaveDat extends Resource
@export var fps:int = 120:
	set(v): 
		fps = v
		Engine.max_fps = v
@export var vsync:bool = false:
	set(v):
		vsync = v
		if v:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		else:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
@export var downscroll:bool = true
@export var center_notefield:bool = false
@export var autoplay:bool = false
@export var shaders:bool = true:
	set(v):
		shaders = v
		Game.shaders = v
@export var scroll_speed:float = 1.0
@export var note_offset:float = 0.0
@export var opponent_play:bool = false
@export var volume:float = 1.0:
	set(v):
		volume = v
		AudioServer.set_bus_volume_db(0,linear_to_db(volume))
@export var normalize_pitch:bool = false
		
@export var keybinds:Dictionary = {
	"note_left" : ["left","d"],
	"note_down" : ["down","f"],
	"note_up" : ["up","j"],
	"note_right" : ["right","k"],
	"volume_down" : ["minus","kp subtract"],
	"volume_up" : ["equal","kp add"]
	
}
