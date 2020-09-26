extends RichTextLabel


const bbcode = "ZIK MACHINE,\n \n Author: Moaaa \n website: [url=https://github.com/supermoaaa/zik-machine]zik-machine[/url]"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_bbcode(bbcode)
# warning-ignore:return_value_discarded
	connect("meta_clicked", self, "meta_clicked")


func meta_clicked( meta ):
# warning-ignore:return_value_discarded
	OS.shell_open(meta)

