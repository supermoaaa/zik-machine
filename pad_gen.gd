extends Control


# Declare member variables here. Examples:
var conf_file = "res://conf.cfg"
var conf_machine = ""
var midi_map = []
var PATH = "res://sample/"

var drag_file = false
var list_file = {} # name:path
var Master_vol_midi = 13
var looper = false
var audio_set = []
var active_set = 0
var pad_number = 0
var default_rec_path = "res://record/"
var default_rec_name = "recorded.wav"
var recordingeffectmaster = AudioServer.get_bus_effect(0, 0)
var list_rec = []
var start_on_pad = false
var active_rec = false
var rec_Folder = null

#bpm variable
var master_Tempo = 461.0
var time = 0.0
var last_ticks = 0.0
var snyc_list = []


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
	
func load_wav_file(parent, path):

	var file = File.new()
	var list_wav = []
	if not file.file_exists(path):
		print("No file detected")
		return
	if file.open(path, File.READ) != 0:
		print("Error opening file")
		return
	
	while not file.eof_reached():
		list_wav.append(file.get_line())
	#print(list_wav)
	for rep in list_wav:
		if len(rep) > 2:
			var start_rep = get_node("File_rep").create_item(parent)
			start_rep.set_text(0, str(rep.get_file ()))
			list_file[rep.get_file ()] = rep

func set_rep(name, path, color):
	var rep = $File_rep.create_item($File_rep)
	rep.set_text(0, name)
	rep.set_selectable(0, false)
	rep.set_collapsed(true)
	rep.set_custom_color(0, color)
	load_wav_file(rep, path)
	if name == "record":
		rec_Folder = rep
		return rec_Folder

func Global_sync():
	time = OS.get_ticks_msec()
	if time - last_ticks >= master_Tempo:
		for sample in snyc_list:
			var active_loop = get_node("loop"+ str(sample))
			if active_loop.pressed == true and looper == true:
				var active_stream = get_node("play_instance" + str(sample))
				active_stream.play()
		last_ticks = time
	
func _process(_delta):
	if (Input.is_mouse_button_pressed(BUTTON_LEFT)):
		if drag_file == true:
			$selfile.set_position(get_local_mouse_position())
	else:
		$selfile.visible = false
		drag_file = false
	Global_sync()

func loadfile(filepath):
	var file = File.new()
	file.open(filepath, File.READ)
	var bytes = file.get_buffer(file.get_len())

	# if File is wav
	if filepath.ends_with(".wav"):

		var newstream = AudioStreamSample.new()


		for i in range(0, 100):
			var those4bytes = str(char(bytes[i])+char(bytes[i+1])+char(bytes[i+2])+char(bytes[i+3]))

			if those4bytes == "fmt ":


				#using formatsubchunk index so it's easier to understand what's going on
				var fsc0 = i+8 #fsc0 is byte 8 after start of "fmt "

				#get format code [Bytes 0-1]
				var format_code = bytes[fsc0] + (bytes[fsc0+1] << 8)
				newstream.format = format_code
				
				#get channel num [Bytes 2-3]
				var channel_num = bytes[fsc0+2] + (bytes[fsc0+3] << 8)

				if channel_num == 2: newstream.stereo = true
				
				#get sample rate [Bytes 4-7]
				var sample_rate = bytes[fsc0+4] + (bytes[fsc0+5] << 8) + (bytes[fsc0+6] << 16) + (bytes[fsc0+7] << 24)
				newstream.mix_rate = sample_rate
				

			if those4bytes == "data":
				var audio_data_size = bytes[i+4] + (bytes[i+5] << 8) + (bytes[i+6] << 16) + (bytes[i+7] << 24)

				var data_entry_point = (i+8)

				newstream.data = bytes.subarray(data_entry_point, data_entry_point+audio_data_size-1)
				
			# end of parsing
			#---------------------------

		#get samples and set loop end
		var samplenum = newstream.data.size() / 4
		newstream.loop_end = samplenum
		newstream.loop_mode = 0 #change to 0 or delete this line if you don't want loop, also check out modes 2 and 3 in the docs
		return newstream  #:D

	#if file is ogg
	elif filepath.ends_with(".ogg"):
		var newstream = AudioStreamOGGVorbis.new()
		#newstream.loop = true #set to false or delete this line if you don't want to loop
		newstream.data = bytes
		return newstream

	#if file is mp3
	elif filepath.ends_with(".mp3"):
		var newstream = AudioStreamMP3.new()
		#newstream.loop = true #set to false or delete this line if you don't want to loop
		newstream.data = bytes
		return newstream

	else:
		print ("ERROR: Wrong filetype or format")
	file.close()

