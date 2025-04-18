extends Node
## class that saves ur score to a file, format of {"song_name/diff" = [SCORE,COMBO_BREAKS,ACCURACY]}
const score_path:String = "user://scores.dat"
var scores:Dictionary = {}
func _enter_tree() -> void:
	load_scores()
func get_score(song:String,diff:String):
	return scores.get("%s/%s"%[song,diff],[0,0,0])
func add_score(song:String,diff:String,stats:Array):
	scores.set("%s/%s"%[song,diff],stats)
	flush_scores()
func load_scores() -> void:
	if FileAccess.file_exists(score_path):
		scores = bytes_to_var(FileAccess.get_file_as_bytes(score_path))
	else:
		scores = {}
		flush_scores()
	
func flush_scores() -> void:
	var f = FileAccess.open(score_path,FileAccess.WRITE)
	f.store_buffer(var_to_bytes(scores))
	f.flush()
	f.close()
	
