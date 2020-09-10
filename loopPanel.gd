extends ColorRect


# Declare member variables here. Examples:

var conf_file = "res://conf.cfg"
var list_file = []
var playing = 0


func load_wav_file():
	var file_rep = get_node("LoopTrack")
	var file = File.new()
	if not file.file_exists("res://loop_path.sav"):
		print("No file detected")
		return
	if file.open("res://loop_path.sav", File.READ) != 0:
		print("Error opening file")
		return
	
	while not file.eof_reached():
		list_file.append(file.get_line())
	for rep in list_file:
		file_rep.add_item(rep)


func _ready():
	var configFile = ConfigFile.new()
	configFile.load(conf_file)
	load_wav_file()

	var loop_instance = AudioStreamPlayer.new()
	loop_instance.name = "loop_stream"
	loop_instance.stream = load("res://loop/"+list_file[0])
	loop_instance.connect("finished", self, "audio_stat")
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
		playing = 1
		
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
	playing = 0


func _on_LoopTrack_item_selected(id):
	get_node("loop_stream").stream = load("res://loop/"+str(list_file[id]))


func _on_loopVolume_value_changed(value):
	$loop_stream.volume_db = value

func audio_stat():
	if playing == 1:
		get_node("loop_stream").play()