func audio_loader(sample):
	var audio_stream_sample = loadfile(sample)
	return(audio_stream_sample)
	pass

func _ready():
	
	# load sample file
	var file_rep = get_node("File_rep")
	$File_rep.create_item(file_rep)
	$File_rep.set_hide_root(true)
	
	set_rep("sample", "res://sample_path.sav", Color(0.5, 0.8, 0.0, 1.0))
	set_rep("loop", "res://loop_path.sav", Color(0.0, 0.9, 0.0, 1.0))
	set_rep("record", "res://record_path.sav", Color(1.0, 0.2, 0.0, 1.0))
	

	# generate pad
	var pad_name = 0
	var configFile = ConfigFile.new()
	configFile.load(conf_file)
	conf_machine = configFile.get_value("MACHINE", "active_machine")

	configFile.load(conf_machine)
	active_set = configFile.get_value("PAD CONF", "BANK_active")
	pad_number = configFile.get_value("PAD CONF", "PAD_number")
	audio_set = configFile.get_value("PAD CONF", "audio_set")
	midi_map = configFile.get_value("PAD CONF", "midi_set")
	Master_vol_midi = configFile.get_value("PAD CONF", "midi_master")
	default_rec_path = configFile.get_value("OUTPUT", "song_save_path")

	var frist_pad_separator = VSeparator.new()
	frist_pad_separator.margin_top = self.get_rect().position[1]+(self.get_rect().size[1]/1.15)
	frist_pad_separator.margin_bottom = self.get_rect().position[1]+self.get_rect().size[1]*2.1
	frist_pad_separator.margin_left = (OS.get_screen_size().x/(pad_number + 4))*2.9
	frist_pad_separator.margin_right = (OS.get_screen_size().x/(pad_number + 4))*2.9
	frist_pad_separator.name = "sep0"
	#pad_separator.size_flags_horizontal = 4
	self.add_child(frist_pad_separator)

	for pad in pad_number:
		var pad_button = Button.new()
		pad_button.margin_top = OS.get_screen_size().y/2 - (pad_number*7)
		pad_button.margin_bottom = OS.get_screen_size().y/2 - (pad_number*2)
		pad_button.margin_left = (OS.get_screen_size().x/(pad_number + 4)*(pad_name + 3))
		pad_button.margin_right = (OS.get_screen_size().x/(pad_number + 4)*(pad_name + 3.8))
		pad_button.name = "pad" + str(pad_name)
		pad_button.text = audio_set[active_set][pad_name].get_file ().left ( 6 )
		pad_button.connect("button_down", self, "pad_press", [pad_name])
		pad_button.connect("mouse_entered", self, "pad_change_sample", [pad_name])
		self.add_child(pad_button)
		
		var pad_separator = VSeparator.new()
		pad_separator.margin_top = self.get_rect().position[1]+(self.get_rect().size[1]/1.15)
		pad_separator.margin_bottom = self.get_rect().position[1]+self.get_rect().size[1]*2.1
		pad_separator.margin_left = (OS.get_screen_size().x/(pad_number + 4)*(pad_name + 3.9))
		pad_separator.margin_right = (OS.get_screen_size().x/(pad_number + 4)*(pad_name + 4.0))
		pad_separator.name = "sep" + str(pad_name)
		#pad_separator.size_flags_horizontal = 4
		self.add_child(pad_separator)
		
				
		var loop_button = TextureButton.new()
		loop_button.margin_top = OS.get_screen_size().y/2 - (pad_number*1)
		loop_button.margin_bottom = OS.get_screen_size().y/2 + (pad_number*1)
		loop_button.margin_left = (OS.get_screen_size().x/(pad_number + 4)*(pad_name + 3))
		loop_button.margin_right = (OS.get_screen_size().x/(pad_number + 4)*(pad_name + 3.8))
		loop_button.name = "loop" + str(pad_name)
		loop_button.texture_normal = load("res://utils/bt_off.png")
		loop_button.texture_hover = load("res://utils/bt_over.png")
		loop_button.texture_pressed = load("res://utils/bt_on.png")
		loop_button.expand = true
		loop_button.toggle_mode = true
		loop_button.add_to_group("loops", true)
		
		var loop_text = Label.new()
		loop_text.text = "looper"
		loop_text.margin_left = 15
		loop_text.align = 2
		loop_text.valign = 1
		
		self.add_child(loop_button)
		loop_button.add_child(loop_text)
		

		var mute_button = TextureButton.new()
		mute_button.margin_top = OS.get_screen_size().y/2 + (pad_number*3)
		mute_button.margin_bottom = OS.get_screen_size().y/2 + (pad_number*5)
		mute_button.margin_left = (OS.get_screen_size().x/(pad_number + 4)*(pad_name + 3))
		mute_button.margin_right = (OS.get_screen_size().x/(pad_number + 4)*(pad_name + 3.8))
		mute_button.name = "mute" + str(pad_name)

		mute_button.texture_normal = load("res://utils/bt_off.png")
		mute_button.texture_hover = load("res://utils/bt_over.png")
		mute_button.texture_pressed = load("res://utils/bt_on.png")
		mute_button.expand = true
		mute_button.toggle_mode = true
		mute_button.connect("button_down", self, "mute_press", [pad_name])
		
		var mute_text = Label.new()
		mute_text.text = "mute"
		mute_text.margin_left = 15
		mute_text.align = 2
		mute_text.valign = 1
		self.add_child(mute_button)
		mute_button.add_child(mute_text)

		var ToTemp_button = TextureButton.new()
		ToTemp_button.margin_top = OS.get_screen_size().y/2 + (pad_number*1.2)
		ToTemp_button.margin_bottom = OS.get_screen_size().y/2 + (pad_number*3)
		ToTemp_button.margin_left = (OS.get_screen_size().x/(pad_number + 4)*(pad_name + 3))
		ToTemp_button.margin_right = (OS.get_screen_size().x/(pad_number + 4)*(pad_name + 3.8))
		ToTemp_button.name = "mute" + str(pad_name)

		ToTemp_button.texture_normal = load("res://utils/bt_off2.png")
		ToTemp_button.texture_hover = load("res://utils/bt_over2.png")
		ToTemp_button.texture_pressed = load("res://utils/bt_on2.png")
		ToTemp_button.expand = true
		ToTemp_button.toggle_mode = true
		ToTemp_button.connect("toggled", self, "_active_snyc_bpm", [pad_name])
		
		var ToTemp_text = Label.new()
		ToTemp_text.text = "bpm sync"
		ToTemp_text.margin_left = 6
		ToTemp_text.align = 2
		ToTemp_text.valign = 1
		self.add_child(ToTemp_button)
		ToTemp_button.add_child(ToTemp_text)

		var vel_button = TextureButton.new()
		vel_button.margin_top = OS.get_screen_size().y/2 + (pad_number*5)
		vel_button.margin_bottom = OS.get_screen_size().y/2 + (pad_number*7.5)
		vel_button.margin_left = (OS.get_screen_size().x/(pad_number + 4)*(pad_name + 3))
		vel_button.margin_right = (OS.get_screen_size().x/(pad_number + 4)*(pad_name + 3.8))
		vel_button.name = "vel" + str(pad_name)
		vel_button.texture_normal = load("res://utils/bt_off.png")
		vel_button.texture_hover = load("res://utils/bt_over.png")
		vel_button.texture_pressed = load("res://utils/bt_on.png")
		vel_button.expand = true
		vel_button.toggle_mode = true
		
		var vel_text = Label.new()
		vel_text.text = "vel to vol"
		
		vel_text.margin_left = 5
		vel_text.margin_top = 3
		vel_text.align = 2
		vel_text.valign = 1
		self.add_child(vel_button)
		vel_button.add_child(vel_text)


		
		var pad_volume = VSlider.new()
		pad_volume.margin_top = OS.get_screen_size().y/2 - (pad_number*22)
		pad_volume.margin_bottom = OS.get_screen_size().y/2 - (pad_number*8)
		pad_volume.margin_left = (OS.get_screen_size().x/(pad_number + 4)*(pad_name + 3.3))
		pad_volume.margin_right = (OS.get_screen_size().x/(pad_number + 4)*(pad_name + 3.5))
		pad_volume.name = "volume" + str(pad_name)
		pad_volume.max_value = 25
		pad_volume.min_value = -80
		pad_volume.value = -15
		pad_volume.connect("value_changed", self, "volume_change", [str(pad_name)])
		self.add_child(pad_volume)
		
		var play_instance = AudioStreamPlayer.new()
		play_instance.name = "play_instance" + str(pad_name)
		play_instance.stream = audio_loader(audio_set[active_set][pad_name])
		play_instance.volume_db = -15
		play_instance.connect("finished", self, "audio_stat", [str(pad_name)])
		play_instance.add_to_group("song")
		self.add_child(play_instance)
		pad_name += 1
		pass
		
