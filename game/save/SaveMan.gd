extends Node
var save:SaveDat = SaveDat.new()
const SETTINGS_PATH:String = "user://save.tres"
func _ready():
	save = load_data()
	save_data()
	init_binds()
	
	
func get_data(setting:String,fb:Variant = null):
	var _ret = save.get(setting)
	if _ret == null:
		_ret = fb
	return _ret

func set_data(setting:String,value:Variant):
	save.set(setting,value)

func save_data():
	ResourceSaver.save(save,SETTINGS_PATH)

func load_data() -> SaveDat:
	var _ret:SaveDat = SaveDat.new()
	if FileAccess.file_exists(SETTINGS_PATH):
		_ret = ResourceLoader.load(SETTINGS_PATH)
	if !is_instance_valid(_ret):
		print("fallbnac daba")
		_ret = SaveDat.new()
		save_data()
	print("DATA LOADED: %s"%_ret)
	return _ret
func init_binds():
	for k in save.keybinds:
		if not InputMap.has_action(k):
			InputMap.add_action(k)
		InputMap.action_erase_events(k)
		for v in save.keybinds.get(k):
			var _ev := InputEventKey.new()
			_ev.keycode = OS.find_keycode_from_string(v.to_lower())
			InputMap.action_add_event(k,_ev)
