extends WindowDialog

var conf_machine = ""
var conf_file = "res://conf.cfg"


# Called when the node enters the scene tree for the first time.
func _ready():
	var configFile = ConfigFile.new()
	configFile.load(conf_file)
	conf_machine = configFile.get_value("MACHINE", "active_machine")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