enum GlobalScope_MidiMessageList {
	MIDI_MESSAGE_NOTE_OFF = 0x8,
	MIDI_MESSAGE_NOTE_ON = 0x9,
	MIDI_MESSAGE_AFTERTOUCH = 0xA,
	MIDI_MESSAGE_CONTROL_CHANGE = 0xB,
	MIDI_MESSAGE_PROGRAM_CHANGE = 0xC,
	MIDI_MESSAGE_CHANNEL_PRESSURE = 0xD,
	MIDI_MESSAGE_PITCH_BEND = 0xE,
	MIDI_MESSAGE_SYSTEM = 0xF,
};

func get_midi_message_description(event : InputEventMIDI):

	if GlobalScope_MidiMessageList.values().has(event.message):
		return GlobalScope_MidiMessageList.keys()[event.message - 0x08]
	return(event.message)


func _unhandled_input(event : InputEvent):

	if (event is InputEventMIDI):
		#event_dump = "event: {0}\n".format([get_midi_message_description(event)])
		#event_dump = "chn: {channel} msg: {message}\n".format({"channel": event.channel, "message": event.message})
		#event_dump = "  pitch: {pitch} vel: {velocity}\n".format({"pitch": event.pitch, "velocity": event.velocity})
		print(event.message)
		var key_index = event.pitch
		var key_vel = event.velocity
		
		#print(midi_map)
		if key_index in midi_map[active_set]:
			#print("key=" + str(midi_map[active_set].find(key_index)))
			var active_PAD = "pad" + str(midi_map[active_set].find(key_index))
			var active_vel = "vel" + str(midi_map[active_set].find(key_index))

			if get_node(active_vel).pressed == true:
				# not good 
				get_node("play_instance" + str(midi_map[active_set].find(key_index))).volume_db = (key_vel * 0.67) - 70
				get_node("volume" + str(midi_map[active_set].find(key_index))).value = (key_vel * 0.67) - 70

			match event.message:
				MIDI_MESSAGE_NOTE_ON:
					var input_event = InputEventMouseButton.new()
					input_event.pressed = true
					input_event.button_index = BUTTON_LEFT
					input_event.position = get_node(active_PAD).rect_global_position
					get_tree().input_event(input_event)


				MIDI_MESSAGE_NOTE_OFF:
					var input_event = InputEventMouseButton.new()
					input_event.pressed = false
					input_event.button_index = BUTTON_LEFT
					input_event.position = get_node(active_PAD).rect_global_position
					get_tree().input_event(input_event)
		else:
			var pad_name = 0
			for map in midi_map:
				if key_index in map:
					active_set = midi_map.find(map)
					get_node("../info/Label").text = "MIDI BANK:" + str(active_set)
					for play_instance in get_tree().get_nodes_in_group("song"):
						play_instance.stream = load(audio_set[active_set][pad_name])
						get_node("pad" + str(pad_name)).text = audio_set[active_set][pad_name].get_file ().left ( 6 )
						pad_name += 1
						

