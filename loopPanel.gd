extends ColorRect


# Declare member variables here. Examples:
var PATH = "res://loop/"
var list_file = []
# var b = "text"



func get_filelist(scan_dir : String) -> Array:
	var my_files : Array = []
	var dir := Directory.new()
	if dir.open(scan_dir) != OK:
		printerr("Warning: could not open directory: ", scan_dir)
		return []
	
	if dir.list_dir_begin(true, true) != OK:
		printerr("Warning: could not list contents of: ", scan_dir)
		return []
	
	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			my_files += get_filelist(dir.get_current_dir() + "/" + file_name)
		else:
			if file_name.get_extension () == "wav":
				my_files.append(dir.get_current_dir() + "/" + file_name)
	
		file_name = dir.get_next()
	
	return my_files

func load_wav_file():
	var file_rep = get_node("LoopTrack")

	
	for rep in get_filelist(PATH):
		file_rep.add_item(str(rep.get_file ()))
		list_file.append(rep.get_file ())


# Called when the node enters the scene tree for the first time.
func _ready():
	load_wav_file()
	pass # Replace with function body.
	var loop_instance = AudioStreamPlayer.new()
	loop_instance.name = "loop_stream"
	loop_instance.stream = load("res://loop/"+list_file[0])
	#loop_instance.loop = true
	self.add_child(loop_instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_playLoop_pressed():
	$pauseLoop.pressed = false
	$stopLoop.pressed = false
	

	if $loop_stream.stream_paused == true:
		$loop_stream.stream_paused = false
	else:
		$loop_stream.play()
		
func _on_pauseLoop_pressed():
	$stopLoop.pressed = false
	$playLoop.pressed = false
	
	if $loop_stream.stream_paused == true:
		$loop_stream.stream_paused = false
	else:
		$loop_stream.stream_paused = true


func _on_stopLoop_pressed():
	$playLoop.pressed = false
	$pauseLoop.pressed = false
	
	$loop_stream.stop()
	
	


func _on_LoopTrack_item_selected(id):
	get_node("loop_stream").stream = load("res://loop/"+str(list_file[id]))


func _on_loopVolume_value_changed(value):
	$loop_stream.volume_db = value



