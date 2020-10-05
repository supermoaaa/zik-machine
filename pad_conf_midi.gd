extends WindowDialog

var conf_machine = ""
var conf_file = "res://conf.cfg"
var pad = 16
var active_set = 0
var midi_map = []


func _ready():
	var configFile = ConfigFile.new()
	configFile.load(conf_file)
	conf_machine = configFile.get_value("MACHINE", "active_machine")
	configFile.load(conf_machine)
	pad = configFile.get_value("PAD CONF", "PAD_number")
	midi_map = configFile.get_value("PAD CONF", "midi_set")
	
	$CenterMidi/GridContainer.columns = pad/4
	for bt in pad:
		var testbt = Button.new()
		#testbt.margin_top = 30
		#testbt.margin_bottom = 30
		testbt.text = str(midi_map[active_set][bt])
		testbt.name = str(bt)
		testbt.toggle_mode = true
		testbt.connect("button_down", self, "midi_learn", [bt])
		testbt.add_to_group("midi_bt")
		$CenterMidi/GridContainer.add_child(testbt)

func midi_learn(bt):
	var active_bt = get_node("CenterMidi/GridContainer/"+str(bt))
	if not active_bt.text == "learn":
		#old_key = active_bt.text
		active_bt.text = "learn"
	else:
		active_bt.text = str(midi_map[active_set][bt])
	
	var midi_bt_node = get_tree().get_nodes_in_group("midi_bt")
	
	for midi_bt in midi_bt_node:
		if not midi_bt == active_bt:
			if midi_bt.pressed == true:
				midi_bt.text = str(midi_map[active_set][int(midi_bt.name)])
			midi_bt.pressed = false


enum GlobalScope_MidiMessageList {
	MIDI_MESSAGE_NOTE_OFF = 0x8,
	MIDI_MESSAGE_NOTE_ON = 0x9,
	MIDI_MESSAGE_AFTERTOUCH = 0xA,
	MIDI_MESSAGE_CONTROL_CHANGE = 0xB,
	MIDI_MESSAGE_PROGRAM_CHANGE = 0xC,
	MIDI_MESSAGE_CHANNEL_PRESSURE = 0xD,
	MIDI_MESSAGE_PITCH_BEND = 0xE,
};

func get_midi_message_description(event : InputEventMIDI):
	if GlobalScope_MidiMessageList.values().has(event.message):
		return GlobalScope_MidiMessageList.keys()[event.message - 0x08]
	#print(event.message)
	
func _unhandled_input(event : InputEvent):
	var midi_bt_node = get_tree().get_nodes_in_group("midi_bt")

	if (event is InputEventMIDI):

		var key_index = event.pitch
		for midi_bt in midi_bt_node:
			if midi_bt.pressed == true:
				midi_map[active_set][int(midi_bt.name)] = key_index
				midi_bt.text = str(key_index)
				midi_bt.pressed = false
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