func pad_press(pad_name):

	var active_stream = get_node("play_instance" + str(pad_name))
	var active_mute = get_node("mute"+ str(pad_name))
	var active_loop = get_node("loop"+ str(pad_name))
	if active_rec == true:
		recordingeffectmaster.set_recording_active(true)
		active_rec = false
		
	if active_mute.pressed == false :
		if active_loop.pressed == false :
			active_stream.play()
		else:
			if active_stream.is_playing():
				looper = false
				active_stream.stop()
				
			else:
				looper = true
				active_stream.play()
				

func mute_press(pad_name):
	get_node("play_instance" + str(pad_name)).stop()
	
func pad_change_sample(pad_name):
	if drag_file == true:
		var sel_file_name = get_node("File_rep").get_selected().get_text(0)
		drag_file = false
		$selfile.visible = false
		var active_node = "pad" + str(pad_name)
		var active_loop = get_node("loop"+ str(pad_name))
		if active_loop.pressed == true :
			get_node("play_instance"+str(pad_name)).stop()
			
		get_node(active_node).text = sel_file_name.left ( 6 )
		get_node("play_instance"+str(pad_name)).stream = audio_loader(list_file[sel_file_name])
		audio_set[active_set][pad_name] = list_file[sel_file_name]
		if looper == true:
			get_node("play_instance"+str(pad_name)).play()

func volume_change(volume, number):
	get_node("play_instance" + str(number)).volume_db = volume

func audio_stat(pad_name):
	var active_stream = get_node("play_instance" + str(pad_name))
	var active_loop = get_node("loop"+ str(pad_name))
	if active_loop.pressed == true and looper == true:
		active_stream.play()

func _on_File_rep_cell_selected():
	$sound_file.stream = audio_loader(list_file[get_node("File_rep").get_selected().get_text(0)])
	if $MuteButtonItem.pressed == false:
		$sound_file.play()
	$selfile.set_position(get_local_mouse_position())
	$selfile.visible = true
	drag_file = true


func _on_Button_toggled(button_pressed):
	var loops_node = get_tree().get_nodes_in_group("loops")
	if button_pressed == true:
		for loop in loops_node:
			loop.pressed = true
	else:
		for loop in loops_node:
			loop.pressed = false


func _on_save_current_bank_pressed():
	#print(audio_set[active_set])
	var configFile = ConfigFile.new()
	configFile.load(conf_machine)
	configFile.set_value("PAD CONF", "audio_set", audio_set)
	configFile.save(conf_machine)


func _on_MuteButtonItem_toggled(_button_pressed):
	if $MuteButtonItem.pressed == true:
		$sound_file.stop()


	
func _on_Rec_Button_toggled(button_pressed):
	if button_pressed:
		if start_on_pad == false:
			recordingeffectmaster.set_recording_active(true)
		else:
			active_rec = true
		
	else:
		recordingeffectmaster.set_recording_active(false)
		var final_recording = recordingeffectmaster.get_recording()
		if default_rec_name in list_file:
			default_rec_name = default_rec_name.get_basename() + "0.wav"
		final_recording.save_to_wav(default_rec_path+default_rec_name)
		
		var file = File.new()			
		if file.open("res://record_path.sav", File.WRITE) != 0:
			print("Error opening file")
			return

		for rec_file in list_rec:
			file.store_line(rec_file)
		file.close()
		
	
		if not file.file_exists("res://record_path.sav"):
			print("No file detected")
			return
		if file.open("res://record_path.sav", File.READ) != 0:
			print("Error opening file")
			return
		
		while not file.eof_reached():
			list_rec.append(file.get_line())
		list_rec.append(str(default_rec_path+default_rec_name))
		file.close()

		#print(rep)
		var rec = $File_rep.create_item(rec_Folder)
		rec.set_text(0, default_rec_name)
		list_file[default_rec_name] = default_rec_path + default_rec_name

		pass


func _on_LineEdit_text_entered(new_text):
	if new_text.get_extension () == "wav":
		default_rec_name = new_text
	else:
		default_rec_name = new_text + ".wav"


func _on_start_rec_toggled(button_pressed):
	start_on_pad = button_pressed


func _on_SpinBox_value_changed(value):
	master_Tempo = 60000/value
	
func _active_snyc_bpm(toggled, pad_name):
	if toggled == true:
		snyc_list.append(pad_name)
	else:
		var idx = snyc_list.find(pad_name)
		snyc_list.remove(idx)

